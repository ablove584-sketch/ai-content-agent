#!/bin/bash

python3 << 'PYEOF'
import re

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. استبدال شريط الإحصائيات القديم بالديناميكي
old_stats = r'<div class="category-bar">.*?</div>\s*</div>'
new_stats = '''<div class="category-stats" id="categoryStats">
                <div class="category-item active" data-type="all" onclick="selectCategory('all')">
                    <div class="category-icon">📊</div>
                    <div class="category-count" id="totalCount">0</div>
                    <div class="category-label">الإجمالي</div>
                </div>
            </div>
        </div>'''

content = re.sub(old_stats, new_stats, content, flags=re.DOTALL)

# 2. إضافة CSS محسّن
stats_css = '''
        .category-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
        }
        .category-item {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            padding: 15px 10px;
            text-align: center;
            transition: all 0.3s;
            cursor: pointer;
            box-shadow: 0 3px 10px rgba(0,0,0,0.08);
        }
        .category-item:hover {
            transform: translateY(-3px);
            box-shadow: 0 5px 20px rgba(0,0,0,0.15);
        }
        .category-item.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: transparent;
        }
        .category-icon { font-size: 24px; margin-bottom: 5px; }
        .category-count { font-size: 24px; font-weight: bold; margin-bottom: 3px; }
        .category-label { font-size: 11px; opacity: 0.85; }
'''

content = content.replace('</style>', stats_css + '\n    </style>')

# 3. إضافة JavaScript لبناء الإحصائيات
stats_js = '''
        // ========== DYNAMIC STATS ==========
        const TYPE_ICONS = {
            'random': '', 'book_summary': '📚', 'article': '',
            'story': '', 'facts': '💡', 'tips': '🎯',
            'news': '', 'philosophy': '🤔', 'history': '🏛️',
            'science': '🔬', 'psychology': '🧠'
        };
        
        const TYPE_LABELS = {
            'random': 'عشوائي', 'book_summary': 'ملخص كتاب', 'article': 'مقال',
            'story': 'قصة', 'facts': 'حقائق', 'tips': 'نصائح',
            'news': 'خبر تقني', 'philosophy': 'فلسفة', 'history': 'تاريخ',
            'science': 'علوم', 'psychology': 'علم نفس'
        };
        
        function buildDynamicStats() {
            const statsContainer = document.getElementById('categoryStats');
            if (!statsContainer || allPosts.length === 0) return;
            
            // حساب عدد المنشورات لكل نوع
            const typeCounts = {};
            allPosts.forEach(post => {
                const type = post.type || 'random';
                typeCounts[type] = (typeCounts[type] || 0) + 1;
            });
            
            // بناء HTML
            let html = `
                <div class="category-item ${currentFilter === 'all' ? 'active' : ''}" 
                     data-type="all" onclick="selectCategory('all')">
                    <div class="category-icon"></div>
                    <div class="category-count">${allPosts.length}</div>
                    <div class="category-label">الإجمالي</div>
                </div>
            `;
            
            // إضافة كل نوع موجود
            Object.entries(typeCounts).forEach(([type, count]) => {
                const icon = TYPE_ICONS[type] || '📄';
                const label = TYPE_LABELS[type] || type;
                const isActive = currentFilter === type ? 'active' : '';
                
                html += `
                    <div class="category-item ${isActive}" 
                         data-type="${type}" onclick="selectCategory('${type}')">
                        <div class="category-icon">${icon}</div>
                        <div class="category-count">${count}</div>
                        <div class="category-label">${label}</div>
                    </div>
                `;
            });
            
            statsContainer.innerHTML = html;
        }
        
        // تحديث selectCategory
        const originalSelectCategory = window.selectCategory || function(){};
        window.selectCategory = function(type) {
            currentFilter = type;
            buildDynamicStats();
            displayedCount = 0;
            displayPosts(true);
        };
'''

content = content.rreplace('</script>', stats_js + '\n    </script>', 1)

# 4. استدعاء buildDynamicStats بعد تحميل المنشورات
content = content.replace(
    'displayPosts(true);',
    'displayPosts(true); buildDynamicStats();'
)

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Dynamic stats bar fixed!")
PYEOF

git add -A && git commit -m "Fix dynamic stats bar with all topics" && git push
