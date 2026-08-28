#!/bin/bash
python3 << 'PYEOF'
with open('docs/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. CSS بأسلوب انستقرام
css = '''
        /* ========== INSTAGRAM STYLE ========== */
        .insta-card { background: var(--card-bg, #fff); border-radius: 14px; box-shadow: 0 3px 15px rgba(0,0,0,0.08); overflow: hidden; animation: fadeIn .5s ease; max-width: 520px; margin: 0 auto; width: 100%; }
        .insta-header { display: flex; align-items: center; gap: 10px; padding: 12px 14px; }
        .insta-avatar-ring { width: 44px; height: 44px; border-radius: 50%; padding: 3px; background: linear-gradient(45deg, #f09433, #e6683c, #dc2743, #cc2366, #bc1888); flex-shrink: 0; }
        .insta-avatar { width: 100%; height: 100%; border-radius: 50%; border: 2px solid var(--card-bg, #fff); display: flex; align-items: center; justify-content: center; font-size: 18px; background: linear-gradient(135deg, #667eea, #764ba2); }
        .insta-user { flex: 1; text-align: right; }
        .insta-username { font-weight: 700; font-size: 14px; color: var(--text-primary, #333); }
        .insta-location { font-size: 12px; color: var(--text-muted, #999); }
        .insta-menu { background: none; border: none; font-size: 20px; cursor: pointer; color: var(--text-primary, #333); }
        .insta-image { position: relative; width: 100%; aspect-ratio: 1/1; background: #000; cursor: pointer; overflow: hidden; }
        .insta-image img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .insta-heart-burst { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%) scale(0); font-size: 90px; opacity: 0; pointer-events: none; text-shadow: 0 5px 20px rgba(0,0,0,.4); }
        .insta-heart-burst.show { animation: heartBurst .8s ease; }
        @keyframes heartBurst { 0% {transform:translate(-50%,-50%) scale(0);opacity:0;} 15% {transform:translate(-50%,-50%) scale(1.2);opacity:1;} 30% {transform:translate(-50%,-50%) scale(1);} 70% {transform:translate(-50%,-50%) scale(1);opacity:1;} 100% {transform:translate(-50%,-50%) scale(0);opacity:0;} }
        .insta-actions { display: flex; align-items: center; gap: 14px; padding: 10px 14px 4px; }
        .insta-actions button { background: none; border: none; font-size: 24px; cursor: pointer; transition: transform .2s; padding: 0; }
        .insta-actions button:hover { transform: scale(1.15); }
        .insta-save { margin-inline-start: auto; }
        .insta-likes { padding: 0 14px; font-size: 14px; color: var(--text-primary, #333); }
        .insta-caption { padding: 6px 14px; font-size: 14px; color: var(--text-secondary, #555); line-height: 1.6; }
        .insta-title { font-weight: 700; color: var(--text-primary, #333); display: block; margin: 4px 0; font-size: 15px; }
        .insta-more { background: none; border: none; color: var(--text-muted, #999); cursor: pointer; font-size: 13px; padding: 0; }
        .insta-hashtags { color: #3897f0; font-size: 13px; margin-top: 4px; display: flex; flex-wrap: wrap; gap: 6px; }
        .insta-comments-link { padding: 4px 14px; font-size: 13px; color: var(--text-muted, #999); cursor: pointer; }
        .insta-time { padding: 0 14px 10px; font-size: 11px; color: var(--text-muted, #999); }
        .insta-add-comment { display: flex; gap: 8px; border-top: 1px solid var(--border-color, #e2e8f0); padding: 10px 14px; }
        .insta-add-comment input { flex: 1; border: none; background: transparent; color: var(--text-primary, #333); font-size: 14px; outline: none; }
        .insta-add-comment button { background: none; border: none; color: #3897f0; font-weight: 700; cursor: pointer; font-size: 14px; }
'''
if '.insta-card' not in content:
    content = content.replace('</style>', css + '    </style>', 1)
    print('✅ CSS added')

# 2. JavaScript للقالب الجديد
js = '''
        // ========== INSTAGRAM CARD SYSTEM ==========
        function getLikes(id) { return parseInt(localStorage.getItem('likes_' + id) || '0'); }
        function isLiked(id) { return localStorage.getItem('liked_' + id) === '1'; }
        if (typeof window.isFavorite !== 'function') window.isFavorite = function(id) { try { return JSON.parse(localStorage.getItem('favorites') || '[]').includes(id); } catch (e) { return false; } };
        if (typeof window.toggleFavorite !== 'function') window.toggleFavorite = function(id) { try { var f = JSON.parse(localStorage.getItem('favorites') || '[]'); var i = f.indexOf(id); if (i > -1) f.splice(i, 1); else f.push(id); localStorage.setItem('favorites', JSON.stringify(f)); } catch (e) {} };
        if (typeof window.getComments !== 'function') window.getComments = function(id) { try { return JSON.parse(localStorage.getItem('comments_' + id) || '[]'); } catch (e) { return []; } };
        if (typeof window.saveComments !== 'function') window.saveComments = function(id, c) { localStorage.setItem('comments_' + id, JSON.stringify(c)); };
        if (typeof window.shareTo !== 'function') window.shareTo = function(p) { var url = encodeURIComponent(location.href); var t = encodeURIComponent('alkinani'); var urls = { whatsapp: 'https://wa.me/?text=' + t + '%20' + url, telegram: 'https://t.me/share/url?url=' + url + '&text=' + t, twitter: 'https://twitter.com/intent/tweet?text=' + t + '&url=' + url, facebook: 'https://www.facebook.com/sharer/sharer.php?u=' + url, linkedin: 'https://www.linkedin.com/sharing/share-offsite/?url=' + url }; window.open(urls[p] || urls.telegram, '_blank'); };
        
        function toggleLike(id) {
            var likes = getLikes(id);
            if (isLiked(id)) { likes = Math.max(0, likes - 1); localStorage.removeItem('liked_' + id); }
            else { likes++; localStorage.setItem('liked_' + id, '1'); }
            localStorage.setItem('likes_' + id, likes);
            updateLikeUI(id);
        }
        function doubleTapLike(id, el) {
            if (!isLiked(id)) { localStorage.setItem('likes_' + id, getLikes(id) + 1); localStorage.setItem('liked_' + id, '1'); }
            var burst = el.querySelector('.insta-heart-burst');
            if (burst) { burst.classList.remove('show'); void burst.offsetWidth; burst.classList.add('show'); }
            setTimeout(function() { updateLikeUI(id); }, 700);
        }
        function updateLikeUI(id) {
            var card = document.querySelector('[data-insta-id="' + id + '"]');
            if (!card) return;
            var btn = card.querySelector('.insta-like-btn');
            var count = card.querySelector('.insta-likes-count');
            if (btn) btn.textContent = isLiked(id) ? '❤️' : '🤍';
            if (count) count.textContent = getLikes(id).toLocaleString('ar-EG') + ' إعجاب';
        }
        function quickComment(postId, input) {
            var text = input.value.trim();
            if (!text) return;
            var comments = getComments(postId);
            var name = localStorage.getItem('userName') || 'زائر';
            comments.unshift({ name: name, text: text, date: new Date().toLocaleString('ar-SA') });
            saveComments(postId, comments);
            input.value = '';
            if (typeof showToast === 'function') showToast('تمت إضافة التعليق 💬', 'success');
            var card = document.querySelector('[data-insta-id="' + postId + '"]');
            if (card) { var link = card.querySelector('.insta-comments-link'); if (link) link.textContent = 'عرض جميع التعليقات (' + comments.length + ')'; }
        }
        
        function createInstaCard(post, index) {
            var div = document.createElement('div');
            div.className = 'insta-card';
            div.setAttribute('data-insta-id', post.id);
            div.style.animationDelay = (index % 5) * 0.08 + 's';
            var imageUrl = (typeof TYPE_IMAGES !== 'undefined' && TYPE_IMAGES[post.type]) || 'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=600&q=70&auto=format';
            var icon = (typeof TYPE_ICONS !== 'undefined' && TYPE_ICONS[post.type]) || '📄';
            var label = (typeof TYPE_LABELS !== 'undefined' && TYPE_LABELS[post.type]) || post.type || '';
            var commentsCount = getComments(post.id).length;
            var contentText = post.content || '';
            var preview = contentText.length > 90 ? contentText.substring(0, 90) + '... ' : contentText;
            var tags = (post.hashtags || []).slice(0, 4);
            div.innerHTML = 
                '<div class="insta-header">' +
                    '<div class="insta-avatar-ring"><div class="insta-avatar">' + icon + '</div></div>' +
                    '<div class="insta-user">' +
                        '<div class="insta-username">alkinani</div>' +
                        '<div class="insta-location">' + label + ' • ' + (post.date || '') + '</div>' +
                    '</div>' +
                    '<button class="insta-menu" onclick="openPost(' + post.id + ')">⋯</button>' +
                '</div>' +
                '<div class="insta-image" ondblclick="doubleTapLike(' + post.id + ', this)">' +
                    '<img src="' + imageUrl + '" alt="" loading="lazy">' +
                    '<div class="insta-heart-burst">❤️</div>' +
                '</div>' +
                '<div class="insta-actions">' +
                    '<button class="insta-like-btn" onclick="toggleLike(' + post.id + ')">' + (isLiked(post.id) ? '❤️' : '🤍') + '</button>' +
                    '<button onclick="openPost(' + post.id + ')">💬</button>' +
                    '<button onclick="shareTo(\'telegram\')">📤</button>' +
                    '<button class="insta-save" onclick="toggleFavorite(' + post.id + ')">' + (isFavorite(post.id) ? '🔖' : '🏷️') + '</button>' +
                '</div>' +
                '<div class="insta-likes"><strong class="insta-likes-count">' + getLikes(post.id).toLocaleString('ar-EG') + ' إعجاب</strong></div>' +
                '<div class="insta-caption">' +
                    '<span class="insta-username">alkinani</span>' +
                    '<span class="insta-title">' + (post.title || '') + '</span>' +
                    '<span>' + preview + '</span>' +
                    (contentText.length > 90 ? '<button class="insta-more" onclick="openPost(' + post.id + ')">المزيد</button>' : '') +
                    (tags.length ? '<div class="insta-hashtags">' + tags.map(function(h) { return '<span>' + h + '</span>'; }).join('') + '</div>' : '') +
                '</div>' +
                '<div class="insta-comments-link" onclick="openPost(' + post.id + ')">عرض جميع التعليقات (' + commentsCount + ')</div>' +
                '<div class="insta-time">' + (post.date || '') + '</div>' +
                '<div class="insta-add-comment">' +
                    '<input type="text" placeholder="أضف تعليقاً..." onkeydown="if(event.key===\'Enter\') quickComment(' + post.id + ', this)">' +
                    '<button onclick="quickComment(' + post.id + ', this.previousElementSibling)">نشر</button>' +
                '</div>';
            return div;
        }
        window.createPostCard = createInstaCard;
'''
if 'createInstaCard' not in content:
    parts = content.rsplit('</script>', 1)
    content = parts[0] + js + '    </script>' + (parts[1] if len(parts) > 1 else '')
    print('✅ JS added')

with open('docs/index.html', 'w', encoding='utf-8') as f:
    f.write(content)
print('✅ Instagram style applied!')
PYEOF

git add -A && git commit -m "Instagram-style post cards" && git push
