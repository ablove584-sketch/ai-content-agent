#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

if 'HEART_F' in content:
    print('⚠️ Already applied')
else:
    upgrade = '''
<style>
.i-actions{gap:8px!important}
.i-actions button{color:var(--text);display:flex;align-items:center}
.i-actions svg{width:26px;height:26px}
.i-cnt{font-size:13px;font-weight:700;color:var(--text)}
</style>
<script>
var HEART_O='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>';
var HEART_F='<svg viewBox="0 0 24 24" fill="#ed4956" stroke="#ed4956" stroke-width="2"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>';
var IC_COMMENT='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>';
var IC_REPOST='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="17 1 21 5 17 9"/><path d="M3 11V9a4 4 0 0 1 4-4h14"/><polyline points="7 23 3 19 7 15"/><path d="M21 13v2a4 4 0 0 1-4 4H3"/></svg>';
var IC_SEND='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="22" y1="2" x2="11" y2="13"/><polygon points="22 2 15 22 11 13 2 9 22 2"/></svg>';
var IC_BOOK='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>';
var BOOK_F='<svg viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2"><path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/></svg>';
function fmtNum(n){n=n||0;if(n>=1000000)return (n/1000000).toLocaleString('ar-EG',{maximumFractionDigits:1})+' مليون';if(n>=1000)return (n/1000).toLocaleString('ar-EG',{maximumFractionDigits:1})+' ألف';return n.toLocaleString('ar-EG');}
function relTime(ds){try{var d=new Date(String(ds).replace(' ','T'));var s=(Date.now()-d.getTime())/1000;if(isNaN(s)||s<0)return ds||'';if(s<60)return 'الآن';if(s<3600)return 'منذ '+Math.floor(s/60)+' دقيقة';if(s<86400)return 'منذ '+Math.floor(s/3600)+' ساعة';var days=Math.floor(s/86400);if(days===1)return 'منذ يوم';if(days===2)return 'منذ يومين';if(days<=10)return 'منذ '+days+' أيام';return 'منذ '+days+' يوماً';}catch(e){return ds||'';}}
function findPost(id){for(var i=0;i<allPosts.length;i++){if(allPosts[i].id===id)return allPosts[i];}return null;}
function getShares(id){return parseInt(lsGet('sh_'+id,'0'),10)||0;}
function bumpShares(id){lsSet('sh_'+id,getShares(id)+1);var card=document.querySelector('[data-card="'+id+'"]');if(card){var els=card.querySelectorAll('.sh-cnt');for(var i=0;i<els.length;i++)els[i].textContent=fmtNum(getShares(id));}}
function repostCard(id){bumpShares(id);toast('🔁 تم إعادة النشر');}
function sendCard(id){bumpShares(id);var p=findPost(id);var tx=encodeURIComponent(p?(p.title||'alkinani'):'alkinani');var url=encodeURIComponent(location.href);window.open('https://t.me/share/url?url='+url+'&text='+tx,'_blank');}
function favUI(id){var card=document.querySelector('[data-card="'+id+'"]');if(!card)return;var b=card.querySelector('.save-btn');if(b)b.innerHTML=isFav(id)?BOOK_F:IC_BOOK;}
function toggleFav(id){var f=[];try{f=JSON.parse(lsGet('favs','[]'));}catch(e){}var i=f.indexOf(id);if(i>-1){f.splice(i,1);toast('أزيل من المحفوظات');}else{f.push(id);toast('🔖 تم الحفظ');}lsSet('favs',JSON.stringify(f));favUI(id);}
function likeUI(id){var card=document.querySelector('[data-card="'+id+'"]');if(!card)return;var b=card.querySelector('.like-btn');var c=card.querySelector('.like-cnt');if(b)b.innerHTML=isLiked(id)?HEART_F:HEART_O;if(c)c.textContent=fmtNum(getLikes(id));}
function makeCard(p){var d=document.createElement('div');d.className='insta-card';d.setAttribute('data-card',p.id);
var img=TYPE_IMAGES[p.type]||TYPE_IMAGES.random;var content=p.content||'';var prev=content.length>90?content.substring(0,90)+'... ':content;
var tags=(p.hashtags||[]).slice(0,4);var cc=getComments(p.id).length;var sh=getShares(p.id);var lk=getLikes(p.id);
d.innerHTML='<div class="i-head"><div class="i-ring"><div class="i-av">'+(TYPE_ICONS[p.type]||'📄')+'</div></div><div class="i-user"><div class="i-name">alkinani</div><div class="i-loc">'+(TYPE_LABELS[p.type]||'')+' • '+relTime(p.date)+'</div></div><button style="background:none;border:none;font-size:20px;cursor:pointer;color:var(--text)" onclick="openPost('+p.id+')">⋯</button></div>'+
'<div class="i-img" ondblclick="dblLike('+p.id+',this)"><img src="'+img+'" alt="" loading="lazy"><div class="i-burst">❤️</div></div>'+
'<div class="i-actions">'+
'<button class="like-btn" onclick="toggleLike('+p.id+')">'+(isLiked(p.id)?HEART_F:HEART_O)+'</button><span class="i-cnt like-cnt">'+fmtNum(lk)+'</span>'+
'<button onclick="openPost('+p.id+')">'+IC_COMMENT+'</button><span class="i-cnt">'+fmtNum(cc)+'</span>'+
'<button onclick="repostCard('+p.id+')">'+IC_REPOST+'</button><span class="i-cnt sh-cnt">'+fmtNum(sh)+'</span>'+
'<button onclick="sendCard('+p.id+')">'+IC_SEND+'</button><span class="i-cnt sh-cnt">'+fmtNum(sh)+'</span>'+
'<button class="i-save save-btn" onclick="toggleFav('+p.id+')">'+(isFav(p.id)?BOOK_F:IC_BOOK)+'</button>'+
'</div>'+
'<div class="i-cap"><span class="i-name">alkinani</span> ✨ <strong style="color:var(--text)">'+(p.title||'')+'</strong> '+prev+(content.length>90?'<button class="i-more" onclick="openPost('+p.id+')">... المزيد</button>':'')+(tags.length?'<div class="i-tags">'+tags.map(function(t){return '<span>'+t+'</span>';}).join('')+'</div>':'')+'</div>'+
'<div class="i-add"><input type="text" placeholder="أضف تعليقاً..." onkeydown="if(event.key===\'Enter\')quickC('+p.id+',this)"><button onclick="quickC('+p.id+',this.previousElementSibling)">نشر</button></div>'+
'<div class="i-time">'+relTime(p.date)+' • تم الإنشاء بالذكاء الاصطناعي ✨</div>';
return d;}
</script>
'''
    content = content.replace('</body>', upgrade + '</body>', 1)
    with open('docs/index.html', 'w', encoding='utf-8') as f:
        f.write(content)
    print('✅ Real Instagram style applied!')
PYEOF

git add -A && git commit -m "Real Instagram icons and Arabic numbers" && git push
