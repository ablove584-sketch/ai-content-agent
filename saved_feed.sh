#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'saved-feed' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== saved-feed: المحفوظات كصفحة تطبيق ====== */
.saved-feed{max-width:520px;margin:0 auto;display:flex;flex-direction:column;gap:15px;padding:12px}
.saved-overlay.open{animation:appPage .3s ease}
@keyframes appPage{from{transform:translateY(40px);opacity:0}to{transform:translateY(0);opacity:1}}
.saved-empty{text-align:center;color:var(--muted);padding:80px 20px;line-height:2.2}
.saved-empty .big{font-size:70px}
.saved-empty .t{font-weight:700;font-size:17px;color:var(--text)}
</style>
<script>
// المحفوظات بنفس بطاقات الصفحة الرئيسية
function openFavs(){
var favs=[];try{favs=JSON.parse(lsGet('favs','[]'));}catch(e){}
lsSet('favsSeen',favs.length);
if(typeof updateNavBadges==='function')updateNavBadges();
var body=document.getElementById('savedBody');
var cnt=document.getElementById('savedCount');
if(cnt)cnt.textContent=favs.length?('('+favs.length.toLocaleString('ar-EG')+')'):'';
if(!favs.length){
body.innerHTML='<div class="saved-empty"><div class="big">🔖</div><div class="t">لا توجد محفوظات بعد</div>اضغط على علامة الحفظ في أي منشور<br>وسيظهر هنا فوراً</div>';
}else{
body.innerHTML='<div class="saved-feed" id="savedFeed"></div>';
var feed=document.getElementById('savedFeed');
var oldFeat=window._featDone;
window._featDone=true; // كل البطاقات بنفس المقاس
for(var i=0;i<favs.length;i++){
var p=null;
for(var j=0;j<allPosts.length;j++){if(allPosts[j].id===favs[i]){p=allPosts[j];break;}}
if(p)feed.appendChild(makeCard(p));
}
window._featDone=oldFeat;
}
document.getElementById('savedOverlay').classList.add('open');
document.body.style.overflow='hidden';
}
</script>
<!-- ====== saved-feed ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ saved feed applied')
PYEOF

git add -A && git commit -m "Saved page with full Instagram-style cards" && git push
