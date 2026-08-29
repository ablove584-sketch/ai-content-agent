#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'layout-v4' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ===== layout-v4 ===== */
.layout{display:block}
.featured-row{display:grid;grid-template-columns:1.6fr 1fr;gap:15px;margin:0 0 15px;align-items:stretch}
.featured-row .side{order:0;display:flex;flex-direction:column;gap:15px;margin:0;max-height:660px;overflow-y:auto;scrollbar-width:thin}
.featured-row .insta-card.featured{grid-column:auto;margin:0}
#postsContainer{display:grid;grid-template-columns:repeat(3,1fr);gap:15px;align-items:stretch}
#postsContainer .loading,#postsContainer .empty{grid-column:1/-1}
.insta-card.grid-card .i-img{aspect-ratio:4/5}
.insta-card.featured .i-img{aspect-ratio:4/5;max-height:660px}
@media(max-width:1100px){
.featured-row{grid-template-columns:1fr}
.featured-row .side{display:grid;grid-template-columns:repeat(2,1fr);max-height:none;overflow:visible}
#postsContainer{grid-template-columns:repeat(2,1fr)}
}
@media(max-width:640px){
.featured-row .side{grid-template-columns:1fr}
#postsContainer{grid-template-columns:1fr}
}
</style>
<script>
(function(){
var layout=document.querySelector('.layout');
var main=document.getElementById('postsContainer');
var side=document.querySelector('.side');
if(layout&&main&&side&&!document.getElementById('featuredRow')){
var row=document.createElement('div');row.id='featuredRow';row.className='featured-row';
layout.insertBefore(row,main);
row.appendChild(side);
}
})();
var _rp4=renderPosts;
renderPosts=function(reset){_rp4(reset);placeFeatured();};
function placeFeatured(){
var row=document.getElementById('featuredRow');if(!row)return;
var cont=document.getElementById('postsContainer');
var side=row.querySelector('.side');
var w=window._mostWidget;
if(w&&side&&w.parentElement!==side)side.insertBefore(w,side.firstChild);
var feat=cont.querySelector('.insta-card.featured');
var cur=row.querySelector('.insta-card.featured');
if(cur&&cur!==feat)cur.remove();
if(feat)row.insertBefore(feat,row.firstChild);
}
</script>
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ layout v4 applied')
PYEOF

git add -A && git commit -m "Layout v4: featured + widgets column + 4:5 uniform grid" && git push
