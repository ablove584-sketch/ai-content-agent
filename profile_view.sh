#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'profile-view' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== profile-view ====== */
.profile-overlay{display:none;position:fixed;inset:0;background:var(--bg);z-index:500;flex-direction:column}
.profile-overlay.open{display:flex;animation:appPage .3s ease}
.pf-top{display:flex;justify-content:space-between;align-items:center;padding:10px 15px;background:var(--card);border-bottom:1px solid var(--border)}
.pf-top .reels-title{color:var(--text)}
.pf-body{flex:1;overflow-y:auto}
.pf-head{text-align:center;padding:20px 15px 10px}
.pf-av{width:96px;height:96px;border-radius:50%;margin:0 auto 10px;display:flex;align-items:center;justify-content:center;font-size:44px;background:linear-gradient(135deg,#667eea,#764ba2);box-shadow:0 0 0 3px var(--card),0 0 0 6px #dc2743}
.pf-handle{color:var(--muted);font-size:13px;letter-spacing:1px;font-weight:700}
.pf-name{font-weight:800;font-size:20px}
.pf-stats{display:flex;justify-content:center;gap:30px;margin:15px 0}
.pf-stat b{display:block;font-size:17px}
.pf-stat span{color:var(--muted);font-size:12px}
.pf-bio{font-size:14px;line-height:1.8;white-space:pre-wrap}
.pf-badge{display:inline-flex;align-items:center;gap:6px;background:var(--card);border:1px solid var(--border);padding:4px 14px;border-radius:15px;font-size:12px;color:var(--muted);margin-top:8px}
.pf-actions{display:flex;justify-content:center;gap:10px;margin:15px 0}
.pf-btn{flex:0 1 150px;padding:10px;border-radius:10px;border:1px solid var(--border);background:var(--card);color:var(--text);cursor:pointer;font-weight:700;font-size:14px}
.pf-links{margin:10px 15px;background:var(--card);border-radius:12px;padding:12px;border:1px solid var(--border)}
.pf-link{display:flex;align-items:center;gap:8px;padding:8px 0;color:var(--text);font-size:14px;cursor:pointer}
.pf-tabs{display:flex;border-bottom:1px solid var(--border);background:var(--card);position:sticky;top:0;z-index:5}
.pf-tab{flex:1;padding:12px;text-align:center;cursor:pointer;color:var(--muted);font-size:18px;border-bottom:2px solid transparent}
.pf-tab.active{color:var(--text);border-bottom-color:var(--primary)}
.pf-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:4px;padding:4px}
</style>

<div class="profile-overlay" id="profileOverlay">
<div class="pf-top">
<span class="reels-title">👤 الملف الشخصي</span>
<div style="display:flex;gap:8px">
<button class="reels-close" onclick="openEditProfile()">✏️</button>
<button class="reels-close" onclick="closeProfile()">✕</button>
</div>
</div>
<div class="pf-body" id="pfBody"></div>
</div>

<script>
// ====== profile logic =====
function totalLikes(){var t=0;allPosts.forEach(function(p){t+=getLikes(p.id);});return t;}
function pfData(){
return{
name:lsGet('pfName2','Al Kinani'),
handle:'@ALKINANI',
bio:lsGet('pfBio','🎙️ | صانع محتوى | 🎙️\nقصص ، توعية ، مشاعر ، واقع'),
followers:1000+totalLikes(),
following:0,
posts:allPosts.length
};}
function openProfile(){
var d=pfData();
var b=document.getElementById('pfBody');
b.innerHTML='<div class="pf-head">'+
'<div class="pf-av">🤖</div>'+
'<div class="pf-handle">'+d.handle+'</div>'+
'<div class="pf-name">'+d.name+'</div>'+
'<div class="pf-stats">'+
'<div class="pf-stat"><b>'+fmtNum(d.followers)+'</b><span>المتابعون</span></div>'+
'<div class="pf-stat"><b>'+d.following.toLocaleString('ar-EG')+'</b><span>يتابع</span></div>'+
'<div class="pf-stat"><b>'+d.posts.toLocaleString('ar-EG')+'</b><span>منشورات</span></div>'+
'</div>'+
'<div class="pf-bio">'+d.bio+'</div>'+
'<div class="pf-badge">📌 شخصية عامة</div>'+
'<div class="pf-actions">'+
'<button class="pf-btn" onclick="closeProfile();openReels()">🎬 ريلز</button>'+
'<button class="pf-btn" onclick="closeProfile();openFavs()">🔖 المحفوظات</button>'+
'</div>'+
'<div class="pf-links"><div style="font-weight:700;margin-bottom:6px">الروابط</div>'+
'<div class="pf-link" onclick="shareTo(\'telegram\')">🔗 مشاركة عبر تيليجرام</div>'+
'<div class="pf-link" onclick="closeProfile()">🌐 العودة للرئيسية</div>'+
'</div>'+
'<div class="pf-tabs">'+
'<div class="pf-tab active" data-tab="posts" onclick="pfTab(\'posts\')">📄</div>'+
'<div class="pf-tab" data-tab="saved" onclick="pfTab(\'saved\')">🔖</div>'+
'<div class="pf-tab" data-tab="liked" onclick="pfTab(\'liked\')">❤️</div>'+
'</div>'+
'<div id="pfGridWrap"></div>';
pfTab('posts');
document.getElementById('profileOverlay').classList.add('open');
document.body.style.overflow='hidden';
}
function pfTab(t){
var tabs=document.querySelectorAll('.pf-tab');
for(var i=0;i<tabs.length;i++)tabs[i].classList.toggle('active',tabs[i].getAttribute('data-tab')===t);
var wrap=document.getElementById('pfGridWrap');
var list=[];
if(t==='posts')list=allPosts;
else if(t==='saved'){var f=[];try{f=JSON.parse(lsGet('favs','[]'));}catch(e){}list=allPosts.filter(function(p){return f.indexOf(p.id)>-1;});}
else list=allPosts.filter(function(p){return isLiked(p.id);});
if(!list.length){wrap.innerHTML='<div style="text-align:center;color:var(--muted);padding:60px 20px">لا يوجد محتوى هنا بعد</div>';return;}
var h='<div class="pf-grid">';
for(var i=0;i<list.length;i++){
var p=list[i];
var img=(typeof postImage==='function')?postImage(p):(TYPE_IMAGES[p.type]||TYPE_IMAGES.random);
h+='<div class="fav-item" onclick="closeProfile();openPost('+p.id+')"><img src="'+img+'" alt="" loading="lazy"><div class="fav-t">👁️ '+fmtNum(getViews(p.id))+'</div></div>';
}
h+='</div>';
wrap.innerHTML=h;
}
function closeProfile(){document.getElementById('profileOverlay').classList.remove('open');document.body.style.overflow='';}
function openEditProfile(){
var d=pfData();
var b=document.getElementById('bottomBody');
b.innerHTML='<h3 class="wtitle">✏️ تعديل الملف الشخصي</h3>'+
'<input id="edName" class="search" style="margin-bottom:10px" placeholder="الاسم" value="'+d.name+'">'+
'<textarea id="edBio" class="search" style="margin-bottom:10px;height:90px" placeholder="النبذة">'+d.bio+'</textarea>'+
'<button class="abtn" onclick="saveProfileEdit()">💾 حفظ</button>';
openBottom();
}
function saveProfileEdit(){
lsSet('pfName2',document.getElementById('edName').value.trim()||'Al Kinani');
lsSet('pfBio',document.getElementById('edBio').value);
closeBottom();closeProfile();openProfile();toast('✅ تم حفظ الملف');
}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeProfile();});
</script>
<!-- ====== profile-view ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ profile view applied')
PYEOF

git add -A && git commit -m "Full profile page like TikTok/Instagram" && git push
