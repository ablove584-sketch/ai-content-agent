#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'layout-v2' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ===== layout-v2 ===== */
.layout{display:flex;flex-direction:column}
.side{order:-1;display:grid;grid-template-columns:repeat(4,1fr);gap:15px;margin:0 0 15px}
@media(max-width:1100px){.side{grid-template-columns:repeat(2,1fr)}}
@media(max-width:640px){.side{grid-template-columns:1fr}}
#postsContainer{align-items:stretch}
.insta-card{display:flex;flex-direction:column}
.insta-card.grid-card .i-img{aspect-ratio:1/1;flex-shrink:0}
.insta-card.grid-card .i-title{height:42px;overflow:hidden}
.insta-card.grid-card .i-cap{height:78px;overflow:hidden}
.insta-card.grid-card .i-time{margin-top:auto}
</style>
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ layout v2 applied')
PYEOF

git add -A && git commit -m "Full-width posts grid + uniform card sizes" && git push
