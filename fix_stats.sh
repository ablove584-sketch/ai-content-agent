#!/bin/bash

python3 << 'PYEOF'
import re

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. استبدال شريط الإحصائيات القديم
old_stats = r'<div class="stats-bar">.*?</div>'
new_stats = '''<div class="stats-bar" id="statsBar">
            <div class="stat-item active" data-type="all" onclick="selectCategory('all')" style="cursor:pointer;">
                <div class="stat-icon">📊</div>
                <div class="stat-number" id="totalCount">0</div>
                <div class="stat-label">الإجمالي</div>
            </div>
        </div>'''

content = re.sub(old_stats, new_stats, content, flags=re.DOTALL)

# 2. إضافة CSS للـ stat-item
stats_css = '''
        .stats-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
            gap: 12px;
        }
        .stat-item {
            background: white;
            border-radius: 12px;
            padding: 20px 15px;
            text-align: center;
            box-shadow: 0 5px 20px rgba(0,0,0,0.08);
            transition: all 0.3s;
            cursor: pointer;
            border: 2px solid transparent;
        }
        .stat-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
        }
        .stat-item.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-color: #5a67d8;
        }
        .stat-icon { font-size: 28px; margin-bottom: 8px; }
        .stat-number { font-size: 32px; font-weight: bold; margin-bottom: 5px; }
        .stat-label { font-size: 14px; opacity: 0.9; font-weight: 500; }
'''

content = content.replace('</style>', stats_css + '\n    </style>')

# 3. تحديث JavaScript لبناء الإحصائيات ديناميكياً
stats_js = '''
        // ========== DYNAMIC STATS ==========
        const TOPIC_ICONS = {
            'random': '🎲', 'book_summary': '📚', 'article': '',
            'story': '📖', 'facts': '💡', 'tips': '🎯',
            'news': '', 'philosophy': '🤔', 'history': '🏛️',
            'science': '🔬', 'psychology': '🧠'
        };
        
        const TOPIC_LABELS = {
            'random': 'عشوائي', 'book_summary': 'ملخص كتاب', 'article': 'مقال',
            'story': 'قصة', 'facts': 'حقائق', 'tips': 'نصائح',
            'news': 'خبر تقني', 'philosophy': 'فلسفة', 'history': 'تاريخ',
            'science': 'علوم', 'psychology': 'علم نفس'
        };
        
        function buildDynamicStats() {
            const statsBar = document.getElementById('statsBar');
            if (!statsBar || allPosts.length === 0) return;
            
            // حساب عدد المنشورات لكل نوع
            const typeCounts = {};
            allPosts.forEach(post => {
                const type = post.type || 'random';
                typeCounts[type] = (typeCounts[type] || 0) + 1;
            });
            
            // بناء HTML
            let html = `
                <div class="stat-item ${currentFilter === 'all' ? 'active' : ''}" 
                     data-type="all" onclick="selectCategory('all')">
                    <div class="stat-icon">📊</div>
                    <div class="stat-number">${allPosts.length}</div>
                    <div class="stat-label">الإجمالي</div>
                </div>
            `;
            
            // إضافة كل نوع موجود
            Object.entries(typeCounts).forEach(([type, count]) => {
                const icon = TOPIC_ICONS[type] || '📄';
                const label = TOPIC_LABELS[type] || type;
                const isActive = currentFilter === type ? 'active' : '';
                
                html += `
                    <div class="stat-item ${isActive}" 
                         data-type="${type}" onclick="selectCategory('${type}')">
                        <div class="stat-icon">${icon}</div>
                        <div class="stat-number">${count}</div>
                        <div class="stat-label">${label}</div>
                    </div>
                `;
            });
            
            statsBar.innerHTML = html;
        }
        
        // تحديث selectCategory لتحديث الإحصائيات
        const originalSelectCategory = window.selectCategory;
        window.selectCategory = function(type) {
            currentFilter = type;
            buildDynamicStats();
            if (originalSelectCategory) originalSelectCategory(type);
            else { displayedCount = 0; displayPosts(true); }
        };
'''

# إضافة قبل آخر </script>
content = content.rreplace('</script>', stats_js + '\n    </script>', 1)

# 4. استدعاء buildDynamicStats بعد loadPosts
content = content.replace(
    'displayPosts(true);',
    'displayPosts(true); buildDynamicStats();'
)

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Dynamic stats added!")
PYEOF

git add -A && git commit -m "Add dynamic stats for all topics" && git push
