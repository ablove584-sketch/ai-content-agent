#!/bin/bash
python3 << 'PYEOF'
import os

# 1) ملفات PWA (تثبيت كتطبيق)
manifest = '''{
  "name": "alkinani - مركز المحتوى الذكي",
  "short_name": "alkinani",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0f0f1e",
  "theme_color": "#667eea",
  "dir": "rtl",
  "lang": "ar",
  "icons": [
    {"src": "icon.svg", "sizes": "any", "type": "image/svg+xml", "purpose": "any"}
  ]
}'''
with open('docs/manifest.json','w',encoding='utf-8') as f: f.write(manifest)

icon = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"><rect width="512" height="512" rx="110" fill="#667eea"/><text x="256" y="345" font-size="280" text-anchor="middle" fill="#ffffff" font-family="Arial" font-weight="bold">K</text></svg>'''
with open('docs/icon.svg','w',encoding='utf-8') as f: f.write(icon)

with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()

# 2) وسوم التطبيق في الهيدر
if 'rel="manifest"' not in c:
    head = '''<link rel="manifest" href="manifest.json">
<meta name="theme-color" content="#667eea">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="alkinani">
'''
    c = c.replace('<meta charset="UTF-8">', '<meta charset="UTF-8">\n'+head, 1)
    print('✅ PWA tags added')

# 3) إحساس التطبيق + بطاقات كاملة بالملف الشخصي
if 'app-feel' not in c:
    extra = r'''
<style>
/* ====== app-feel: إحساس تطبيق أصلي ====== */
*{-webkit-tap-highlight-color:transparent}
html,body{overscroll-behavior:none}
body{touch-action:manipulation}
button,.chip,.tab-btn,.bn-btn{-webkit-user-select:none;user-select:none}
</style>
<script>
// الملف الشخصي: بطاقات كاملة مثل الرئيسية
function pfTab(t){
var tabs=document.querySelectorAll('.pf-tab');
for(var i=0;i<tabs.length;i++)tabs[i].classList.toggle('active',tabs[i].getAttribute('data-tab')===t);
var wrap=document.getElementById('pfGridWrap');
var list=[];
if(t==='posts')list=allPosts;
else if(t==='saved'){var f=[];try{f=JSON.parse(lsGet('favs','[]'));}catch(e){}list=allPosts.filter(function(p){return f.indexOf(p.id)>-1;});}
else list=allPosts.filter(function(p){return isLiked(p.id);});
if(!list.length){wrap.innerHTML='<div style="text-align:center;color:var(--muted);padding:60px 20px">لا يوجد محتوى هنا بعد</div>';return;}
wrap.innerHTML='<div class="saved-feed"></div>';
var feed=wrap.firstChild;
var old=window._featDone;window._featDone=true;
for(var i=0;i<list.length;i++)feed.appendChild(makeCard(list[i]));
window._featDone=old;
}
</script>
<!-- ====== app-feel ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    print('✅ app feel applied')

with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
PYEOF

git add -A && git commit -m "Native app feel: PWA install + full cards in profile" && git push
