#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'saved-view' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== saved-view: شاشة المحفوظات الكاملة ====== */
.saved-overlay{display:none;position:fixed;inset:0;background:var(--bg);z-index:500;flex-direction:column}
.saved-overlay.open{display:flex}
.saved-top{display:flex;align-items:center;gap:10px;padding:12px 15px;background:var(--card);border-bottom:1px solid var(--border)}
.saved-top .reels-title{color:var(--text)}
.saved-body{flex:1;overflow-y:auto;padding:10px}
.saved-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px}
@media(max-width:768px){.saved-top .reels-close{color:var(--text);background:var(--bg)}}
</style>

<div class="saved-overlay" id="savedOverlay">
<div class="saved-top">
<button class="reels-close" onclick="closeSaved()">✕</button>
<span class="reels-title">🔖 المحفوظات</span>
<span id="savedCount" style="color:var(--muted);font-size:13px"></span>
</div>
<div class="saved-body" id="savedBody"></div>
</div>

<script>
// 1) تحويل أيقونة المتجر إلى 🔖
(function(){
var btns=document.querySelectorAll('#bottomNav .bn-btn');
for(var i=0;i<btns.length;i++){
if((btns[i].getAttribute('onclick')||'').indexOf('openFavs')>-1){
btns[i].innerHTML='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg><span class="bn-badge" id="bnFav" style="display:none">0</span>';
btns[i].title='المحفوظات';
}
}
})();
// 2) العداد يظهر فقط للجديد منذ آخر زيارة
function updateNavBadges(){
var today=0;allPosts.forEach(function(p){try{var d=new Date(String(p.date).replace(' ','T'));if((Date.now()-d.getTime())/3600000<24)today++;}catch(e){}});
var nb=document.getElementById('bnBell');if(nb){nb.textContent=today;nb.style.display=today>0?'flex':'none';}
var favs=[];try{favs=JSON.parse(lsGet('favs','[]'));}catch(e){}
var seen=parseInt(lsGet('favsSeen','0'),10)||0;
var unseen=Math.max(0,favs.length-seen);
var fb=document.getElementById('bnFav');if(fb){fb.textContent=unseen;fb.style.display=unseen>0?'flex':'none';}
}
// 3) شاشة المحفوظات الكاملة + إخفاء الرقم عند الفتح
function openFavs(){
var favs=[];try{favs=JSON.parse(lsGet('favs','[]'));}catch(e){}
lsSet('favsSeen',favs.length);
updateNavBadges();
var body=document.getElementById('savedBody');
document.getElementById('savedCount').textContent=favs.length?('('+favs.length.toLocaleString('ar-EG')+')'):'';
if(!favs.length){
body.innerHTML='<div style="text-align:center;color:var(--muted);padding:70px 20px;line-height:2.2"><div style="font-size:70px">🔖</div><div style="font-weight:700;font-size:17px;color:var(--text)">لا توجد محفوظات بعد</div>اضغط على علامة الحفظ في أي منشور<br>وسيظهر هنا فوراً</div>';
}else{
var items='';
for(var i=0;i<favs.length;i++){
var p=null;
for(var j=0;j<allPosts.length;j++){if(allPosts[j].id===favs[i]){p=allPosts[j];break;}}
if(p){
var img=(typeof postImage==='function')?postImage(p):(TYPE_IMAGES[p.type]||TYPE_IMAGES.random);
items+='<div class="fav-item" onclick="closeSaved();openPost('+p.id+')"><img src="'+img+'" alt="" loading="lazy"><div class="fav-t">'+(p.title||'')+'</div></div>';
}
}
body.innerHTML='<div class="saved-grid">'+items+'</div>';
}
document.getElementById('savedOverlay').classList.add('open');
document.body.style.overflow='hidden';
}
function closeSaved(){
document.getElementById('savedOverlay').classList.remove('open');
document.body.style.overflow='';
}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeSaved();});
</script>
<!-- ====== saved-view ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ saved view applied')
PYEOF

git add -A && git commit -m "Saved button replaces shop + full-screen saved page" && git push
