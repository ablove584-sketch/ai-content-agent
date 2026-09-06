#!/bin/bash

# ========== 1) الموقع: تصنيفات وأيقونات وصور ==========
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'emotional-topics' not in c:
    extra = r'''
<script>
// ====== emotional-topics: 10 أنواع جديدة ======
Object.assign(TYPE_LABELS,{hope:'الأمل',life:'الحياة',friendship:'الصداقة',mother:'الأم',homeland:'الوطن',exile:'الغربة',success:'النجاح',failure:'الفشل',love:'الحب',change:'التغيير'});
Object.assign(TYPE_ICONS,{hope:'🌅',life:'🌱',friendship:'🤝',mother:'🌹',homeland:'🏡',exile:'✈️',success:'🏆',failure:'💪',love:'💞',change:'🦋'});
var U2='https://images.unsplash.com/';var Q2='?w=500&q=60&auto=format';
Object.assign(TYPE_IMAGES,{hope:U2+'photo-1470252649378-9c29740c9fa8'+Q2,life:U2+'photo-1441974231531-c6227db76b6e'+Q2,friendship:U2+'photo-1529156069898-49953e39b3ac'+Q2,mother:U2+'photo-1490750967868-88aa4486c946'+Q2,homeland:U2+'photo-1469474968028-56623f02e42e'+Q2,exile:U2+'photo-1436491865332-7a61a109cc05'+Q2,success:U2+'photo-1519681393784-d120267933ba'+Q2,failure:U2+'photo-1506744038136-46273834b3fb'+Q2,love:U2+'photo-1518199266791-5375a83190b7'+Q2,change:U2+'photo-1452570053594-1b985d6ea890'+Q2});
var _dt2=detectType;
detectType=function(p){
var t=_dt2(p);
if(t==='article'||t==='random'){
var s=((p.title||'')+' '+(p.content||'')+' '+(p.hashtags||[]).join(' '));
if(/صداقة|صديق|أصدقاء/.test(s))return 'friendship';
if(/أمي|حنان|الأم/.test(s))return 'mother';
if(/وطن|بلاد|موطن|انتماء/.test(s))return 'homeland';
if(/غربة|اغتراب|مهجر|حنين/.test(s))return 'exile';
if(/نجاح|إنجاز|طموح/.test(s))return 'success';
if(/فشل|إخفاق|تعثر/.test(s))return 'failure';
if(/حب|عشق|قلوب/.test(s))return 'love';
if(/تغيير|تحوّل|بداية جديدة/.test(s))return 'change';
if(/أمل|تفاؤل|إشراق/.test(s))return 'hope';
if(/حياة|معيشة|يومية/.test(s))return 'life';
}
return t;
};
</script>
<!-- ====== emotional-topics ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ website updated')
else:
    print('⚠️ website already done')
PYEOF

# ========== 2) الـ workflow: خيارات + توليد ==========
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
        options: [random, book_summary, article, story, facts, tips, news, philosophy, history, science, psychology, hope, life, friendship, mother, homeland, exile, success, failure, love, change]
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

      - name: Map emotional topics
        id: map
        run: |
          CT="${{ github.event.inputs.content_type || 'random' }}"
          CTOPIC="${{ github.event.inputs.custom_topic || '' }}"
          case "$CT" in
            hope) CTOPIC="الأمل"; CT="article";;
            life) CTOPIC="الحياة"; CT="article";;
            friendship) CTOPIC="الصداقة"; CT="article";;
            mother) CTOPIC="الأم"; CT="article";;
            homeland) CTOPIC="الوطن"; CT="article";;;
            exile) CTOPIC="الغربة"; CT="article";;
            success) CTOPIC="النجاح"; CT="article";;
            failure) CTOPIC="الفشل"; CT="article";;
            love) CTOPIC="الحب"; CT="article";;
            change) CTOPIC="التغيير"; CT="article";;
            random)
              R=$((RANDOM % 5))
              if [ "$R" = "0" ]; then
                TOPICS=("الأمل" "الحياة" "الصداقة" "الأم" "الوطن" "الغربة" "النجاح" "الفشل" "الحب" "التغيير")
                CTOPIC="${TOPICS[$((RANDOM % 10))]}"
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
              if re.search(r'فلسف|وجود|ماهية|أخلاقي|منطق|سقراط|أرسطو|كانط|هوية|ثيسيوس|مفارقة', t): return 'philosophy'
              if re.search(r'قصة|حكاية|رواية|بطل|حلم|استيقظ|عجوز|طفل', t): return 'story'
              if re.search(r'فيزياء|كيمياء|فضاء|كوكب|ذرة|بيولوج|دماغ|أينشتاين|نظرية|علم', t): return 'science'
              if re.search(r'تاريخ|حضارة|فرعون|رومان|أندلس|خلافة|إمبراطورية|آثار', t): return 'history'
              if re.search(r'نفس|سلوك|عادة|قلق|توتر|ثقة|عاطفي|عقلية', t): return 'psychology'
              if re.search(r'كتاب|مؤلف|ملخص|قراءة|فصل', t): return 'book_summary'
              if re.search(r'تقنية|برمج|ذكاء اصطناعي|خوارزم|بيانات|رقمي|إنترنت', t): return 'news'
              if re.search(r'نصيح|خطوة|طريقة|مهارة|إنتاجية', t): return 'tips'
              if re.search(r'حقيقة|معلومة|هل تعلم|غريب', t): return 'facts'
              if re.search(r'صداقة|صديق|أصدقاء', t): return 'friendship'
              if re.search(r'أمي|حنان|الأم', t): return 'mother'
              if re.search(r'وطن|بلاد|موطن|انتماء', t): return 'homeland'
              if re.search(r'غربة|اغتراب|مهجر|حنين', t): return 'exile'
              if re.search(r'نجاح|إنجاز|طموح', t): return 'success'
              if re.search(r'فشل|إخفاق|تعثر', t): return 'failure'
              if re.search(r'حب|عشق|قلوب', t): return 'love'
              if re.search(r'تغيير|تحوّل|بداية جديدة', t): return 'change'
              if re.search(r'أمل|تفاؤل|إشراق', t): return 'hope'
              if re.search(r'حياة|معيشة|يومية', t): return 'life'
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

git add -A && git commit -m "Add 10 emotional content types: hope, love, mother, homeland..." && git push
