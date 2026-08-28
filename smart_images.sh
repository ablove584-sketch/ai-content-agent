#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'IMG_POOLS' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ========== SMART IMAGES ==========
var U='https://images.unsplash.com/';
var Q='?w=600&q=70&auto=format';
var IMG_POOLS={
ship:[U+'photo-1493962853295-0fd70327578a'+Q,U+'photo-1505142468610-359e7d316be0'+Q,U+'photo-1500375592092-40eb2168fd21'+Q],
brain:[U+'photo-1559757148-5c350d0d3c56'+Q,U+'photo-1499209974431-9dddcece7f88'+Q,U+'photo-1507003211169-0a1dd7228f2d'+Q],
tech:[U+'photo-1485827404703-89b55fcc595e'+Q,U+'photo-1518770660439-4636190af4f3'+Q,U+'photo-1526374965328-7f61d4dc18c5'+Q,U+'photo-1451187580459-43490279c0fa'+Q],
space:[U+'photo-1462331940025-496dfbfc7564'+Q,U+'photo-1446776811953-b23d57bd21aa'+Q,U+'photo-1444703686981-a3abbc4d2fe3'+Q,U+'photo-1519681393784-d120267933ba'+Q],
book:[U+'photo-1512820790803-83ca734da794'+Q,U+'photo-1481627834876-b7833e8f5570'+Q,U+'photo-1457369804613-52c61a468e7d'+Q,U+'photo-1456513080510-7bf3a84b82f8'+Q],
history:[U+'photo-1461360370896-922624d12aa1'+Q,U+'photo-1529699211952-734e80c4d42b'+Q],
science:[U+'photo-1532094349884-543bc11b234d'+Q,U+'photo-1451187580459-43490279c0fa'+Q],
nature:[U+'photo-1470071459604-3b5ec3a7fe05'+Q,U+'photo-1441974231531-c6227db76b6e'+Q,U+'photo-1506744038136-46273834b3fb'+Q],
work:[U+'photo-1499750310107-5fef28a66643'+Q,U+'photo-1488998427799-e3362cec87c3'+Q,U+'photo-1455390582262-044cdead277a'+Q,U+'photo-1512314889357-e157c22f938d'+Q]
};
var GENERAL=[].concat(IMG_POOLS.tech,IMG_POOLS.book,IMG_POOLS.nature,IMG_POOLS.space,IMG_POOLS.brain,IMG_POOLS.work);
function postImage(p){
var t=((p.title||'')+' '+(p.content||'')+' '+(p.hashtags||[]).join(' ')+' '+(p.keywords||[]).join(' '));
var pool=null;
if(/سفينة|بحر|محيط|موج|ماء|شاطئ/.test(t))pool=IMG_POOLS.ship;
else if(/فضاء|كوكب|نجم|مجرة|قمر|كون/.test(t))pool=IMG_POOLS.space;
else if(/دماغ|عقل|ذاكرة|وعي|أعصاب|نفس|سلوك/.test(t))pool=IMG_POOLS.brain;
else if(/كتاب|قراءة|مكتبة|مؤلف|رواية|ملخص/.test(t))pool=IMG_POOLS.book;
else if(/تاريخ|حضارة|أثر|فرعون|معركة|إمبراطور|فلسف|وجود|هوية|مفارقة/.test(t))pool=IMG_POOLS.history;
else if(/روبوت|ذكاء اصطناعي|خوارزم|بيانات|رقمي|إنترنت|هاتف|حاسوب|تقنية/.test(t))pool=IMG_POOLS.tech;
else if(/فيزياء|كيمياء|مختبر|تجربة|علم|نظرية/.test(t))pool=IMG_POOLS.science;
else if(/طبيعة|جبل|غابة|صحراء|نهر|سماء/.test(t))pool=IMG_POOLS.nature;
else if(/عمل|نجاح|إنتاج|مهارة|عادة|وقت|نصيح/.test(t))pool=IMG_POOLS.work;
if(!pool)pool=GENERAL;
return pool[(p.id||0)%pool.length];
}
var _mi=makeCard;
makeCard=function(p){var d=_mi(p);var im=d.querySelector('.i-img img');if(im){im.src=postImage(p);im.onerror=function(){im.src=GENERAL[(p.id||0)%GENERAL.length];im.onerror=null;};}return d;};
var _oi=openPost;
openPost=function(id){_oi(id);var p=null;for(var i=0;i<allPosts.length;i++)if(allPosts[i].id===id){p=allPosts[i];break;}if(p)$('mImg').src=postImage(p);};
</script>
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ Smart images applied')
PYEOF

git add -A && git commit -m "Smart per-post images by content keywords" && git push
