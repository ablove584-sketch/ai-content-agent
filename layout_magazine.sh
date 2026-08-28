#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'grid-card' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* Magazine Layout */
#postsContainer{display:grid;grid-template-columns:repeat(3,1fr);gap:15px;align-items:start}
#postsContainer .loading,#postsContainer .empty{grid-column:1/-1}
.insta-card{max-width:none;width:auto;margin:0}
/* Featured (الأحدث) */
.insta-card.featured{grid-column:1/-1;border:2px solid transparent;background:linear-gradient(var(--card),var(--card)) padding-box,linear-gradient(45deg,#f09433,#dc2743,#764ba2) border-box}
.insta-card.featured .i-img{aspect-ratio:16/9;max-height:420px}
.insta-card.featured .i-title{font-size:20px}
.insta-card.featured .i-cap{font-size:15px}
.insta-card.featured .i-name::after{content:'⭐';margin-inline-start:5px}
/* Grid cards */
.insta-card.grid-card .i-title{font-size:14px}
.insta-card.grid-card .i-cap{font-size:12px}
.insta-card.grid-card .i-add{display:none}
.insta-card.grid-card .i-actions svg{width:22px;height:22px}
.insta-card.grid-card .i-cnt{font-size:11px}
@media(max-width:1100px){#postsContainer{grid-template-columns:repeat(2,1fr)}}
@media(max-width:640px){#postsContainer{grid-template-columns:1fr}}
</style>
<script>
var _rp=renderPosts;
renderPosts=function(reset){if(reset)window._featDone=false;_rp(reset);};
var _mk=makeCard;
makeCard=function(p){var d=_mk(p);
if(!window._featDone){d.classList.add('featured');window._featDone=true;}
else{d.classList.add('grid-card');}
return d;};
</script>
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ Magazine layout applied')
PYEOF

git add -A && git commit -m "Magazine layout: featured latest post + 3-column grid" && git push
