#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-nav' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-nav: شريط سفلي للجوال فقط ====== */
.bottom-nav{display:none;position:fixed;bottom:0;left:0;right:0;background:var(--card);z-index:300;border-top:1px solid var(--border);padding:8px 0 calc(8px + env(safe-area-inset-bottom));box-shadow:0 -3px 15px rgba(0,0,0,.15)}
@media(max-width:768px){
.bottom-nav{display:flex;justify-content:space-around;align-items:center}
body{padding-bottom:70px}
.back-top{bottom:80px}
}
.bn-btn{position:relative;background:none;border:none;color:var(--text);cursor:pointer;padding:6px 12px;transition:transform .2s}
.bn-btn:active{transform:scale(.85)}
.bn-btn svg{width:26px;height:26px}
.bn-badge{position:absolute;top:0;right:4px;background:#ed4956;color:#fff;font-size:10px;font-weight:700;min-width:16px;height:16px;border-radius:8px;display:flex;align-items:center;justify-content:center;padding:0 4px}
</style>

<nav class="bottom-nav" id="bottomNav">
<button class="bn-btn" onclick="window.scrollTo({top:0,behavior:'smooth'})" title="الرئيسية"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 3l9 7.5V21h-6v-6H9v6H3V10.5z"/></svg></button>
<button class="bn-btn" onclick="openTopPost()" title="الأبرز"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="8" width="18" height="12" rx="2"/><path d="M7 8l2-4"/><path d="M12 8l2-4"/><path d="M17 8l2-4"/><path d="M10 12l5 3-5 3z"/></svg></button>
<button class="bn-btn" onclick="openCommentsAll()" title="التعليقات"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3"/><path d="M3.5 19a5.5 5.5 0 0 1 11 0"/><circle cx="17" cy="9" r="2.5"/><path d="M15.5 14.5a4.5 4.5 0 0 1 5.5 4.5"/></svg></button>
<button class="bn-btn" onclick="openFavs()" title="المفضلة"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 4h16l1 5a2.5 2.5 0 0 1-4.5 1.5A2.5 2.5 0 0 1 12 10.5 2.5 2.5 0 0 1 7.5 10.5 2.5 2.5 0 0 1 3 9z"/><path d="M5 12v8h14v-8"/><path d="M9 20v-5h6v5"/></svg><span class="bn-badge" id="bnFav" style="display:none">0</span></button>
<button class="bn-btn" onclick="bellTap()" title="الجديد"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8a6 6 0 0 0-12 0c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.7 21a2 2 0 0 1-3.4 0"/></svg><span class="bn-badge" id="bnBell" style="display:none">0</span></button>
<button class="bn-btn" onclick="openProfile()" title="حسابي"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><circle cx="12" cy="10" r="3"/><path d="M6.5 18.5a5.5 5.5 0 0 1 11 0"/></svg></button>
</nav>

<div class="modal" id="bottomModal">
<div class="m-box" style="max-width:500px;margin:15px auto">
<button class="m-close" onclick="closeBottom()">✕</button>
<div class="m-body" id="bottomBody"></div>
</div>
</div>

<script>
// ====== mobile-nav logic =====
function openBottom(){$('bottomModal').classList.add('open');document.body.style.overflow='hidden';}
function closeBottom(){$('bottomModal').classList.remove('open');document.body.style.overflow='';}
$('bottomModal').addEventListener('click',function(e){if(e.target.id==='bottomModal')closeBottom();});
function updateNavBadges(){
var today=0;allPosts.forEach(function(p){try{var d=new Date(String(p.date).replace(' ','T'));if((Date.now()-d.getTime())/3600000<24)today++;}catch(e){}});
var nb=document.getElementById('bnBell');if(nb){nb.textContent=today;nb.style.display=today>0?'flex':'none';}
var favs=[];try{favs=JSON.parse(lsGet('favs','[]'));}catch(e){}
var fb=document.getElementById('bnFav');if(fb){fb.textContent=favs.length;fb.style.display=favs.length>0?'flex':'none';}
}
var _ra2=renderAll;
renderAll=function(){_ra2();updateNavBadges();};
function bellTap(){
var today=0;allPosts.forEach(function(p){try{var d=new Date(String(p.date).replace(' ','T'));if((Date.now()-d.getTime())/3600000<24)today++;}catch(e){}});
toast('🔔 '+today.toLocaleString('ar-EG')+' منشورات جديدة اليوم');
document.getElementById('postsContainer').scrollIntoView({behavior:'smooth'});
}
function openTopPost(){
if(!allPosts.length)return;
var top=allPosts.slice().sort(function(a,b){return getViews(b.id)-getViews(a.id);})[0];
openPost(top.id);
}
function openFavs(){
var favs=[];try{favs=JSON.parse(lsGet('favs','[]'));}catch(e){}
var b=document.getElementById('bottomBody');
if(!favs.length){b.innerHTML='<h3 class="wtitle">🔖 المفضلة</h3><p style="color:var(--muted);text-align:center;padding:20px">لا توجد منشورات محفوظة</p>';}
else{b.innerHTML='<h3 class="wtitle">🔖 المفضلة ('+favs.length+')</h3>'+favs.map(function(id){var p=null;for(var i=0;i<allPosts.length;i++)if(allPosts[i].id===id)p=allPosts[i];return p?'<div class="rel-card" onclick="closeBottom();openPost('+p.id+')"><strong>'+(p.title||'')+'</strong></div>':'';}).join('');}
openBottom();
}
function openCommentsAll(){
var all=[];allPosts.forEach(function(p){getComments(p.id).forEach(function(x){all.push({x:x,pid:p.id});});});
var b=document.getElementById('bottomBody');
if(!all.length){b.innerHTML='<h3 class="wtitle">💬 التعليقات</h3><p style="color:var(--muted);text-align:center;padding:20px">كن أول من يعلّق!</p>';}
else{b.innerHTML='<h3 class="wtitle">💬 آخر التعليقات</h3>'+all.slice(0,10).map(function(o){return '<div class="citem" style="cursor:pointer" onclick="closeBottom();openPost('+o.pid+')"><div class="cname">'+o.x.name+'</div><div class="ctext">'+o.x.text+'</div></div>';}).join('');}
openBottom();
}
function openProfile(){
var favs=[];try{favs=JSON.parse(lsGet('favs','[]'));}catch(e){}
var my=0;allPosts.forEach(function(p){getComments(p.id).forEach(function(x){if(x.name===lsGet('userName',''))my++;});});
var tv=0;allPosts.forEach(function(p){tv+=getViews(p.id);});
var b=document.getElementById('bottomBody');
b.innerHTML='<h3 class="wtitle">👤 الملف الشخصي</h3>'+
'<input id="pfName" class="search" style="margin-bottom:12px" placeholder="اسمك" value="'+lsGet('userName','')+'">'+
'<ul class="wlist"><li>🔖 المحفوظات: <strong>'+favs.length+'</strong></li><li>💬 تعليقاتك: <strong>'+my+'</strong></li><li>👁️ مشاهدات الموقع: <strong>'+tv+'</strong></li><li>📚 المنشورات: <strong>'+allPosts.length+'</strong></li></ul>'+
'<button class="nform" style="width:100%;padding:10px;background:var(--grad);color:#fff;border:none;border-radius:8px;cursor:pointer;font-weight:600" onclick="saveProfile()">حفظ الاسم</button>';
openBottom();
}
function saveProfile(){lsSet('userName',document.getElementById('pfName').value.trim()||'زائر');toast('✅ تم الحفظ');closeBottom();}
</script>
<!-- ====== mobile-nav ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ mobile bottom nav added')
PYEOF

git add -A && git commit -m "Mobile-only fixed bottom navigation bar" && git push
