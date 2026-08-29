#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'app-top-flush' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== app-top-flush: اندماج مع شريط الحالة ====== */
html{background:var(--card)}
@media(max-width:768px){
.top-app-bar{border-radius:0!important;margin:0!important;top:0!important;left:0!important;right:0!important;width:100%!important;padding-top:calc(8px + env(safe-area-inset-top))!important}
body{padding-top:calc(60px + env(safe-area-inset-top))}
}
</style>
<script>
// مزامنة لون شريط الحالة مع التطبيق
function syncTC(){
var m=document.querySelector('meta[name="theme-color"]');
if(!m)return;
var dark=document.documentElement.getAttribute('data-theme')==='dark';
m.setAttribute('content',dark?'#1a1a2e':'#ffffff');
}
var _tt2=toggleTheme;
toggleTheme=function(){_tt2();syncTC();};
syncTC();
</script>
<!-- ====== app-top-flush ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ app top flush applied')
PYEOF

git add -A && git commit -m "Flush top bar with status bar + theme color sync" && git push
