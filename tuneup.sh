#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'back-top' in c:
    print('⚠️ already tuned')
else:
    extra = r'''
<style>
.cats-wrap{position:sticky;top:8px;z-index:60}
.back-top{position:fixed;bottom:20px;left:20px;width:46px;height:46px;border-radius:50%;border:none;background:var(--grad);color:#fff;font-size:18px;cursor:pointer;box-shadow:var(--shadow);opacity:0;pointer-events:none;transition:.3s;z-index:90}
.back-top.show{opacity:1;pointer-events:auto}
.new-badge{background:#ed4956;color:#fff;font-size:10px;padding:2px 8px;border-radius:10px;margin-inline-start:6px}
.sort-btns{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
.rel-card{background:var(--bg);border-radius:10px;padding:10px;margin-bottom:8px;cursor:pointer}
.rel-card:hover{background:var(--border)}
.m-progress{position:sticky;top:0;z-index:5;height:4px;background:var(--border)}
.m-progress div{height:100%;width:0;background:var(--grad)}
</style>
<script>
var sortMode='newest';
function setSort(m){sortMode=m;var b=document.querySelectorAll('.sort-b');for(var i=0;i<b.length;i++){b[i].classList.toggle('active',b[i].getAttribute('data-sort')===m);}shown=0;renderPosts(true);}
var _f=filtered;
filtered=function(){var l=_f().slice();if(sortMode==='views')l.sort(function(a,b){return getViews(b.id)-getViews(a.id);});else if(sortMode==='likes')l.sort(function(a,b){return getLikes(b.id)-getLikes(a.id);});else l.sort(function(a,b){return b.id-a.id;});return l;};
(function(){var crow=document.querySelector('.crow');if(crow){var d=document.createElement('div');d.className='sort-btns';d.innerHTML='<span style="font-size:12px;color:var(--muted)">ترتيب:</span><button class="fbtn sort-b active" data-sort="newest">الأحدث</button><button class="fbtn sort-b" data-sort="views">الأكثر قراءة</button><button class="fbtn sort-b" data-sort="likes">الأكثر إعجاباً</button>';crow.appendChild(d);var bs=d.querySelectorAll('.sort-b');for(var i=0;i<bs.length;i++){bs[i].addEventListener('click',function(){setSort(this.getAttribute('data-sort'));});}}}());
(function(){var b=document.createElement('button');b.className='back-top';b.textContent='⬆️';b.onclick=function(){window.scrollTo({top:0,behavior:'smooth'});};document.body.appendChild(b);window.addEventListener('scroll',function(){b.classList.toggle('show',window.scrollY>400);});})();
function isNew(p){try{var d=new Date(String(p.date).replace(' ','T'));return (Date.now()-d.getTime())/3600000<24;}catch(e){return false;}}
var _m=makeCard;
makeCard=function(p){var d=_m(p);
if(isNew(p)){var h=d.querySelector('.i-name');if(h){var s=document.createElement('span');s.className='new-badge';s.textContent='جديد';h.appendChild(s);}}
var t=d.querySelector('.i-time');if(t)t.innerHTML+=' • 👁️ '+fmtNum(getViews(p.id));
var im=d.querySelector('.i-img img');if(im)im.onerror=function(){im.src='https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=600&q=70&auto=format';im.onerror=null;};
return d;};
var _o=openPost;
openPost=function(id){_o(id);addExtras(id);};
function addExtras(id){var p=null;for(var i=0;i<allPosts.length;i++)if(allPosts[i].id===id){p=allPosts[i];break;}if(!p)return;
var body=document.querySelector('.m-body');
var old=body.querySelector('.rel-box');if(old)old.remove();
var rel=allPosts.filter(function(x){return x.id!==id&&(x.type||'random')===(p.type||'random');}).slice(0,3);
var box=document.createElement('div');box.className='rel-box';box.style.marginTop='20px';
box.innerHTML='<h3 class="wtitle">🔗 منشورات ذات صلة</h3>'+(rel.length?rel.map(function(r){return '<div class="rel-card" onclick="openPost('+r.id+')"><strong>'+(r.title||'')+'</strong><div style="font-size:12px;color:var(--muted)">'+(TYPE_LABELS[r.type]||'')+' • 👁️ '+fmtNum(getViews(r.id))+'</div></div>';}).join(''):'<p style="color:var(--muted)">لا يوجد</p>');
body.appendChild(box);
var acts=document.querySelector('.m-actions');
if(acts&&!acts.querySelector('.tts-b')){var tb=document.createElement('button');tb.className='abtn tts-b';tb.textContent='🔊 استمع';tb.onclick=function(){speak(p);};acts.appendChild(tb);}
var mb=document.querySelector('.m-box');if(mb&&!mb.querySelector('.m-progress')){var pr=document.createElement('div');pr.className='m-progress';pr.innerHTML='<div></div>';mb.insertBefore(pr,mb.firstChild);}
}
function speak(p){if(!('speechSynthesis' in window)){toast('غير مدعوم في متصفحك');return;}speechSynthesis.cancel();var u=new SpeechSynthesisUtterance((p.title||'')+'. '+(p.content||''));u.lang='ar-SA';speechSynthesis.speak(u);toast('🔊 جاري القراءة الصوتية');}
var _c=closeModal;
closeModal=function(){if('speechSynthesis' in window)speechSynthesis.cancel();_c();};
(function(){var m=document.getElementById('postModal');if(m)m.addEventListener('scroll',function(){var h=m.scrollHeight-m.clientHeight;var bar=document.querySelector('.m-progress div');if(bar)bar.style.width=(h>0?(m.scrollTop/h)*100:0)+'%';});})();
</script>
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ tune-up applied')
PYEOF

git add -A && git commit -m "Posts page tune-up: sticky cats, sort, badge, TTS, related" && git push
