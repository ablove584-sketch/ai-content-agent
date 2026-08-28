import os
import json
import re
import requests
import time
import random
from typing import Dict, Any, List, Optional
from src.config import Config

# قائمة شاملة بجميع موديلات Gemini المعروفة
ALL_GEMINI_MODELS = [
    # الجيل الأحدث (2.5) - موصى به
    "gemini-2.5-flash",
    "gemini-2.5-pro",
    "gemini-2.5-flash-lite",
    
    # الجيل الثاني (2.0)
    "gemini-2.0-flash",
    "gemini-2.0-flash-lite",
    "gemini-2.0-pro-exp",
    
    # الجيل الأول (1.5) - قد يكون متوقفاً
    "gemini-1.5-pro",
    "gemini-1.5-flash",
    
    # موديلات قديمة (غالباً متوقفة)
    "gemini-1.0-pro",
    "gemini-pro",
]

# موديلات سيتم تجاهلها نهائياً (معروفة بأنها متوقفة)
KNOWN_DEPRECATED = {
    "gemini-pro-vision",
    "gemini-1.0-pro-vision",
    "gemini-ultra",
}

class ContentGenerator:
    def __init__(self, config: Config):
        self.config = config
        self.gemini_key = config.GEMINI_API_KEY
        
        # قراءة قائمة الموديلات من البيئة
        models_env = os.getenv("GEMINI_MODELS", "")
        if models_env:
            self.models = [m.strip() for m in models_env.split(",") if m.strip()]
        else:
            self.models = ALL_GEMINI_MODELS.copy()
        
        # إزالة الموديلات المتوقفة المعروفة
        self.models = [m for m in self.models if m not in KNOWN_DEPRECATED]
        
        # النموذج المفضل للبدء
        preferred = os.getenv("GEMINI_MODEL", "")
        if preferred and preferred in self.models:
            self.current_model = preferred
        else:
            self.current_model = self.models[0] if self.models else "gemini-2.5-flash"
        
        # قائمة الموديلات التي فشلت في هذه الجلسة
        self.failed_models = set()
        
        print(f"🤖 Total models: {len(self.models)}")
        print(f"📋 Models list: {self.models}")
        print(f"🎯 Starting with: {self.current_model}")
        print(f" Strategy: Auto-fallback on failure")

    def build_prompt(self, recent_posts: List[Dict[str, Any]]) -> str:
        memory = ""
        if recent_posts:
            memory = "\n\n**المنشورات السابقة (لا تكرر هذه الأفكار):**\n"
            for i, post in enumerate(recent_posts[:self.config.MEMORY_CONTEXT_LIMIT], 1):
                memory += f"\n{i}. {post.get('title', '')}\n"
                memory += f"   الفكرة: {post.get('core_idea', '')}\n"

        content_type = os.getenv("CONTENT_TYPE", "random")
        book_name = os.getenv("BOOK_NAME", "")
        custom_topic = os.getenv("CUSTOM_TOPIC", "")

        if content_type == "book_summary" and book_name:
            topic = f"ملخص كتاب: {book_name}"
            type_instruction = "اكتب ملخصاً احترافياً يبرز الأفكار الرئيسية والدروس المستفادة"
        elif custom_topic:
            topic = custom_topic
            type_instruction = "اكتب محتوى احترافياً عن هذا الموضوع"
        else:
            topic = self.config.CONTENT_TOPIC
            type_instruction = "اكتب محتوى احترافياً ومفيداً"

        return f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة لـ {self.config.CONTENT_AUDIENCE}.

**نوع المحتوى:** {content_type}
{type_instruction}

**الموضوع:** {topic}
**الأسلوب:** {self.config.CONTENT_STYLE}
**اللغة:** {self.config.CONTENT_LANGUAGE}

{memory}

**مهم جداً:** لا تكرر الأفكار السابقة. قدم زاوية جديدة تماماً.

**أعد النتيجة بصيغة JSON فقط** (بدون أي نص إضافي):

