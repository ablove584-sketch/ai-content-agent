#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-fix2' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-fix2: الشريط يرجع + المنشورات أولاً ====== */
@media(max-width:768px){
.top-app-bar{display:flex!important}
.container>header{display:none!important}
.layout{display:flex;flex-direction:column}
#postsContainer{order:1}
.featured-row{order:2}
}
</style>
<!-- ====== mobile-fix2 ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ mobile fix2 applied')
PYEOF

git add -A && git commit -m "Restore top bar, posts before widgets on mobile" && git push
