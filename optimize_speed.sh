#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

changes = []

# 1. إزالة المكتبات الثقيلة من التحميل الأولي (تُحمّل عند الطلب فقط)
old1 = '<script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>'
old2 = '<script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>'
if old1 in content:
    content = content.replace(old1, ''); changes.append('removed html2pdf')
if old2 in content:
    content = content.replace(old2, ''); changes.append('removed qrcode')

# 2. إضافة preconnect لتسريع الصور
preconnect = '''    <link rel="preconnect" href="https://images.unsplash.com">
    <link rel="dns-prefetch" href="https://images.unsplash.com">
'''
if 'preconnect' not in content:
    content = content.replace('<meta charset="UTF-8">', '<meta charset="UTF-8">\n' + preconnect, 1)
    changes.append('added preconnect')

# 3. تصغير الصور (800 → 600 مع ضغط)
if '?w=800' in content:
    content = content.replace('?w=800', '?w=600&q=70&auto=format')
    changes.append('optimized images')

# 4. تحميل المكتبات عند الطلب فقط
lazy_js = '''
        // ========== LAZY LOAD LIBRARIES ==========
        function loadScript(src) {
            return new Promise((resolve, reject) => {
                if (document.querySelector('script[src="' + src + '"]')) return resolve();
                const s = document.createElement('script');
                s.src = src; s.onload = resolve; s.onerror = reject;
                document.body.appendChild(s);
            });
        }
        async function ensurePDF() {
            if (typeof html2pdf === 'undefined')
                await loadScript('https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js');
        }
        async function ensureQR() {
            if (typeof QRCode === 'undefined')
                await loadScript('https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js');
        }
'''
if 'ensurePDF' not in content:
    parts = content.rsplit('</script>', 1)
    content = parts[0] + lazy_js + '    </script>' + (parts[1] if len(parts) > 1 else '')
    changes.append('added lazy loaders')

# 5. ربط التحميل عند الطلب بالدوال
if 'function downloadPDF() {' in content:
    content = content.replace('function downloadPDF() {', 'async function downloadPDF() { await ensurePDF();', 1)
    changes.append('pdf on demand')
if 'await ensurePDF' not in content and 'async function downloadPDF' in content:
    pass
if 'function openShareModal(postId) {' in content:
    content = content.replace('function openShareModal(postId) {', 'async function openShareModal(postId) { await ensureQR();', 1)
    changes.append('qr on demand')

# 6. عرض فوري من الكاش (بدون انتظار الشبكة)
cache_read = '''
            // عرض فوري من الكاش
            if (!window._cacheRendered) {
                window._cacheRendered = true;
                try {
                    const c = localStorage.getItem('postsCache');
                    if (c && allPosts.length === 0) {
                        allPosts = JSON.parse(c);
                        setTimeout(() => {
                            try {
                                if (typeof updateStats === 'function') updateStats();
                                if (typeof buildCategoriesBar === 'function') buildCategoriesBar();
                                if (typeof buildCategoryStats === 'function') buildCategoryStats();
                                if (typeof buildFilters === 'function') buildFilters();
                                if (typeof updateWidgets === 'function') updateWidgets();
                                displayedCount = 0;
                                displayPosts(true);
                            } catch (e) {}
                        }, 30);
                    }
                } catch (e) {}
            }
'''
if 'postsCache' not in content and 'async function loadPosts()' in content:
    content = content.replace('async function loadPosts() {', 'async function loadPosts() {' + cache_read, 1)
    changes.append('instant cache render')

# 7. حفظ الكاش بعد التحميل
if "allPosts = await response.json();" in content and 'postsCache' not in content.split('allPosts = await response.json()')[1][:200]:
    content = content.replace('allPosts = await response.json();', 
        'allPosts = await response.json();\n                try { localStorage.setItem("postsCache", JSON.stringify(allPosts)); } catch (e) {}', 1)
    changes.append('save cache')

# 8. تقليل التحديثات المتكررة (5 ثواني → 60 ثانية)
if 'setInterval(buildCategoriesBar, 5000)' in content:
    content = content.replace('setInterval(buildCategoriesBar, 5000)', 'setInterval(buildCategoriesBar, 60000)')
    changes.append('reduced intervals')

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print('✅ Applied:', ', '.join(changes) if changes else 'no changes needed')
PYEOF

git add -A && git commit -m "Optimize page loading speed" && git push
