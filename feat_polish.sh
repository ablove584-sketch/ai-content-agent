#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'feat-polish' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== feat-polish: صورة المميز تملأ الارتفاع ====== */
.featured-row .insta-card.featured{display:flex;flex-direction:column;height:100%}
.featured-row .insta-card.featured .i-img{flex:1;aspect-ratio:auto!important;min-height:320px;max-height:none!important}
.featured-row .insta-card.featured .i-time{margin-top:auto}
</style>
<!-- ====== feat-polish ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ featured polish applied')
PYEOF

git add -A && git commit -m "Featured image fills column height" && git push
