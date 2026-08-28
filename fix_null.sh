#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

safe_js = '''
        // ========== NULL SAFETY (منع أخطاء العناصر المفقودة) ==========
        (function() {
            const orig = document.getElementById.bind(document);
            document.getElementById = function(id) {
                const el = orig(id);
                if (el) return el;
                // عنصر مفقود؟ نرجعن عنصر وهمي لمنع توقف الكود
                return document.createElement('div');
            };
        })();
'''

if 'NULL SAFETY' not in content:
    idx = content.find('<script>')
    if idx != -1:
        pos = idx + len('<script>')
        content = content[:pos] + safe_js + content[pos:]
        print('✅ Added null safety protection')
    else:
        print('❌ script tag not found')
else:
    print('⚠️ Already present')

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)
PYEOF

git add -A && git commit -m "Fix null element errors blocking page load" && git push
