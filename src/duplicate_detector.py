import re
import math
from typing import List, Dict, Any, Set, Tuple
from collections import Counter


class DuplicateDetector:
    def __init__(self, threshold=0.78):
        self.threshold = threshold
    
    def normalize_text(self, text):
        if not text:
            return ""
        text = text.lower()
        text = re.sub(r'\s+', ' ', text)
        text = re.sub(r'[^\w\s\u0600-\u06FF]', '', text)
        text = re.sub(r'[\u064B-\u065F]', '', text)
        return text.strip()
    
    def tokenize(self, text):
        normalized = self.normalize_text(text)
        return normalized.split()
    
    def get_ngrams(self, text, n=3):
        normalized = self.normalize_text(text)
        return set(normalized[i:i+n] for i in range(len(normalized) - n + 1))
    
    def get_shingles(self, text, n=3):
        tokens = self.tokenize(text)
        if len(tokens) < n:
            return set(tokens)
        return set(' '.join(tokens[i:i+n]) for i in range(len(tokens) - n + 1))
    
    def jaccard_similarity(self, set1, set2):
        if not set1 or not set2:
            return 0.0
        intersection = len(set1.intersection(set2))
        union = len(set1.union(set2))
        return intersection / union if union > 0 else 0.0
    
    def cosine_similarity(self, vec1, vec2):
        all_terms = set(vec1.keys()) | set(vec2.keys())
        if not all_terms:
            return 0.0
        dot_product = sum(vec1.get(term, 0) * vec2.get(term, 0) for term in all_terms)
        magnitude1 = math.sqrt(sum(v**2 for v in vec1.values()))
        magnitude2 = math.sqrt(sum(v**2 for v in vec2.values()))
        if magnitude1 == 0 or magnitude2 == 0:
            return 0.0
        return dot_product / (magnitude1 * magnitude2)
    
    def tf_vector(self, tokens):
        return dict(Counter(tokens))
    
    def keyword_similarity(self, keywords1, keywords2):
        if not keywords1 or not keywords2:
            return 0.0
        set1 = set(kw.lower().strip() for kw in keywords1)
        set2 = set(kw.lower().strip() for kw in keywords2)
        return self.jaccard_similarity(set1, set2)
    
    def title_similarity(self, title1, title2):
        norm1 = self.normalize_text(title1)
        norm2 = self.normalize_text(title2)
        if norm1 == norm2:
            return 1.0
        tokens1 = self.tokenize(title1)
        tokens2 = self.tokenize(title2)
        if not tokens1 or not tokens2:
            return 0.0
        token_jaccard = self.jaccard_similarity(set(tokens1), set(tokens2))
        ngrams1 = self.get_ngrams(title1, n=3)
        ngrams2 = self.get_ngrams(title2, n=3)
        ngram_sim = self.jaccard_similarity(ngrams1, ngrams2)
        return max(token_jaccard, ngram_sim)
    
    def content_similarity(self, content1, content2):
        norm1 = self.normalize_text(content1)
        norm2 = self.normalize_text(content2)
        if norm1 == norm2:
            return 1.0
        tokens1 = self.tokenize(content1)
        tokens2 = self.tokenize(content2)
        tf1 = self.tf_vector(tokens1)
        tf2 = self.tf_vector(tokens2)
        cosine_sim = self.cosine_similarity(tf1, tf2)
        shingles1 = self.get_shingles(content1, n=3)
        shingles2 = self.get_shingles(content2, n=3)
        jaccard_sim = self.jaccard_similarity(shingles1, shingles2)
        ngrams1 = self.get_ngrams(content1, n=5)
        ngrams2 = self.get_ngrams(content2, n=5)
        ngram_sim = self.jaccard_similarity(ngrams1, ngrams2)
        return 0.4 * cosine_sim + 0.3 * jaccard_sim + 0.3 * ngram_sim
    
    def check_duplicate(self, new_post, previous_posts):
        if not previous_posts:
            return False, 0.0, {}
        
        max_score = 0.0
        best_match = None
        best_details = {}
        
        for old_post in previous_posts:
            title_sim = self.title_similarity(new_post.get('title', ''), old_post.get('title', ''))
            content_sim = self.content_similarity(new_post.get('content', ''), old_post.get('content', ''))
            keyword_sim = self.keyword_similarity(
                new_post.get('keywords', []),
                old_post.get('keywords', [])
            )
            topic_match = 1.0 if new_post.get('topic', '').lower() == old_post.get('topic', '').lower() else 0.0
            angle_match = 1.0 if new_post.get('angle', '').lower() == old_post.get('angle', '').lower() else 0.0
            core_idea_sim = self.content_similarity(
                new_post.get('core_idea', ''),
                old_post.get('core_idea', '')
            )
            
            overall_score = (
                0.20 * title_sim +
                0.35 * content_sim +
                0.15 * keyword_sim +
                0.10 * topic_match +
                0.10 * angle_match +
                0.10 * core_idea_sim
            )
            
            if overall_score > max_score:
                max_score = overall_score
                best_match = old_post
                best_details = {
                    'title_similarity': title_sim,
                    'content_similarity': content_sim,
                    'keyword_similarity': keyword_sim,
                    'topic_match': topic_match,
                    'angle_match': angle_match,
                    'core_idea_similarity': core_idea_sim,
                    'overall_score': overall_score,
                    'matched_post_id': old_post.get('id')
                }
        
        is_duplicate = max_score >= self.threshold
        return is_duplicate, max_score, best_details
    
    def generate_fingerprint(self, post):
        elements = [
            self.normalize_text(post.get('title', '')),
            self.normalize_text(post.get('core_idea', '')),
            ','.join(sorted(kw.lower().strip() for kw in post.get('keywords', []))),
        ]
        fingerprint_text = '|'.join(elements)
        return fingerprint_text.replace(' ', '_')[:200]


def check_duplicate(new_post, previous_posts, threshold=0.78):
    detector = DuplicateDetector(threshold)
    return detector.check_duplicate(new_post, previous_posts)
