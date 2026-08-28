from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, MessageHandler, filters, ContextTypes, ConversationHandler
import requests
import os
import json

# ==================== الإعدادات ====================
BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
CHANNEL_ID = os.getenv("TELEGRAM_CHANNEL_ID")
GITHUB_TOKEN = os.getenv("GITHUB_TRIGGER_TOKEN")
GITHUB_USERNAME = "ablove584-sketch"
REPO_NAME = "ai-content-agent"
WORKFLOW_FILE = "content-agent.yml"

# حالات المحادثة
CHOOSING_TYPE, ENTERING_BOOK, ENTERING_TOPIC = range(3)

# أنواع المحتوى
CONTENT_TYPES = {
    "book_summary": "📚 ملخص كتاب",
    "article": "📝 مقال",
    "story": "📖 قصة",
    "facts": "💡 حقائق",
    "tips": "🎯 نصائح",
    "news": "📰 خبر تقني",
    "philosophy": "🤔 فلسفة",
    "history": "🏛️ تاريخ",
    "science": "🔬 علوم",
    "psychology": "🧠 علم نفس",
    "random": "🎲 عشوائي"
}

# حفظ بيانات المستخدم
user_data = {}
# ===================================================

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """أمر /start"""
    keyboard = [
        [InlineKeyboardButton("🚀 نشر محتوى جديد", callback_data="publish")]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.message.reply_text(
        "🤖 مرحباً! أنا بوت التحكم في نشر المحتوى.\n\n"
        "يمكنني نشر أنواع مختلفة من المحتوى على قناتك.\n\n"
        "اضغط الزر أدناه للبدء:",
        reply_markup=reply_markup
    )

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """معالجة الأزرار"""
    query = update.callback_query
    await query.answer()
    
    if query.data == "publish":
        # عرض أنواع المحتوى
        keyboard = []
        for key, value in CONTENT_TYPES.items():
            keyboard.append([InlineKeyboardButton(value, callback_data=f"type_{key}")])
        
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text(
            "📋 اختر نوع المحتوى:",
            reply_markup=reply_markup
        )
    
    elif query.data.startswith("type_"):
        content_type = query.data.replace("type_", "")
        user_id = update.effective_user.id
        user_data[user_id] = {"content_type": content_type}
        
        if content_type == "book_summary":
            await query.edit_message_text(
                "📚 اخترت: ملخص كتاب\n\n"
                "أدخل اسم الكتاب الذي تريد تلخيصه:\n"
                "(مثال: العادات الذرية، فن اللامبالاة)"
            )
            return ENTERING_BOOK
        
        elif content_type == "random":
            # نشر عشوائي مباشرة
            await query.edit_message_text(" جاري نشر محتوى عشوائي...")
            await trigger_workflow(user_data[user_id])
            await query.message.reply_text("✅ تم تشغيل عملية النشر!")
            return ConversationHandler.END
        
        else:
            # عرض مواضيع فرعية
            keyboard = [
                [InlineKeyboardButton("📝 موضوع عام", callback_data="topic_general")],
                [InlineKeyboardButton("✏️ أدخل موضوع محدد", callback_data="topic_custom")]
            ]
            reply_markup = InlineKeyboardMarkup(keyboard)
            await query.edit_message_text(
                f"📋 اخترت: {CONTENT_TYPES[content_type]}\n\n"
                "اختر طريقة تحديد الموضوع:",
                reply_markup=reply_markup
            )
    
    elif query.data.startswith("topic_"):
        user_id = update.effective_user.id
        if query.data == "topic_general":
            user_data[user_id]["topic"] = "عام"
            await query.edit_message_text(" موضوع عام\n\nجاري النشر...")
        else:
            await query.edit_message_text(
                "✏️ أدخل الموضوع المحدد:\n"
                "(مثال: الذكاء الاصطناعي، تطوير الذات)"
            )
            return ENTERING_TOPIC
        
        await trigger_workflow(user_data[user_id])
        await query.message.reply_text("✅ تم تشغيل عملية النشر!")
        return ConversationHandler.END
    
    return ConversationHandler.END

async def enter_book(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """استقبال اسم الكتاب"""
    user_id = update.effective_user.id
    book_name = update.message.text.strip()
    user_data[user_id]["book_name"] = book_name
    
    await update.message.reply_text(
        f" الكتاب: {book_name}\n\n"
        "جاري توليد الملخص ونشره..."
    )
    
    await trigger_workflow(user_data[user_id])
    await update.message.reply_text("✅ تم تشغيل عملية النشر!")
    
    return ConversationHandler.END

async def enter_topic(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """استقبال الموضوع المخصص"""
    user_id = update.effective_user.id
    topic = update.message.text.strip()
    user_data[user_id]["topic"] = topic
    
    await update.message.reply_text(
        f"📝 الموضوع: {topic}\n\n"
        "جاري توليد المحتوى ونشره..."
    )
    
    await trigger_workflow(user_data[user_id])
    await update.message.reply_text("✅ تم تشغيل عملية النشر!")
    
    return ConversationHandler.END

async def trigger_workflow(data: dict):
    """تشغيل GitHub Actions workflow مع البيانات"""
    url = f"https://api.github.com/repos/{GITHUB_USERNAME}/{REPO_NAME}/actions/workflows/{WORKFLOW_FILE}/dispatches"
    
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json",
        "Content-Type": "application/json"
    }
    
    # تحضير البيانات
    inputs = {
        "content_type": data.get("content_type", "random"),
        "book_name": data.get("book_name", ""),
        "custom_topic": data.get("topic", "")
    }
    
    data_payload = {
        "ref": "main",
        "inputs": inputs
    }
    
    try:
        response = requests.post(url, headers=headers, json=data_payload, timeout=30)
        
        if response.status_code == 204:
            print(f"✅ Workflow triggered: {inputs}")
            return True
        else:
            print(f"❌ GitHub API error: {response.status_code}")
            print(f"Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

async def status_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """أمر /status"""
    url = f"https://api.github.com/repos/{GITHUB_USERNAME}/{REPO_NAME}/actions/runs?per_page=5"
    
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    
    try:
        response = requests.get(url, headers=headers, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            workflows = data.get("workflow_runs", [])
            
            status_msg = "📊 آخر 5 عمليات:\n\n"
            
            for wf in workflows:
                status = "✅" if wf["conclusion"] == "success" else "❌" if wf["conclusion"] else "🔄"
                created = wf["created_at"][:16].replace("T", " ")
                status_msg += f"{status} {created}\n"
            
            await update.message.reply_text(status_msg)
        else:
            await update.message.reply_text(f" فشل: {response.status_code}")
            
    except Exception as e:
        await update.message.reply_text(f"❌ خطأ: {str(e)}")

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """أمر /help"""
    await update.message.reply_text(
        " المساعدة:\n\n"
        "/start - بدء النشر التفاعلي\n"
        "/status - حالة العمليات\n"
        "/help - هذه الرسالة\n\n"
        "أنواع المحتوى:\n"
        "📚 ملخص كتاب\n"
        " مقال\n"
        "📖 قصة\n"
        "💡 حقائق\n"
        "🎯 نصائح\n"
        "📰 خبر تقني\n"
        " فلسفة\n"
        "🏛️ تاريخ\n"
        "🔬 علوم\n"
        "🧠 علم نفس\n"
        "🎲 عشوائي"
    )

def main():
    """تشغيل البوت"""
    print("🤖 Starting Telegram Bot...")
    
    application = Application.builder().token(BOT_TOKEN).build()
    
    # محادثة تفاعلية
    conv_handler = ConversationHandler(
        entry_points=[
            CommandHandler("start", start),
            CallbackQueryHandler(button_handler)
        ],
        states={
            ENTERING_BOOK: [MessageHandler(filters.TEXT & ~filters.COMMAND, enter_book)],
            ENTERING_TOPIC: [MessageHandler(filters.TEXT & ~filters.COMMAND, enter_topic)],
        },
        fallbacks=[CommandHandler("cancel", lambda u, c: ConversationHandler.END)]
    )
    
    application.add_handler(conv_handler)
    application.add_handler(CommandHandler("status", status_command))
    application.add_handler(CommandHandler("help", help_command))
    
    print("✅ Bot is running!")
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
