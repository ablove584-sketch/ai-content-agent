#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()
if 'mobile-equal' in c:
    print('⚠️ already applied')
else:
    extra = r'''
<style>
/* ====== mobile-equal: المميز بنفس مقاس الباقي بالجوال ====== */
@media(max-width:768px){
.insta-card.featured{border:2px solid var(--border)!important;background:var(--card)!important}
.insta-card.featured .i-img{aspect-ratio:var(--card-img-ratio,4/5)!important;max-height:none!important;min-height:0!important}
.insta-card.featured .i-title{font-size:14px!important;height:42px!important;overflow:hidden}
.insta-card.featured .i-cap{font-size:12px!important;height:78px!important;overflow:hidden;line-height:1.6!important}
.insta-card.featured .i-name::after{content:''!important}
}
</style>
<script>
// 1) إعادة زر القائمة ☰ ليكون أولاً قبل الشعار
(function(){
var bar=document.getElementById('topAppBar');
if(!bar)return;
var grp=bar.querySelector('.tab-group');
if(grp&&!grp.querySelector('[onclick*="openMenuModal"]')){
var btn=document.createElement('button');
btn.className='tab-btn';
btn.setAttribute('onclick','openMenuModal()');
btn.title='القائمة';
btn.innerHTML='<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><line x1="4" y1="7" x2="20" y2="7"/><line x1="4" y1="12" x2="20" y2="12"/><line x1="4" y1="17" x2="20" y2="17"/></svg>';
grp.insertBefore(btn,grp.firstChild);
}
})();
// 2) بالجوال: المميز يبقى داخل الشبكة بنفس المقاس
var _pf3=placeFeatured;
placeFeatured=function(){
if(window.matchMedia('(max-width:768px)').matches){
var row=document.getElementById('featuredRow');
var cont=document.getElementById('postsContainer');
if(row&&cont){var cur=row.querySelector('.insta-card');if(cur)cont.insertBefore(cur,cont.firstChild);}
return;
}
_pf3();
};
</script>
<!-- ====== mobile-equal ====== -->
'''
    c = c.replace('</body>', extra + '</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ mobile equal applied')
PYEOF

git add -A && git commit -m "Menu button first + featured same size on mobile" && git push
