#!/bin/bash

# استبدال قسم Hero بكود الإعلانات الديناميكي
python3 << 'PYEOF'
import re

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# إزالة قسم Hero القديم
hero_pattern = r'<section class="hero">.*?</section>'
content = re.sub(hero_pattern, '', content, flags=re.DOTALL)

# إضافة قسم الإعلانات الجديد بعد header
ads_section = '''
        <!-- Dynamic Ads Section -->
        <section id="adsContainer" style="display:none; margin: 20px 0;">
            <div class="ad-banner" id="adBanner">
                <button class="ad-close" onclick="closeAd()" title="إغلاق">✕</button>
                <a href="#" id="adLink" target="_blank" rel="noopener">
                    <img src="" alt="إعلان" id="adImage" class="ad-image">
                    <div class="ad-content">
                        <h3 id="adTitle"></h3>
                        <p id="adDescription"></p>
                        <span class="ad-badge">إعلان</span>
                    </div>
                </a>
            </div>
        </section>
'''

# إدراج بعد header
content = content.replace('</header>', '</header>\n' + ads_section)

# إضافة CSS للإعلانات قبل </style>
ads_css = '''
        /* Ads Section */
        .ad-banner {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            padding: 30px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            animation: slideDown 0.5s ease;
        }
        .ad-banner::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 70%);
            animation: pulse 4s ease-in-out infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 0.5; }
            50% { transform: scale(1.1); opacity: 0.8; }
        }
        .ad-banner a {
            display: flex;
            align-items: center;
            gap: 30px;
            text-decoration: none;
            color: white;
            position: relative;
            z-index: 2;
        }
        .ad-image {
            width: 300px;
            height: 200px;
            object-fit: cover;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.2);
            flex-shrink: 0;
        }
        .ad-content {
            flex: 1;
        }
        .ad-content h3 {
            font-size: 28px;
            margin-bottom: 15px;
            font-weight: 700;
        }
        .ad-content p {
            font-size: 16px;
            opacity: 0.95;
            line-height: 1.6;
            margin-bottom: 20px;
        }
        .ad-badge {
            display: inline-block;
            background: rgba(255,255,255,0.2);
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }
        .ad-close {
            position: absolute;
            top: 15px;
            left: 15px;
            background: rgba(255,255,255,0.2);
            border: none;
            width: 35px;
            height: 35px;
            border-radius: 50%;
            color: white;
            font-size: 18px;
            cursor: pointer;
            z-index: 10;
            transition: background 0.3s;
        }
        .ad-close:hover {
            background: rgba(255,255,255,0.3);
        }
        @media (max-width: 768px) {
            .ad-banner a {
                flex-direction: column;
                gap: 20px;
            }
            .ad-image {
                width: 100%;
                height: 180px;
            }
            .ad-content h3 {
                font-size: 22px;
            }
        }
'''

content = content.replace('</style>', ads_css + '\n    </style>')

# إضافة JavaScript لتحميل الإعلانات قبل </script> الأخير
ads_js = '''
        // ========== ADS SYSTEM ==========
        let currentAd = null;
        
        async function loadAds() {
            try {
                const response = await fetch('ads.json?t=' + Date.now());
                if (!response.ok) return;
                
                const ads = await response.json();
                const now = new Date();
                const today = now.toISOString().split('T')[0];
                
                // البحث عن إعلان نشط وصالح
                const activeAd = ads.find(ad => {
                    if (!ad.active) return false;
                    if (ad.startDate && ad.startDate > today) return false;
                    if (ad.endDate && ad.endDate < today) return false;
                    return true;
                });
                
                if (activeAd) {
                    currentAd = activeAd;
                    document.getElementById('adsContainer').style.display = 'block';
                    document.getElementById('adTitle').textContent = activeAd.title;
                    document.getElementById('adDescription').textContent = activeAd.description;
                    document.getElementById('adImage').src = activeAd.image;
                    document.getElementById('adLink').href = activeAd.link;
                } else {
                    document.getElementById('adsContainer').style.display = 'none';
                }
            } catch (error) {
                console.log('Ads loading error:', error);
                document.getElementById('adsContainer').style.display = 'none';
            }
        }
        
        function closeAd() {
            document.getElementById('adsContainer').style.display = 'none';
            localStorage.setItem('adClosed_' + (currentAd?.id || ''), Date.now());
        }
        
        // تحميل الإعلانات
        loadAds();
        setInterval(loadAds, 5 * 60 * 1000);
'''

# إضافة قبل آخر </script>
content = content.rreplace('</script>', ads_js + '\n    </script>', 1)

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Ads system added successfully!")
PYEOF

git add -A && git commit -m "Add dynamic ads system" && git push
