#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html', 'r', encoding='utf-8') as f:
    c = f.read()

if 'detectType' in c:
    print('⚠️ already patched')
else:
    detector = '''
function detectType(p){
if(p.type && p.type!=='random') return p.type;
var t=((p.title||'')+' '+(p.content||'')+' '+(p.hashtags||[]).join(' ')+' '+(p.keywords||[]).join(' '));
if(/فلسف|وجود|ماهية|أخلاقي|منطق|سقراط|أرسطو|كانط|هوية|ثيسيوس|مفارقة/.test(t))return 'philosophy';
if(/قصة|حكاية|رواية|بطل|حلم|استيقظ|عجوز|طفل/.test(t))return 'story';
if(/فيزياء|كيمياء|فضاء|كوكب|ذرة|بيولوج|دماغ|أينشتاين|نظرية|علم/.test(t))return 'science';
if(/تاريخ|حضارة|فرعون|رومان|أندلس|خلافة|إمبراطورية|آثار/.test(t))return 'history';
if(/نفس|سلوك|عادة|قلق|توتر|ثقة|عاطفي|عقلية/.test(t))return 'psychology';
if(/كتاب|مؤلف|ملخص|قراءة|فصل/.test(t))return 'book_summary';
if(/تقنية|برمج|ذكاء اصطناعي|خوارزم|بيانات|رقمي|إنترنت/.test(t))return 'news';
if(/نصيح|خطوة|طريقة|مهارة|إنتاجية/.test(t))return 'tips';
if(/حقيقة|معلومة|هل تعلم|غريب/.test(t))return 'facts';
return 'article';
}
'''
    c = c.replace('function renderAll(){', detector + '\nfunction renderAll(){allPosts.forEach(function(p){p.type=detectType(p);});', 1)
    with open('docs/index.html', 'w', encoding='utf-8') as f:
        f.write(c)
    print('✅ Page classifier added')
PYEOF

git add -A && git commit -m "Auto-classify posts by content keywords" && git push
