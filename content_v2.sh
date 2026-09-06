#!/bin/bash

# ========== 1) الموقع ==========
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'content-v2' not in c:
    extra = r'''
<script>
// ====== content-v2: حذف العاطفية + إضافة 9 تصنيفات ======
['hope','life','friendship','mother','homeland','exile','success','failure','love','change'].forEach(function(k){delete TYPE_LABELS[k];delete TYPE_ICONS[k];delete TYPE_IMAGES[k];});
Object.assign(TYPE_LABELS,{amazing_facts:'معلومات وحقائق مذهلة',ai_tech:'الذكاء الاصطناعي والتقنية',self_dev:'تطوير الذات والمهارات',money:'المال والأعمال',true_stories:'قصص حقيقية قصيرة',world:'حول العالم',simple_science:'العلوم المبسطة',civilizations:'التاريخ والحضارات',daily:'محتوى يومي سريع'});
Object.assign(TYPE_ICONS,{amazing_facts:'🌍',ai_tech:'🤖',self_dev:'🧠',money:'💰',true_stories:'📖',world:'✈️',simple_science:'🔬',civilizations:'🏛️',daily:'⚡'});
var U3='https://images.unsplash.com/';var Q3='?w=500&q=60&auto=format';
Object.assign(TYPE_IMAGES,{amazing_facts:U3+'photo-1446776811953-b23d57bd21aa'+Q3,ai_tech:U3+'photo-1485827404703-89b55fcc595e'+Q3,self_dev:U3+'photo-1499750310107-5fef28a66643'+Q3,money:U3+'photo-1554224155-6726b3ff858f'+Q3,true_stories:U3+'photo-1455390582262-044cdead277a'+Q3,world:U3+'photo-1488646953014-85cb44e25828'+Q3,simple_science:U3+'photo-1532094349884-543bc11b234d'+Q3,civilizations:U3+'photo-1461360370896-922624d12aa1'+Q3,daily:U3+'photo-1451187580459-43490279c0fa'+Q3});
var EMOT=['hope','life','friendship','mother','homeland','exile','success','failure','love','change'];
var _dt3=detectType;
detectType=function(p){
var s=((p.title||'')+' '+(p.content||'')+' '+(p.hashtags||[]).join(' '));
if(/معلومة اليوم|رقم اليوم|حدث في مثل هذا اليوم|هل تعلم/.test(s))return 'daily';
if(/حضارة|حضارات|فرعون|معركة|اكتشافات/.test(s))return 'civilizations';
if(/جسم الإنسان|الحيوانات|لماذا يحدث|فيزياء|كيمياء|فضاء/.test(s))return 'simple_science';
if(/ذكاء اصطناعي|أدوات|AI|تقنية|مواقع مفيدة|تطبيق|برمج/.test(s))return 'ai_tech';
if(/إدارة الوقت|تركيز|تعلم|عادات|تواصل|تطوير الذات|مهارات/.test(s))return 'self_dev';
if(/مشروع|تجارة|ادخار|استثمار|عمل حر|مال|أعمال|شركة/.test(s))return 'money';
if(/حول العالم|دول|مدن|شعوب|سياحة|قوانين/.test(s))return 'world';
if(/قصة حقيقية|حدثت|اختراع|غريبة|شخص/.test(s))return 'true_stories';
if(/حقائق|مذهلة|أرقام|معلومة|غريبة/.test(s))return 'amazing_facts';
var t=_dt3(p);
if(EMOT.indexOf(t)>-1)return 'amazing_facts';
return t;
};
</script>
<!-- ====== content-v2 ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ website updated')
else:
    print('⚠️ website already done')
PYEOF

# ========== 2) الـ workflow ==========
cat > .github/workflows/content-agent.yml << 'EOF'
name: AI Content Agent

on:
  schedule:
    - cron: '0 * * * *'
  workflow_dispatch:
    inputs:
      content_type:
        description: 'نوع المحتوى'
        required: false
        default: 'random'
        type: choice
        options: [random, book_summary, article, story, facts, tips, news, philosophy, history, science, psychology, amazing_facts, ai_tech, self_dev, money, true_stories, world, simple_science, civilizations, daily]
      book_name:
        description: 'اسم الكتاب'
        required: false
        default: ''
        type: string
      custom_topic:
        description: 'موضوع مخصص'
        required: false
        default: ''
        type: string

permissions:
  contents: write

jobs:
  run-content-agent:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt

      - name: Map content topics
        id: map
        run: |
          CT="${{ github.event.inputs.content_type || 'random' }}"
          CTOPIC="${{ github.event.inputs.custom_topic || '' }}"
          case "$CT" in
            amazing_facts) CTOPIC="معلومات وحقائق مذهلة عن دول وشعوب وتاريخ وعلوم وأرقام غير معروفة"; CT="article";;
            ai_tech) CTOPIC="الذكاء الاصطناعي والتقنية: أدوات AI وشروحات ومواقع مفيدة وأخبار تقنية وطرق استخدام الذكاء الاصطناعي"; CT="article";;
            self_dev) CTOPIC="تطوير الذات والمهارات: التركيز والتعلم وإدارة الوقت والتواصل وبناء العادات"; CT="article";;
            money) CTOPIC="المال والأعمال: أفكار مشاريع والتجارة الإلكترونية والادخار والعمل الحر وقصص الشركات"; CT="article";;
            true_stories) CTOPIC="قصة حقيقية قصيرة عن أشخاص أو أحداث غريبة أو اختراعات أو نجاح وفشل أو أحداث تاريخية"; CT="article";;
            world) CTOPIC="حول العالم: دول ومدن وعادات شعوب وأماكن غريبة وقوانين غير متوقعة ومعلومات سياحية"; CT="article";;
            simple_science) CTOPIC="العلوم المبسطة: لماذا يحدث هذا؟ جسم الإنسان والحيوانات والفضاء والفيزياء بطريقة سهلة"; CT="article";;
            civilizations) CTOPIC="التاريخ والحضارات: حضارات قديمة وشخصيات تاريخية ومعارك واكتشافات وأحداث غيرت العالم"; CT="article";;
            daily) CTOPIC="محتوى يومي سريع: هل تعلم؟ أو معلومة اليوم أو رقم اليوم أو حدث في مثل هذا اليوم"; CT="article";;
            random)
              R=$((RANDOM % 3))
              if [ "$R" = "0" ]; then
                TOPICS=("معلومات وحقائق مذهلة" "الذكاء الاصطناعي والتقنية" "تطوير الذات والمهارات" "المال والأعمال" "قصة حقيقية قصيرة" "حول العالم" "العلوم المبسطة" "التاريخ والحضارات" "محتوى يومي سريع")
                CTOPIC="${TOPICS[$((RANDOM % 9))]}"
                CT="article"
              fi
              ;;
          esac
          echo "content_type=$CT" >> $GITHUB_OUTPUT
          echo "custom_topic=$CTOPIC" >> $GITHUB_OUTPUT

      - name: Run Content Agent
        id: run-agent
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
          TELEGRAM_BOT_TOKEN: ${{ secrets.TELEGRAM_BOT_TOKEN }}
          TELEGRAM_CHANNEL_ID: ${{ secrets.TELEGRAM_CHANNEL_ID }}
          CONTENT_TYPE: ${{ steps.map.outputs.content_type }}
          BOOK_NAME: ${{ github.event.inputs.book_name || '' }}
          CUSTOM_TOPIC: ${{ steps.map.outputs.custom_topic }}
        run: |
          python main.py
          echo "workflow_id=${GITHUB_RUN_ID}" >> $GITHUB_OUTPUT

      - name: Save post to JSON
        run: |
          python3 << 'PYEOF'
          import json, os, re
          from datetime import datetime

          def detect_type(title, content, tags):
              t = title + ' ' + content + ' ' + ' '.join(tags)
              if re.search(r'معلومة اليوم|رقم اليوم|حدث في مثل هذا اليوم|هل تعلم', t): return 'daily'
              if re.search(r'حضارة|حضارات|فرعون|معركة|اكتشافات', t): return 'civilizations'
              if re.search(r'جسم الإنسان|الحيوانات|لماذا يحدث|فيزياء|كيمياء|فضاء', t): return 'simple_science'
              if re.search(r'ذكاء اصطناعي|أدوات|AI|تقنية|مواقع مفيدة|تطبيق|برمج', t): return 'ai_tech'
              if re.search(r'إدارة الوقت|تركيز|تعلم|عادات|تواصل|تطوير الذات|مهارات', t): return 'self_dev'
              if re.search(r'مشروع|تجارة|ادخار|استثمار|عمل حر|مال|أعمال|شركة', t): return 'money'
              if re.search(r'حول العالم|دول|مدن|شعوب|سياحة|قوانين', t): return 'world'
              if re.search(r'قصة حقيقية|حدثت|اختراع|غريبة|شخص', t): return 'true_stories'
              if re.search(r'حقائق|مذهلة|أرقام|معلومة|غريبة', t): return 'amazing_facts'
              if re.search(r'فلسف|وجود|ماهية|أخلاقي|منطق|سقراط|أرسطو|كانط|هوية|ثيسيوس|مفارقة', t): return 'philosophy'
              if re.search(r'قصة|حكاية|رواية|بطل|حلم|استيقظ|عجوز|طفل', t): return 'story'
              if re.search(r'تاريخ|حضارة|آثار', t): return 'history'
              if re.search(r'نفس|سلوك|عادة|قلق|توتر|ثقة|عاطفي|عقلية', t): return 'psychology'
              if re.search(r'كتاب|مؤلف|ملخص|قراءة|فصل', t): return 'book_summary'
              if re.search(r'نصيح|خطوة|طريقة|مهارة|إنتاجية', t): return 'tips'
              return 'article'

          posts_file = 'docs/posts.json'
          posts = []
          if os.path.exists(posts_file):
              try:
                  with open(posts_file, 'r', encoding='utf-8') as f:
                      posts = json.load(f)
              except: posts = []

          db_path = 'data/content.db'
          title, content, topic, angle, core_idea = 'منشور جديد', 'تم إنشاء محتوى جديد', '', '', ''
          keywords, hashtags = [], []

          if os.path.exists(db_path):
              import sqlite3
              conn = sqlite3.connect(db_path)
              conn.row_factory = sqlite3.Row
              cur = conn.cursor()
              cur.execute('SELECT title, content, topic, angle, core_idea, keywords, hashtags FROM posts ORDER BY id DESC LIMIT 1')
              row = cur.fetchone()
              if row:
                  title = row['title'] or title
                  content = row['content'] or content
                  topic = row['topic'] or ''
                  angle = row['angle'] or ''
                  core_idea = row['core_idea'] or ''
                  if row['keywords'] and row['keywords'].strip():
                      try: keywords = json.loads(row['keywords'])
                      except: keywords = []
                  if row['hashtags'] and row['hashtags'].strip():
                      try: hashtags = json.loads(row['hashtags'])
                      except: hashtags = []
              conn.close()

          new_post = {
              "id": len(posts) + 1,
              "title": title,
              "content": content,
              "topic": topic,
              "angle": angle,
              "core_idea": core_idea,
              "keywords": keywords,
              "hashtags": hashtags,
              "type": detect_type(title, content, hashtags),
              "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
              "url": f"https://github.com/{os.getenv('GITHUB_REPOSITORY')}/actions/runs/{os.getenv('WORKFLOW_ID')}",
              "reading_time": max(1, len(content.split()) // 200)
          }

          posts.insert(0, new_post)
          posts = posts[:50]
          os.makedirs('docs', exist_ok=True)
          with open(posts_file, 'w', encoding='utf-8') as f:
              json.dump(posts, f, ensure_ascii=False, indent=2)

          print(f"✅ Saved. Type detected: {new_post['type']}")
          PYEOF
        env:
          WORKFLOW_ID: ${{ steps.run-agent.outputs.workflow_id }}

      - name: Commit and push posts.json
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git add docs/posts.json
          git diff --quiet && git diff --staged --quiet || (git commit -m "📝 Auto-classified post" && git push)
        continue-on-error: true

      - name: Upload database as artifact
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: content-database
          path: data/content.db
          retention-days: 7
          overwrite: true
EOF

git add -A && git commit -m "Replace emotional types with 9 new content categories" && git push
