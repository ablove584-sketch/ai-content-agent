#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-feat-text' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== mobile-feat-text: المميز نص قصير بالجوال ======
var _mk6=makeCard;
makeCard=function(p){var d=_mk6(p);
if(window.matchMedia('(max-width:768px)').matches&&d.classList.contains('featured')){
var content=p.content||'';
var prev=content.length>90?content.substring(0,90)+'... ':content;
var cap=d.querySelector('.i-cap');
if(cap){
var tags=(p.hashtags||[]).slice(0,4);
cap.innerHTML='<span class="i-name">alkinani</span> ✨ <strong style="color:var(--text)">'+(p.title||'')+'</strong> '+prev+(content.length>90?'<button class="i-more" onclick="openPost('+p.id+')">... المزيد</button>':'')+(tags.length?'<div class="i-tags">'+tags.map(function(t){return '<span>'+t+'</span>';}).join('')+'</div>':'');
}
}
return d;};
</script>
<!-- ====== mobile-feat-text ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ mobile featured text shortened')
PYEOF

git add -A && git commit -m "Featured post short text on mobile like others" && git push
