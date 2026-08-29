#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'fix-tabs' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== fix-tabs: ربط قوي لأزرار التنقل ======
(function(){
var map=['home','reels','friends','saved','bell','profile'];
function bind(){
var btns=document.querySelectorAll('#bottomNav .bn-btn');
if(!btns.length){setTimeout(bind,600);return;}
for(var i=0;i<btns.length&&i<map.length;i++){
(function(b,t){
if(b.getAttribute('data-tab-fixed'))return;
b.setAttribute('data-tab-fixed','1');
b.removeAttribute('onclick');
b.setAttribute('data-tab',t);
b.addEventListener('click',function(e){
e.preventDefault();e.stopPropagation();
if(typeof switchTab==='function')switchTab(t);
else fallbackTab(t);
});
})(btns[i],map[i]);
}
// تفعيل الهوم مبدئياً
btns[0].classList.add('active');
}
function fallbackTab(t){
if(t==='home'){window.scrollTo({top:0,behavior:'smooth'});}
else if(t==='reels'&&typeof openReels==='function')openReels();
else if(t==='saved'&&typeof openFavs==='function')openFavs();
else if(t==='profile'&&typeof openProfile==='function')openProfile();
else if(t==='bell'&&typeof openBellPage==='function')openBellPage();
else if(t==='friends'&&typeof openFriendsPage==='function')openFriendsPage();
}
bind();
})();
</script>
<!-- ====== fix-tabs ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ fix tabs applied')
PYEOF

git add -A && git commit -m "Robust tab binding with addEventListener" && git push
