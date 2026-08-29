#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'size-fix' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== size-fix: توحيد المقاسات نهائياً ====== */
.insta-card .i-img{aspect-ratio:var(--card-img-ratio,4/5)!important;max-height:none!important;height:auto!important;overflow:hidden;flex-shrink:0}
.insta-card.featured .i-img{aspect-ratio:var(--feat-img-ratio,4/5)!important}
.insta-card{display:flex;flex-direction:column;height:auto}
.insta-card.grid-card .i-title{height:42px;overflow:hidden}
.insta-card.grid-card .i-cap{height:78px;overflow:hidden}
.insta-card.grid-card .i-time{margin-top:auto}
@media(min-width:1101px){#postsContainer{grid-template-columns:repeat(var(--grid-cols,3),1fr)!important}}
@media(max-width:1100px){#postsContainer{grid-template-columns:repeat(2,1fr)!important}}
@media(max-width:640px){#postsContainer{grid-template-columns:1fr!important}}
</style>
<!-- ====== size-fix ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ size fix applied')
PYEOF

git add -A && git commit -m "Force uniform image ratio and remove empty gaps" && git push
