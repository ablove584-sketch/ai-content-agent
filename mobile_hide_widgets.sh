#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-hide-widgets' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-hide-widgets: ودجات الجوال مخفية ====== */
@media(max-width:768px){
.featured-row{display:none!important}
}
</style>
<!-- ====== mobile-hide-widgets ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ widgets hidden on mobile')
PYEOF

git add -A && git commit -m "Hide widgets on mobile only" && git push
