#!/bin/bash

# استبدال div الشعار بـ img في header
sed -i 's|<div class="logo">alkinani</div>|<div class="logo-container"><img src="logo.png" alt="alkinani" class="logo-img"></div>|g' docs/index.html

# إضافة CSS للشعار
sed -i '/\.logo {/i \
.logo-container { display: flex; justify-content: center; margin-bottom: 15px; }\
.logo-img { max-width: 280px; height: auto; filter: drop-shadow(0 4px 12px rgba(102,126,234,0.3)); transition: transform 0.3s; }\
.logo-img:hover { transform: scale(1.05); }' docs/index.html

git add -A && git commit -m "Replace text logo with image logo" && git push
