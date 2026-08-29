#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'scroll-fix' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== scroll-fix: المميز لا يتأثر بالتمرير ======
var _rp6=renderPosts;
renderPosts=function(reset){window._isReset=!!reset;_rp6(reset);};
var _pf2=placeFeatured;
placeFeatured=function(){if(!window._isReset)return;_pf2();window._isReset=false;};
// ضمان ظهور الصور المخزنة مؤقتاً (لا تبقى شفافة)
function fixLoadedImgs(){
var imgs=document.querySelectorAll('.i-img img');
for(var i=0;i<imgs.length;i++){
if(imgs[i].complete&&imgs[i].naturalWidth>0)imgs[i].classList.add('loaded');
}
}
setInterval(fixLoadedImgs,1000);
fixLoadedImgs();
</script>
<!-- ====== scroll-fix ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ scroll fix applied')
PYEOF

git add -A && git commit -m "Keep featured post stable during infinite scroll" && git push
