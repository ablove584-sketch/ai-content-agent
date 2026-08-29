#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'feat-text' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== feat-text: نص أكبر للمميز ====== */
.insta-card.featured .i-cap{font-size:15px!important;line-height:1.9!important;height:auto!important}
.insta-card.featured .i-title{font-size:19px!important;height:auto!important}
.insta-card.featured .i-tags{margin-top:8px}
</style>
<script>
// المنشور المميز يعرض نصاً أطول ليملأ المساحة
var _mk5=makeCard;
makeCard=function(p){var d=_mk5(p);
if(d.classList.contains('featured')){
var content=p.content||'';
var prev=content.length>500?content.substring(0,500)+'... ':content;
var cap=d.querySelector('.i-cap');
if(cap){
var tags=(p.hashtags||[]).slice(0,6);
cap.innerHTML='<span class="i-name">alkinani</span> ✨ <strong style="color:var(--text)">'+(p.title||'')+'</strong> '+prev+(content.length>500?'<button class="i-more" onclick="openPost('+p.id+')">... المزيد</button>':'')+(tags.length?'<div class="i-tags">'+tags.map(function(t){return '<span>'+t+'</span>';}).join('')+'</div>':'');
}
}
return d;};
</script>
<!-- ====== feat-text ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ featured text expanded')
PYEOF

git add -A && git commit -m "Featured post shows longer text to fill space" && git push
