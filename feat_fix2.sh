#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'feat-fix2' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== feat-fix2: ضبط ارتفاع المميز والودجات ====== */
.featured-row{align-items:stretch}
.featured-row .insta-card.featured .i-img{flex:none!important;aspect-ratio:4/5!important;max-height:600px!important;min-height:280px}
.featured-row .side{display:flex!important;flex-direction:column;gap:15px;justify-content:space-between;max-height:none!important;overflow:visible!important}
.featured-row .side .widget{flex:0 1 auto}
</style>
<!-- ====== feat-fix2 ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ feat fix2 applied')
PYEOF

git add -A && git commit -m "Cap featured image height, distribute widgets evenly" && git push
