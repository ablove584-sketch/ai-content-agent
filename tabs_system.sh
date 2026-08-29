#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'tabs-system' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== tabs-system: تبويبات بتطبيق أصلي ====== */
.bottom-nav{z-index:600!important}
.bn-btn.active{color:var(--primary)}
.tab-page{display:none;position:fixed;inset:0;background:var(--bg);z-index:500;flex-direction:column}
.tab-page.open{display:flex;animation:appPage .3s ease}
.reels-overlay.open{animation:appPage .3s ease}
.saved-body,.pf-body{padding-bottom:80px}
@media(max-width:768px){.reel-bottom{bottom:64px}}
</style>

<div class="tab-page" id="bellPage">
<div class="saved-top"><button class="reels-close" onclick="switchTab('home')">✕</button><span class="reels-title">🔔 الجديد</span></div>
<div class="saved-body" id="bellBody"></div>
</div>

<div class="tab-page" id="friendsPage">
<div class="saved-top"><button class="reels-close" onclick="switchTab('home')">✕</button><span class="reels-title">👥 المجتمع</span></div>
<div class="saved-body" id="friendsBody"></div>
</div>

<script>
// ====== tabs-system ======
(function(){
var map=['home','reels','friends','saved','bell','profile'];
var btns=document.querySelectorAll('#bottomNav .bn-btn');
for(var i=0;i<btns.length&&i<map.length;i++){
btns[i].setAttribute('data-tab',map[i]);
btns[i].onclick=function(){switchTab(this.getAttribute('data-tab'));};
if(map[i]==='home')btns[i].classList.add('active');
}
})();
function switchTab(t){
closeSaved();closeProfile();closeReels();closeTabPages();
var btns=document.querySelectorAll('#bottomNav .bn-btn');
for(var i=0;i<btns.length;i++)btns[i].classList.toggle('active',btns[i].getAttribute('data-tab')===t);
if(t==='home'){window.scrollTo({top:0,behavior:'smooth'});}
else if(t==='reels')openReels();
else if(t==='saved')openFavs();
else if(t==='profile')openProfile();
else if(t==='bell')openBellPage();
else if(t==='friends')openFriendsPage();
}
function closeTabPages(){
['bellPage','friendsPage'].forEach(function(id){var e=document.getElementById(id);if(e)e.classList.remove('open');});
}
function openBellPage(){
var fresh=allPosts.filter(function(p){try{var d=new Date(String(p.date).replace(' ','T'));return (Date.now()-d.getTime())/3600000<24;}catch(e){return false;}});
var b=document.getElementById('bellBody');
if(!fresh.length){
b.innerHTML='<div class="saved-empty"><div class="big">🔔</div><div class="t">لا جديد اليوم</div>عد لاحقاً - الوكيل ينشر تلقائياً كل ساعة</div>';
}else{
b.innerHTML='<div class="saved-feed"></div>';
var feed=b.firstChild;var old=window._featDone;window._featDone=true;
for(var i=0;i<fresh.length;i++)feed.appendChild(makeCard(fresh[i]));
window._featDone=old;
}
document.getElementById('bellPage').classList.add('open');
document.body.style.overflow='hidden';
}
function openFriendsPage(){
var all=[];allPosts.forEach(function(p){getComments(p.id).forEach(function(x){all.push({x:x,pid:p.id,pt:p.title});});});
var top=allPosts.slice().sort(function(a,b){return getComments(b.id).length-getComments(a.id).length;}).slice(0,5);
var b=document.getElementById('friendsBody');
var html='<div style="padding:15px"><h3 class="wtitle">💬 آخر التعليقات</h3>';
if(!all.length)html+='<p style="color:var(--muted);text-align:center;padding:20px">كن أول من يعلّق!</p>';
else html+=all.slice(0,10).map(function(o){return '<div class="citem" style="cursor:pointer;margin-bottom:8px" onclick="switchTab(\'home\');openPost('+o.pid+')"><div class="cname">'+o.x.name+'</div><div class="ctext">'+o.x.text+'</div><div class="cdate">على: '+o.pt+'</div></div>';}).join('');
html+='<h3 class="wtitle" style="margin-top:20px">🗣️ الأكثر نقاشاً</h3>'+top.map(function(p){return '<div class="rel-card" onclick="switchTab(\'home\');openPost('+p.id+')"><strong>'+(p.title||'')+'</strong><div style="font-size:12px;color:var(--muted)">💬 '+getComments(p.id).length+'</div></div>';}).join('')+'</div>';
b.innerHTML=html;
document.getElementById('friendsPage').classList.add('open');
document.body.style.overflow='hidden';
}
document.addEventListener('keydown',function(e){if(e.key==='Escape')switchTab('home');});
</script>
<!-- ====== tabs-system ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ tabs system applied')
PYEOF

git add -A && git commit -m "App-style tab navigation with smooth animations" && git push
