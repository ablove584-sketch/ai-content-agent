#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'display-fix' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== display-fix ====== */
.featured-row .side{max-height:none!important;overflow:visible!important}
</style>
<script>
// ترتيب الودجات: الإحصائيات أولاً لتكون ظاهرة دائماً
(function(){
var side=document.querySelector('.side');
if(!side)return;
var stat=null,most=null,comm=null,news=null;
var ws=side.querySelectorAll('.widget');
for(var i=0;i<ws.length;i++){
if(ws[i].querySelector('#sTotal'))stat=ws[i];
else if(ws[i].querySelector('#wMost'))most=ws[i];
else if(ws[i].querySelector('#wComments'))comm=ws[i];
else if(ws[i].querySelector('.nform'))news=ws[i];
}
[stat,most,comm,news].forEach(function(w){if(w)side.appendChild(w);});
})();
// مراقبة التحميل: إذا علقت الصفحة تظهر رسالة وزر إعادة
setTimeout(function(){
var c=document.getElementById('postsContainer');
if(c&&(!window.allPosts||allPosts.length===0)){
c.innerHTML='<div class="empty">⚠️ تعذر تحميل المنشورات<br><br><button class="fbtn" onclick="location.reload()">🔄 إعادة المحاولة</button></div>';
}
},8000);
</script>
<!-- ====== display-fix ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ display fix applied')
PYEOF

git add -A && git commit -m "Show stats first + loading watchdog" && git push
