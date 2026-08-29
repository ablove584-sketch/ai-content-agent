#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-min' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-min: واجهة جوال نظيفة ====== */
@media(max-width:768px){
header{display:none!important}
.cats-wrap{display:none!important}
.controls{display:none!important}
}
</style>
<script>
// البحث من الشريط العلوي يفتح نافذة بحث بالجوال
var _fs=focusSearch;
focusSearch=function(){
if(window.matchMedia('(max-width:768px)').matches){
var b=document.getElementById('bottomBody');
b.innerHTML='<h3 class="wtitle">🔍 البحث في المنشورات</h3><input id="mSearch" class="search" placeholder="اكتب للبحث..." oninput="mobileSearch(this.value)"><p style="color:var(--muted);font-size:12px;margin-top:10px">أغلق النافذة لرؤية النتائج</p>';
openBottom();
setTimeout(function(){var i=document.getElementById('mSearch');if(i)i.focus();},300);
}else{_fs();}
};
function mobileSearch(v){currentSearch=v;shown=0;renderPosts(true);}
// التصنيفات تنتقل لقائمة ☰ بالجوال
var _om=openMenuModal;
openMenuModal=function(){
_om();
var b=document.getElementById('bottomBody');
var counts={};allPosts.forEach(function(p){var t=p.type||'random';counts[t]=(counts[t]||0)+1;});
var h='<button class="chip'+(currentFilter==='all'?' active':'')+'" onclick="selectCat(\'all\');closeBottom()">🏠 الرئيسية</button>';
Object.keys(TYPE_LABELS).forEach(function(t){var n=counts[t]||0;if(!n)return;h+='<button class="chip'+(currentFilter===t?' active':'')+'" onclick="selectCat(\''+t+'\');closeBottom()">'+TYPE_ICONS[t]+' '+TYPE_LABELS[t]+' ('+n+')</button>';});
var d=document.createElement('div');
d.innerHTML='<h3 class="wtitle" style="margin-top:15px">📂 التصنيفات</h3><div style="display:flex;flex-wrap:wrap;gap:8px">'+h+'</div>';
b.appendChild(d);
};
</script>
<!-- ====== mobile-min ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ mobile minimal applied')
PYEOF

git add -A && git commit -m "Clean mobile UI: posts first, controls in menu" && git push
