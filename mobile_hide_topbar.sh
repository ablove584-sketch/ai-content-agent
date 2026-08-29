#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-hide-topbar' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-hide-topbar ====== */
@media(max-width:768px){
.topbar{display:none!important}
}
</style>
<!-- ====== mobile-hide-topbar ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ topbar hidden on mobile')
PYEOF

git add -A && git commit -m "Hide time strip on mobile" && git push