```json
{{
  "title": "العنوان",
  "topic": "الموضوع الفرعي",
  "angle": "الزاوية",
  "core_idea": "الفكرة الأساسية",
  "keywords": ["كلمة1", "كلمة2"],
  "content": "المحتوى الكامل هنا",
  "hashtags": ["#هاشتاج1", "#هاشتاج2"]
}}
```"""

    def extract_json(self, text: str) -> Optional[Dict[str, Any]]:
        text = text.strip()
        text = re.sub(r'^```json\s*', '', text, flags=re.MULTILINE)
        text = re.sub(r'^```\s*', '', text, flags=re.MULTILINE)
        text = re.sub(r'```$', '', text, flags=re.MULTILINE)
        text = text.strip()

        try:
            return json.loads(text)
        except:
            pass

        match = re.search(r'\{[\s\S]*\}', text)
        if match:
            try:
                return json.loads(match.group(0))
            except:
                pass

        return None

    def generate(self, config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        if not self.gemini_key:
            print("❌ No Gemini API key configured")
            return None

        prompt = self.build_prompt(recent_posts)

        # ترتيب الموديلات: المفضل أولاً، ثم الباقي عشوائياً
        available_models = [m for m in self.models if m not in self.failed_models]
        
        if not available_models:
            print("❌ No available models!")
            return None
        
        # ضع الموديل الحالي في البداية
        ordered = [self.current_model] if self.current_model in available_models else []
        others = [m for m in available_models if m != self.current_model]
        random.shuffle(others)
        ordered.extend(others)

        print(f"\n🎯 Models order: {ordered}")

        # تجربة كل موديل
        for model in ordered:
            print(f"\n{'='*50}")
            print(f"🎯 Trying model: {model}")
            print(f"{'='*50}")
            
            max_retries = 2
            for attempt in range(1, max_retries + 1):
                print(f"  Attempt {attempt}/{max_retries}")
                result, error_code = self._generate_gemini(prompt, model)
                
                if result:
                    print(f"\n✅ SUCCESS with {model} (attempt {attempt})")
                    self.current_model = model
                    return result
                
                # إذا كان 404، تخطى هذا الموديل نهائياً
                if error_code == 404:
                    print(f"  ⛔ Model {model} NOT FOUND - skipping permanently")
                    self.failed_models.add(model)
                    break
                
                # إذا كان Rate Limit، انتقل للموديل التالي
                if error_code == 429:
                    print(f"  ⚠️ Rate limit on {model} - trying next model")
                    break
                
                if attempt < max_retries:
                    wait = 20
                    print(f"  ⏳ Waiting {wait}s before retry...")
                    time.sleep(wait)

        print("\n❌ All models failed")
        return None

    def _generate_gemini(self, prompt: str, model: str):
        """توليد محتوى باستخدام موديل محدد. تُرجع (result, error_code)"""
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
        headers = {"Content-Type": "application/json"}
        params = {"key": self.gemini_key}
        data = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "temperature": 0.8,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048,
            }
        }

        try:
            response = requests.post(url, headers=headers, params=params, json=data, timeout=90)
            
            if response.status_code == 429:
                print(f"  ⚠️ Rate limit exceeded")
                return None, 429
            elif response.status_code == 404:
                print(f"  ❌ Model not found (404)")
                return None, 404
            elif response.status_code == 503:
                print(f"  ⚠️ Service unavailable (503)")
                return None, 503
            elif response.status_code != 200:
                print(f"   API error: {response.status_code}")
                try:
                    err = response.json()
                    print(f"     Details: {err.get('error', {}).get('message', '')[:100]}")
                except:
                    pass
                return None, response.status_code

            result = response.json()
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                return self.extract_json(content_text), 200
            return None, 200
            
        except Exception as e:
            print(f"  ❌ Network error: {e}")
            return None, 0


def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    generator = ContentGenerator(config)
    return generator.generate(config, recent_posts)
