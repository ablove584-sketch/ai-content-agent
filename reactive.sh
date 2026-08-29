#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'reactive' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<script>
// ====== reactive: تحديث لحظي لكل الواجهات ======
function refreshUI(){
// 1) شارات الشريط السفلي
if(typeof updateNavBadges==='function')updateNavBadges();
// 2) ودجات الأكثر قراءة والتعليقات والإحصائيات
if(typeof widgets==='function')widgets();
// 3) صفحة المحفوظات إن كانت مفتوحة
var so=document.getElementById('savedOverlay');
if(so&&so.classList.contains('open')&&typeof openFavs==='function')openFavs();
// 4) الملف الشخصي إن كان مفتوحاً
var po=document.getElementById('profileOverlay');
if(po&&po.classList.contains('open')){
var act=document.querySelector('.pf-tab.active');
if(act&&typeof pfTab==='function')pfTab(act.getAttribute('data-tab'));
}
// 5) عداد المشاهدات في نافذة القراءة
var mv=document.getElementById('mViews');
if(mv&&window.currentPostId)mv.textContent=getViews(currentPostId);
}
// ربط كل التفاعلات بالتحديث الفوري
var _tl2=toggleLike;toggleLike=function(id){_tl2(id);refreshUI();};
var _tf3=toggleFav;toggleFav=function(id){_tf3(id);refreshUI();};
var _qc2=quickC;quickC=function(id,inp){_qc2(id,inp);refreshUI();};
var _ac2=addComment;addComment=function(e){_ac2(e);refreshUI();};
var _op2=openPost;openPost=function(id){_op2(id);refreshUI();};
var _rc2=repostCard;repostCard=function(id){_rc2(id);refreshUI();};
var _sc2=sendCard;sendCard=function(id){_sc2(id);refreshUI();};
</script>
<!-- ====== reactive ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ reactive system applied')
PYEOF

git add -A && git commit -m "Instant reactive UI across all screens" && git push
