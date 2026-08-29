#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'reels-video' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== reels-video: الريلز للفيديوهات فقط ======
function hasVideo(p){return !!(p.video||p.video_url);}
function getVideo(p){return p.video||p.video_url;}
var _or2=openReels;
openReels=function(){
var o=document.getElementById('reelsOverlay');
var feed=document.getElementById('reelsFeed');
var vids=allPosts.filter(hasVideo);
if(!vids.length){
feed.innerHTML='<div class="reel" style="display:flex;align-items:center;justify-content:center;flex-direction:column;gap:15px;color:#fff">'+
'<div style="font-size:70px">🎬</div>'+
'<div style="font-weight:700;font-size:18px">لا توجد فيديوهات بعد</div>'+
'<div style="color:#aaa;font-size:14px;text-align:center;padding:0 30px;line-height:1.8">عندما ينشر الوكيل فيديو سيظهر هنا تلقائياً في الريلز</div>'+
'<button class="reel-follow" onclick="closeReels()">العودة للمنشورات</button></div>';
}else{
feed.innerHTML=vids.map(function(p){return reelHTML(p);}).join('');
}
o.classList.add('open');
document.body.style.overflow='hidden';
};
// إعادة بناء reelHTML بدعم الفيديو
function reelHTML(p){
var v=getVideo(p);
var media;
if(v){
media='<video class="reel-bg" src="'+v+'" autoplay muted loop playsinline onclick="if(this.paused)this.play();else this.pause()"></video>';
}else{
var img=(typeof postImage==='function')?postImage(p):(TYPE_IMAGES[p.type]||TYPE_IMAGES.random);
media='<img class="reel-bg" src="'+img+'" alt="" loading="lazy" ondblclick="dblLike('+p.id+',this);updateReelUI('+p.id+')">';
}
var lk=getLikes(p.id),cc=getComments(p.id).length,sh=getShares(p.id);
return '<div class="reel" data-reel="'+p.id+'">'+media+
'<div class="reel-actions">'+
'<button onclick="toggleLike('+p.id+');updateReelUI('+p.id+')"><span class="rl">'+(isLiked(p.id)?HEART_F:HEART_O)+'</span><span class="rc rlike">'+fmtNum(lk)+'</span></button>'+
'<button onclick="closeReels();openPost('+p.id+')">'+IC_COMMENT+'<span class="rc">'+fmtNum(cc)+'</span></button>'+
'<button onclick="repostCard('+p.id+');updateReelUI('+p.id+')">'+IC_REPOST+'<span class="rc rshare">'+fmtNum(sh)+'</span></button>'+
'<button onclick="sendCard('+p.id+');updateReelUI('+p.id+')">'+IC_SEND+'<span class="rc rshare">'+fmtNum(sh)+'</span></button>'+
'<button onclick="toggleFav('+p.id+')">'+(isFav(p.id)?BOOK_F:IC_BOOK)+'</button>'+
'</div>'+
'<div class="reel-bottom">'+
'<div class="reel-av">'+(TYPE_ICONS[p.type]||'📄')+'</div>'+
'<div style="flex:1"><div style="display:flex;align-items:center;gap:10px"><span class="reel-name">alkinani</span><button class="reel-follow" onclick="this.textContent=\'✓ متابَع\';toast(\'✅ تمت المتابعة\')">متابعة</button></div>'+
'<div class="reel-cap">✨ '+(p.title||'')+'</div></div>'+
'</div>'+
'</div>';
}
</script>
<!-- ====== reels-video ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ reels now video-only')
PYEOF

git add -A && git commit -m "Reels shows videos only, ready for future video posts" && git push
