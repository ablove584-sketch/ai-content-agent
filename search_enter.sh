#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'search-enter' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== search-enter: الذهاب/Enter يغلق البحث ======
var _fs2=focusSearch;
focusSearch=function(){
if(window.matchMedia('(max-width:768px)').matches){
var b=document.getElementById('bottomBody');
b.innerHTML='<h3 class="wtitle">🔍 البحث في المنشورات</h3>'+
'<form onsubmit="event.preventDefault();closeBottom();">'+
'<input id="mSearch" class="search" placeholder="اكتب للبحث..." enterkeyhint="search" oninput="mobileSearch(this.value)">'+
'</form>';
openBottom();
setTimeout(function(){var i=document.getElementById('mSearch');if(i)i.focus();},300);
}else{_fs2();}
};
// احتياطي: Enter يغلق مباشرة
document.addEventListener('keydown',function(e){
if(e.key==='Enter'){
var i=document.getElementById('mSearch');
if(i&&document.activeElement===i){e.preventDefault();closeBottom();}
}
});
</script>
<!-- ====== search-enter ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ search enter applied')
PYEOF

git add -A && git commit -m "Search keyboard Go/Enter closes modal" && git push
