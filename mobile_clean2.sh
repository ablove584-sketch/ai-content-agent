#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-clean2' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-clean2: إخفاء شريط التمرير من الجوال ====== */
@media(max-width:768px){
html{scrollbar-width:none;-ms-overflow-style:none}
html::-webkit-scrollbar,body::-webkit-scrollbar{display:none;width:0;height:0}
}
</style>
<!-- ====== mobile-clean2 ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ scrollbar hidden on mobile')
PYEOF

git add -A && git commit -m "Hide scrollbar on mobile" && git push
