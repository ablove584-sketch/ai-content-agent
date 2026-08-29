#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html','r',encoding='utf-8') as f: c=f.read()

start = c.find('<style>')
marker = c.find('size-settings')

if start != -1 and marker != -1 and start < marker:
    end = c.find('-->', marker) + 3
    while end < len(c) and c[end] in '\r\n': end += 1
    removed = c[start+len('<style>'):end]
    s = removed.find('<style>')
    e = removed.find('</style>')
    settings_css = removed[s+len('<style>'):e] if (s!=-1 and e!=-1) else ''
    # إزالة البلوك المكسور من الأعلى
    c = c[:start+len('<style>')] + c[end:]
    # إضافته كآخر style قبل </body> (ليكون الأعلى أولوية)
    c = c.replace('</body>', '<style>' + settings_css + '</style>\n</body>', 1)
    with open('docs/index.html','w',encoding='utf-8') as f: f.write(c)
    print('✅ Style fixed - settings moved to end')
else:
    print('⚠️ broken block not found')
PYEOF

git add -A && git commit -m "Fix broken style tag, move size settings to end" && git push
