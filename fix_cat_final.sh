#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# دالة لإزالة أي div مع محتواه بالكامل (تعد الأقواس)
def remove_div_block(content, marker):
    start = content.find(marker)
    if start == -1:
        return content, False
    i = content.find('>', start) + 1
    depth = 1
    while depth > 0 and i < len(content):
        next_open = content.find('<div', i)
        next_close = content.find('</div>', i)
        if next_close == -1: break
        if next_open != -1 and next_open < next_close:
            depth += 1; i = next_open + 4
        else:
            depth -= 1; i = next_close + 6
    return content[:start] + content[i:], True

# 1. إزالة شريط الإحصائيات القديم
content, r1 = remove_div_block(content, '<div class="category-bar">')
content, r2 = remove_div_block(content, '<div class="stats-bar"')
print('Removed old bars:', r1, r2)

# 2. شريط التصنيفات الجديد
bar_html = '''
        <div class="categories-wrapper">
            <button class="scroll-btn scroll-right" onclick="scrollCategories(1)">❯</button>
            <div class="categories-bar" id="categoriesBar"></div>
            <button class="scroll-btn scroll-left" onclick="scrollCategories(-1)">❮</button>
        </div>
'''
if 'categories-wrapper' not in content:
    hero = content.find('<section class="hero"')
    done = False
    if hero != -1:
        end = content.find('</section>', hero)
        if end != -1:
            pos = end + 10
            content = content[:pos] + bar_html + content[pos:]
            done = True
    if not done:
        content = content.replace('</header>', '</header>' + bar_html, 1)

# 3. CSS
css = '''
        .categories-wrapper { position: relative; margin: 20px 0; background: var(--card-bg, white); border-radius: 15px; padding: 15px 50px; box-shadow: 0 5px 20px rgba(0,0,0,0.08); }
        .categories-bar { display: flex; gap: 10px; overflow-x: auto; scroll-behavior: smooth; scrollbar-width: none; padding: 5px 0; }
        .categories-bar::-webkit-scrollbar { display: none; }
        .category-chip { flex-shrink: 0; display: inline-flex; align-items: center; gap: 8px; padding: 10px 20px; background: var(--bg-color, #f5f7fa); border: 2px solid var(--border-color, #e2e8f0); border-radius: 25px; cursor: pointer; font-size: 14px; font-weight: 600; color: var(--text-primary, #4a5568); transition: all 0.3s; white-space: nowrap; }
        .category-chip:hover { border-color: #667eea; color: #667eea; transform: translateY(-2px); }
        .category-chip.active { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-color: transparent; }
        .chip-count { background: rgba(128,128,128,0.2); padding: 2px 8px; border-radius: 10px; font-size: 11px; }
        .category-chip.active .chip-count { background: rgba(255,255,255,0.25); }
        .scroll-btn { position: absolute; top: 50%; transform: translateY(-50%); width: 35px; height: 35px; border-radius: 50%; border: none; background: linear-gradient(135deg, #667eea, #764ba2); color: white; cursor: pointer; z-index: 10; }
        .scroll-right { right: 8px; } .scroll-left { left: 8px; }
'''
if '.categories-bar' not in content:
    content = content.replace('</style>', css + '    </style>', 1)

# 4. JavaScript
js = '''
        // ========== CATEGORIES ==========
        const CATEGORY_TYPES = [
            { type: 'philosophy', icon: '🤔', label: 'فلسفة' },
            { type: 'story', icon: '📖', label: 'قصص' },
            { type: 'science', icon: '🔬', label: 'علوم' },
            { type: 'article', icon: '📝', label: 'مقالات' },
            { type: 'book_summary', icon: '📚', label: 'ملخصات كتب' },
            { type: 'facts', icon: '💡', label: 'حقائق' },
            { type: 'tips', icon: '🎯', label: 'نصائح' },
            { type: 'news', icon: '📰', label: 'أخبار تقنية' },
            { type: 'history', icon: '🏛️', label: 'تاريخ' },
            { type: 'psychology', icon: '🧠', label: 'علم نفس' },
            { type: 'random', icon: '🎲', label: 'عشوائي' }
        ];
        function buildCategoriesBar() {
            const bar = document.getElementById('categoriesBar');
            if (!bar || typeof allPosts === 'undefined' || !allPosts.length) return;
            const counts = {};
            allPosts.forEach(p => { const t = p.type || 'random'; counts[t] = (counts[t] || 0) + 1; });
            let html = '<button class="category-chip ' + (currentFilter === 'all' ? 'active' : '') + '" onclick="selectCategory(\\'all\\')"><span>🏠</span> الرئيسية <span class="chip-count">' + allPosts.length + '</span></button>';
            CATEGORY_TYPES.forEach(c => {
                const n = counts[c.type] || 0;
                if (!n) return;
                html += '<button class="category-chip ' + (currentFilter === c.type ? 'active' : '') + '" onclick="selectCategory(\\'' + c.type + '\\')"><span>' + c.icon + '</span> ' + c.label + ' <span class="chip-count">' + n + '</span></button>';
            });
            bar.innerHTML = html;
        }
        function scrollCategories(d) {
            const bar = document.getElementById('categoriesBar');
            if (bar) bar.scrollBy({ left: d * 250, behavior: 'smooth' });
        }
        // ربط بالدوال القديمة
        window.buildCategoryStats = buildCategoriesBar;
        const _oldSel = window.selectCategory;
        window.selectCategory = function(type) {
            currentFilter = type;
            buildCategoriesBar();
            if (typeof _oldSel === 'function') _oldSel(type);
            else { displayedCount = 0; displayPosts(true); }
        };
        setInterval(buildCategoriesBar, 5000);
'''
if 'buildCategoriesBar' not in content:
    parts = content.rsplit('</script>', 1)
    content = parts[0] + js + '    </script>' + (parts[1] if len(parts) > 1 else '')

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)
print('✅ Done!')
PYEOF

git add -A && git commit -m "Add scrollable categories bar" && git push
