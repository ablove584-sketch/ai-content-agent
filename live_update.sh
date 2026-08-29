#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'live-update' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== live-update: إشعار المنشورات الجديدة ====== */
.new-pill{display:none;position:fixed;top:calc(75px + env(safe-area-inset-top));left:50%;transform:translateX(-50%);z-index:450;background:linear-gradient(135deg,#667eea,#764ba2);color:#fff;border:none;padding:10px 24px;border-radius:25px;font-weight:700;font-size:13px;box-shadow:0 5px 20px rgba(102,126,234,.5);cursor:pointer;animation:appPage .3s ease}
</style>
<script>
// ====== live-update: بث المنشورات الجديدة ======
var _checking=false;
function checkNewPosts(){
if(_checking)return;_checking=true;
fetch('posts.json?t='+Date.now()).then(function(r){if(!r.ok)throw 0;return r.json();}).then(function(server){
_checking=false;
if(!server||!server.length)return;
var known={};allPosts.forEach(function(p){known[p.id]=1;});
var fresh=server.filter(function(p){return !known[p.id];});
if(!fresh.length)return;
window._serverPosts=server;
if(window.scrollY<300){applyNew();}
else{showNewPill(fresh.length);}
}).catch(function(){_checking=false;});
}
function applyNew(){
if(window._serverPosts){allPosts=window._serverPosts;window._serverPosts=null;}
lsSet('postsCache',JSON.stringify(allPosts));
hideNewPill();
renderAll();
window.scrollTo({top:0,behavior:'smooth'});
toast('🆕 وصل منشور جديد!');
}
function showNewPill(n){
var p=document.getElementById('newPill');
if(!p){p=document.createElement('button');p.id='newPill';p.className='new-pill';p.onclick=applyNew;document.body.appendChild(p);}
p.textContent='⬆️ '+n.toLocaleString('ar-EG')+' منشور جديد';
p.style.display='block';
}
function hideNewPill(){var p=document.getElementById('newPill');if(p)p.style.display='none';}
// فحص كل 45 ثانية + عند العودة للتطبيق
setInterval(checkNewPosts,45000);
document.addEventListener('visibilitychange',function(){if(!document.hidden)checkNewPosts();});
setTimeout(checkNewPosts,5000);
</script>
<!-- ====== live-update ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ live update applied')
PYEOF

git add -A && git commit -m "Live updates: new posts appear without reopening" && git push
