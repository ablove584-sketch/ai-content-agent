#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'feat-fix' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== feat-fix: صف مميز جنباً إلى جنب من 900px ====== */
@media(min-width:900px){
.featured-row{grid-template-columns:1.6fr 1fr!important;align-items:stretch}
.featured-row .side{display:flex!important;flex-direction:column!important;gap:15px;margin:0;max-height:700px;overflow-y:auto;scrollbar-width:thin}
.featured-row .insta-card.featured{margin:0}
}
@media(max-width:899px){
.featured-row{grid-template-columns:1fr!important}
.featured-row .side{display:grid!important;grid-template-columns:repeat(2,1fr)!important;max-height:none;overflow:visible}
}
@media(max-width:640px){
.featured-row .side{grid-template-columns:1fr!important}
}
</style>
<!-- ====== feat-fix ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ featured row fix applied')
PYEOF

git add -A && git commit -m "Featured post beside widgets from 900px" && git push
