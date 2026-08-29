#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'tabs-final' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== tabs-final: نظام تبويبات مستقل مضمون ======
function forceOpen(el){if(!el)return;el.classList.add('open');el.style.display='flex';el.style.zIndex='500';}
function forceClose(el){if(!el)return;el.classList.remove('open');el.style.display='none';}
window.tabGo=function(t){
try{
var pages=['savedOverlay','profileOverlay','reelsOverlay','bellPage','friendsPage'];
for(var i=0;i<pages.length;i++)forceClose(document.getElementById(pages[i]));
var btns=document.querySelectorAll('#bottomNav .bn-btn');
for(var i=0;i<btns.length;i++)btns[i].classList.toggle('active',btns[i].getAttribute('data-tab')===t);
if(t==='home'){document.body.style.overflow='';window.scrollTo({top:0,behavior:'smooth'});return;}
if(t==='reels'){if(window.openReels)openReels();forceOpen(document.getElementById('reelsOverlay'));}
else if(t==='saved'){if(window.openFavs)openFavs();forceOpen(document.getElementById('savedOverlay'));}
else if(t==='profile'){if(window.openProfile)openProfile();forceOpen(document.getElementById('profileOverlay'));}
else if(t==='bell'){if(window.openBellPage)openBellPage();forceOpen(document.getElementById('bellPage'));}
else if(t==='friends'){if(window.openFriendsPage)openFriendsPage();forceOpen(document.getElementById('friendsPage'));}
document.body.style.overflow='hidden';
}catch(err){toast('⚠️ '+err.message);}
};
function bindNavFinal(){
var map=['home','reels','friends','saved','bell','profile'];
var btns=document.querySelectorAll('#bottomNav .bn-btn');
if(!btns.length){setTimeout(bindNavFinal,800);return;}
for(var i=0;i<btns.length&&i<map.length;i++){
(function(b,t){
if(b.getAttribute('data-final'))return;
b.setAttribute('data-final','1');
b.removeAttribute('onclick');
b.setAttribute('data-tab',t);
b.addEventListener('click',function(e){e.preventDefault();e.stopPropagation();window.tabGo(t);},true);
})(btns[i],map[i]);
}
btns[0].classList.add('active');
}
bindNavFinal();
setInterval(function(){
var nb=document.querySelector('#bottomNav .bn-btn:not([data-final])');
if(nb)bindNavFinal();
},3000);
</script>
<!-- ====== tabs-final ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ tabs final applied')
PYEOF

git add -A && git commit -m "Bulletproof tab navigation system" && git push
