#!/bin/bash

python3 << 'PYEOF'
import re

with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. استبدال قسم Hero بقسم إعلانات ديناميكي
hero_pattern = r'<section class="hero">.*?</section>'
new_hero = '''<section class="hero" id="heroAds" style="display:none;">
            <div class="hero-content">
                <button class="ad-close-btn" onclick="closeHeroAd()" title="إغلاق">✕</button>
                <a href="#" id="heroAdLink" target="_blank" rel="noopener" style="text-decoration:none;color:white;">
                    <img src="" alt="إعلان" id="heroAdImage" class="hero-ad-image" style="max-width:100%;border-radius:15px;margin-bottom:20px;display:none;">
                    <h2 id="heroAdTitle"></h2>
                    <p id="heroAdDescription"></p>
                    <span class="ad-badge" style="background:rgba(255,255,255,0.2);padding:5px 15px;border-radius:20px;font-size:12px;">إعلان</span>
                </a>
            </div>
        </section>'''

content = re.sub(hero_pattern, new_hero, content, flags=re.DOTALL)

# 2. إضافة JavaScript لتحميل الإعلانات
ads_js = '''
        // ========== ADS SYSTEM ==========
        let currentHeroAd = null;
        
        async function loadHeroAds() {
            try {
                const response = await fetch('ads.json?t=' + Date.now());
                if (!response.ok) {
                    document.getElementById('heroAds').style.display = 'none';
                    return;
                }
                
                const ads = await response.json();
                const now = new Date();
                const today = now.toISOString().split('T')[0];
                
                const activeAd = ads.find(ad => {
                    if (!ad.active) return false;
                    if (ad.startDate && ad.startDate > today) return false;
                    if (ad.endDate && ad.endDate < today) return false;
                    return true;
                });
                
                if (activeAd) {
                    currentHeroAd = activeAd;
                    document.getElementById('heroAds').style.display = 'block';
                    document.getElementById('heroAdTitle').textContent = activeAd.title;
                    document.getElementById('heroAdDescription').textContent = activeAd.description;
                    document.getElementById('heroAdLink').href = activeAd.link;
                    
                    if (activeAd.image) {
                        const img = document.getElementById('heroAdImage');
                        img.src = activeAd.image;
                        img.style.display = 'block';
                    }
                } else {
                    document.getElementById('heroAds').style.display = 'none';
                }
            } catch (error) {
                console.log('Ads error:', error);
                document.getElementById('heroAds').style.display = 'none';
            }
        }
        
        function closeHeroAd() {
            document.getElementById('heroAds').style.display = 'none';
            if (currentHeroAd) {
                localStorage.setItem('heroAdClosed_' + currentHeroAd.id, Date.now());
            }
        }
        
        loadHeroAds();
        setInterval(loadHeroAds, 5 * 60 * 1000);
'''

# إضافة قبل آخر </script>
content = content.rreplace('</script>', ads_js + '\n    </script>', 1)

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Hero ads system added!")
PYEOF

git add -A && git commit -m "Make Hero section dynamic - hides when no ads" && git push
