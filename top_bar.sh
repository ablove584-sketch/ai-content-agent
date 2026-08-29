#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'top-app-bar' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== top-app-bar: شريط علوي ثابت للجوال ====== */
.top-app-bar{display:none}
@media(max-width:768px){
.top-app-bar{display:flex;justify-content:space-between;align-items:center;position:fixed;top:0;left:0;right:0;z-index:400;background:var(--card);border-bottom:1px solid var(--border);padding:8px 12px;box-shadow:0 3px 15px rgba(0,0,0,.15)}
body{padding-top:56px}
.cats-wrap{top:60px}
}
.tab-group{display:flex;align-items:center;gap:8px}
.tab-btn{background:var(--bg);border:none;color:var(--text);width:38px;height:38px;border-radius:50%;cursor:pointer;display:flex;align-items:center;justify-content:center;transition:transform .2s}
.tab-btn:active{transform:scale(.85)}
.tab-btn svg{width:22px;height:22px}
.bn-logo{font-family:'Helvetica Neue',Helvetica,Arial,sans-serif;font-weight:700;font-size:24px;letter-spacing:-1px;color:var(--text)}
</style>

<header class="top-app-bar" id="topAppBar">
<div class="tab-group">
<span class="bn-logo">alkinani</span>
<button class="tab-btn" onclick="openMenuModal()" title="القائمة"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="4" y1="7" x2="20" y2="7"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="17" x2="20" y2="17"/></svg></button>
</div>
<div class="tab-group">
<button class="tab-btn" onclick="openCommentsAll()" title="التعليقات"><svg viewBox="0 0 24 24" fill="currentColor"><path d="M12 2C6.36 2 2 6.13 2 11.7c0 2.91 1.19 5.44 3.14 7.17.16.14.26.35.27.57l.05 1.78c.02.57.6.94 1.12.71l1.98-.87c.17-.08.36-.09.53-.05.91.25 1.88.39 2.91.39 5.64 0 10-4.13 10-9.7S17.64 2 12 2z"/><path d="M5.8 13.7l3.2-5c.25-.4.77-.5 1.15-.22l2.5 1.87c.2.15.47.15.67 0l3.32-2.5c.47-.36 1.05.22.7.7l-3.2 5c-.25.4-.77.5-1.15.22l-2.5-1.87c-.2-.15-.47-.15-.67 0l-3.32 2.5c-.47.36-1.05-.22-.7-.7z" fill="var(--card)"/></svg></button>
<button class="tab-btn" onclick="focusSearch()" title="بحث"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><circle cx="11" cy="11" r="7"/><line x1="21" y1="21" x2="16.5" y2="16.5"/></svg></button>
<button class="tab-btn" onclick="openSuggest()" title="إضافة"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><rect x="3" y="3" width="18" height="18" rx="5"/><line x1="12" y1="8" x2="12" y2="16"/><line x1="8" y1="12" x2="16" y2="12"/></svg></button>
</div>
</header>

<script>
// ====== top-app-bar logic =====
function focusSearch(){
var s=document.getElementById('searchBox');
if(s){s.scrollIntoView({behavior:'smooth',block:'center'});setTimeout(function(){s.focus();},400);}
}
function openMenuModal(){
var b=document.getElementById('bottomBody');
b.innerHTML='<h3 class="wtitle">☰ القائمة</h3>'+
'<div style="display:flex;flex-direction:column;gap:10px">'+
'<button class="abtn" onclick="toggleTheme()">🌗 تبديل الوضع الداكن/الفاتح</button>'+
'<button class="abtn" onclick="setFont(14)">🔤 خط صغير</button>'+
'<button class="abtn" onclick="setFont(16)">🔤 خط وسط</button>'+
'<button class="abtn" onclick="setFont(18)">🔤 خط كبير</button>'+
'<button class="abtn" onclick="closeBottom();openSuggest()">💡 اقترح موضوعاً</button>'+
'</div>';
openBottom();
}
function openSuggest(){
var b=document.getElementById('bottomBody');
b.innerHTML='<h3 class="wtitle">💡 اقترح موضوعاً</h3>'+
'<p style="color:var(--muted);font-size:13px;margin-bottom:10px">اكتب فكرة منشور تريدها وسينشئها الذكاء الاصطناعي!</p>'+
'<input id="sugText" class="search" placeholder="اكتب فكرتك..." style="margin-bottom:10px">'+
'<button class="abtn" onclick="saveSuggest()">📤 إرسال الاقتراح</button>';
openBottom();
}
function saveSuggest(){
var t=document.getElementById('sugText').value.trim();if(!t)return;
var s=[];try{s=JSON.parse(lsGet('suggestions','[]'));}catch(e){}
s.unshift({text:t,date:new Date().toLocaleString('ar-SA')});
lsSet('suggestions',JSON.stringify(s));
closeBottom();toast('💡 تم استلام اقتراحك!');
}
</script>
<!-- ====== top-app-bar ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ top app bar added')
PYEOF

git add -A && git commit -m "Facebook-style fixed top bar for mobile" && git push
