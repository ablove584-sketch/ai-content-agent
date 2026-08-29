#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-clean' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-clean: إخفاء من الجوال فقط ====== */
@media(max-width:768px){
.back-top{display:none!important}
footer{display:none!important}
}
</style>
<!-- ====== mobile-clean ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ mobile clean applied')
PYEOF

git add -A && git commit -m "Hide back-top and footer on mobile" && git push
