#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'size-settings' in c:
    print('⚠️ already exists')
else:
    extra = r'''
<style>
/* ============================================ */
/* ====== ⚙️ إعدادات المقاسات - عدّل من هنا ====== */
/* ============================================ */
:root{
--grid-cols:3;             /* عدد أعمدة الشبكة (2 أو 3 أو 4) */
--card-img-ratio:4/5;      /* صورة البطاقة: 1/1 مربع | 4/5 عمودي | 16/9 عريض */
--feat-img-ratio:4/5;      /* صورة المنشور الكبير */
--card-title-size:14px;    /* حجم عنوان البطاقة */
--card-text-size:12px;     /* حجم نص البطاقة */
}
/* ============================================ */
#postsContainer{grid-template-columns:repeat(var(--grid-cols),1fr)}
.insta-card.grid-card .i-img{aspect-ratio:var(--card-img-ratio)}
.insta-card.featured .i-img{aspect-ratio:var(--feat-img-ratio)}
.insta-card.grid-card .i-title{font-size:var(--card-title-size)}
.insta-card.grid-card .i-cap{font-size:var(--card-text-size)}
</style>
<!-- ====== size-settings ====== -->
'''
    # أدخل الإعدادات بعد أول <style> لتكون سهلة الوصول
    idx = c.find('<style>')
    if idx != -1:
        pos = idx + len('<style>')
        c = c[:pos] + extra + c[pos:]
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ size settings added')
PYEOF

git add -A && git commit -m "Add manual size settings panel" && git push
