#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()

# 1. تخفيف حجم كل الصور (تحميل أسرع)
c = c.replace('?w=600&q=70&auto=format', '?w=500&q=60&auto=format')

if 'speed-fix' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== speed-fix: خلفية أنيقة أثناء تحميل الصور ====== */
.i-img{background:linear-gradient(135deg,#2a2a45,#151528)}
.i-img img{opacity:0;transition:opacity .5s}
.i-img img.loaded{opacity:1}
</style>
<script>
// ظهور تدريجي للصور عند اكتمال التحميل
document.addEventListener('load',function(e){var t=e.target;if(t&&t.tagName==='IMG')t.classList.add('loaded');},true);
document.addEventListener('error',function(e){var t=e.target;if(t&&t.tagName==='IMG')t.classList.add('loaded');},true);
// ضمان وجود المنشور المميز دائماً + أولوية تحميل لصورته
var _pf=placeFeatured;
placeFeatured=function(){
var cont=document.getElementById('postsContainer');
if(cont&&!cont.querySelector('.insta-card.featured')){
var first=cont.querySelector('.insta-card');
if(first){first.classList.add('featured');first.classList.remove('grid-card');}
}
_pf();
var row=document.getElementById('featuredRow');
if(row){var f=row.querySelector('.insta-card.featured');
if(f){var im=f.querySelector('img');if(im){im.loading='eager';try{im.fetchPriority='high';}catch(e){}}}}
};
</script>
<!-- ====== speed-fix ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    print('✅ speed fix added')

with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
PYEOF

git add -A && git commit -m "Faster images + guaranteed featured post" && git push
