#!/bin/bash

# ========== 1) الموقع: إضافة #alkinani لكل المنشورات ==========
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'brand-tag' not in c:
    extra = r'''
<script>
// ====== brand-tag: #alkinani ثابت في كل منشور ======
var _ra3=renderAll;
renderAll=function(){
allPosts.forEach(function(p){
var h=(p.hashtags||[]).filter(function(t){return t!=='#alkinani';});
h.unshift('#alkinani');
p.hashtags=h.slice(0,5);
});
_ra3();
};
</script>
<!-- ====== brand-tag ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ website: #alkinani fixed')
else:
    print('⚠️ website already done')
PYEOF

# ========== 2) الـ workflow: حفظ #alkinani في المنشورات الجديدة ==========
python3 << 'PYEOF'
with open('.github/workflows/content-agent.yml','r',encoding='utf-8') as f: c=f.read()
if 'brand-tag-wf' not in c:
    old = "          new_post = {"
    new = """          # تثبيت #alkinani كأول هاشتاج (5 كحد أقصى)
          hashtags = [t for t in hashtags if t != '#alkinani'][:4]
          hashtags.append('#alkinani')  # brand-tag-wf

          new_post = {"""
    if old in c:
        c = c.replace(old, new, 1)
        with open('.github/workflows/content-agent.yml','w',encoding='utf-8') as f: f.write(c)
        print('✅ workflow: #alkinani fixed')
    else:
        print('⚠️ pattern not found')
else:
    print('⚠️ workflow already done')
PYEOF

git add -A && git commit -m "Fix #alkinani brand hashtag in all posts" && git push
