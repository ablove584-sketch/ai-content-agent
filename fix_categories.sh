#!/bin/bash

python3 << 'PYEOF'
import re

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. إزالة شريط الإحصائيات القديم بالكامل
content = re.sub(r'<div class="category-bar">.*?</div>\s*</div>\s*</div>', '', content, flags=re.DOTALL)
content = re.sub(r'<div class="stats-bar".*?</div>\s*</div>', '', content, flags=re.DOTALL)

# 2. إضافة شريط التصنيفات الأفقي بعد الـ header
categories_bar = '''
        <!-- Horizontal Scrollable Categories -->
        <div class="categories-wrapper">
            <button class="scroll-btn scroll-right" onclick="scrollCategories(1)">❯</button>
            <div class="categories-bar" id="categoriesBar">
                <button class="category-chip active" data-type="all" onclick="selectCategory('all')">
                    <span class="chip-icon">🏠</span> الرئيسية
                </button>
            </div>
            <button class="scroll-btn scroll-left" onclick="scrollCategories(-1)">❮</button>
        </div>
'''

content = content.replace('</header>', '</header>\n' + categories_bar)

# 3. إضافة CSS لشريط التصنيفات
categories_css = '''
        /* Horizontal Categories Bar */
        .categories-wrapper {
            position: relative;
            margin: 20px 0;
            background: white;
            border-radius: 15px;
            padding: 15px 50px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
        }
        .categories-bar {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            scroll-behavior: smooth;
            scrollbar-width: none;
            -ms-overflow-style: none;
            padding: 5px 0;
            direction: rtl;
        }
        .categories-bar::-webkit-scrollbar { display: none; }
        .category-chip {
            flex-shrink: 0;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 20px;
            background: #f5f7fa;
            border: 2px solid #e2e8f0;
            border-radius: 25px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            color: #4a5568;
            transition: all 0.3s;
            white-space: nowrap;
        }
        .category-chip:hover {
            background: #eef2ff;
            border-color: #667eea;
            color: #667eea;
            transform: translateY(-2px);
        }
        .category-chip.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: transparent;
            box-shadow: 0 5px 15px rgba(102,126,234,0.4);
        }
        .chip-icon { font-size: 16px; }
        .chip-count {
            background: rgba(255,255,255,0.25);
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 11px;
            font-weight: bold;
        }
        .category-chip:not(.active) .chip-count {
            background: #e2e8f0;
            color: #4a5568;
        }
        .scroll-btn {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            width: 35px;
            height: 35px;
            border-radius: 50%;
            border: none;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            cursor: pointer;
            font-size: 14px;
            z-index: 10;
            box-shadow: 0 3px 10px rgba(0,0,0,0.2);
            transition: all 0.3s;
        }
        .scroll-btn:hover { transform: translateY(-50%) scale(1.1); }
        .scroll-right { right: 8px; }
        .scroll-left { left: 8px; }
        @media (max-width: 768px) {
            .categories-wrapper { padding: 12px 45px; }
            .category-chip { padding: 8px 16px; font-size: 13px; }
        }
'''

content = content.replace('</style>', categories_css + '\n    </style>')

# 4. إضافة JavaScript للتصنيفات
categories_js = '''
        // ========== CATEGORIES SYSTEM ==========
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
            if (!bar) return;
            
            // حساب عدد المنشورات لكل نوع
            const typeCounts = {};
            allPosts.forEach(post => {
                const type = post.type || 'random';
                typeCounts[type] = (typeCounts[type] || 0) + 1;
            });
            
            let html = `
                <button class="category-chip ${currentFilter === 'all' ? 'active' : ''}" 
                        data-type="all" onclick="selectCategory('all')">
                    <span class="chip-icon">🏠</span> الرئيسية
                    <span class="chip-count">${allPosts.length}</span>
                </button>
            `;
            
            // إضافة كل التصنيفات (الموجودة فقط)
            CATEGORY_TYPES.forEach(cat => {
                const count = typeCounts[cat.type] || 0;
                if (count === 0) return; // إخفاء التصنيفات الفارغة
                
                html += `
                    <button class="category-chip ${currentFilter === cat.type ? 'active' : ''}" 
                            data-type="${cat.type}" onclick="selectCategory('${cat.type}')">
                        <span class="chip-icon">${cat.icon}</span> ${cat.label}
                        <span class="chip-count">${count}</span>
                    </button>
                `;
            });
            
            bar.innerHTML = html;
        }
        
        function scrollCategories(direction) {
            const bar = document.getElementById('categoriesBar');
            if (bar) bar.scrollBy({ left: direction * 250, behavior: 'smooth' });
        }
        
        // دعم السحب باللمس والفأرة
        (function enableDragScroll() {
            let isDown = false, startX, scrollLeft;
            document.addEventListener('DOMContentLoaded', () => {
                const bar = document.getElementById('categoriesBar');
                if (!bar) return;
                bar.addEventListener('mousedown', (e) => {
                    isDown = true;
                    startX = e.pageX - bar.offsetLeft;
                    scrollLeft = bar.scrollLeft;
                });
                bar.addEventListener('mouseleave', () => isDown = false);
                bar.addEventListener('mouseup', () => isDown = false);
                bar.addEventListener('mousemove', (e) => {
                    if (!isDown) return;
                    e.preventDefault();
                    const x = e.pageX - bar.offsetLeft;
                    bar.scrollLeft = scrollLeft - (x - startX);
                });
            });
        })();
        
        // تحديث selectCategory
        window.selectCategory = function(type) {
            currentFilter = type;
            buildCategoriesBar();
            displayedCount = 0;
            displayPosts(true);
        };
'''

content = content.rreplace('</script>', categories_js + '\n    </script>', 1)

# 5. استدعاء buildCategoriesBar بعد تحميل المنشورات
content = content.replace(
    'displayPosts(true);',
    'displayPosts(true); buildCategoriesBar();'
)

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Categories bar added successfully!")
PYEOF

git add -A && git commit -m "Add horizontal scrollable categories bar" && git push
