import os
import json
import re
import requests
import time
import random
from typing import Dict, Any, List, Optional
from src.config import Config

class ContentGenerator:
    def __init__(self, config: Config):
        self.config = config
        self.gemini_key = config.GEMINI_API_KEY
        self.model = config.GEMINI_MODEL
        
        # قراءة نوع المحتوى من البيئة
        self.content_type = os.getenv("CONTENT_TYPE", "random")
        self.book_name = os.getenv("BOOK_NAME", "")
        self.custom_topic = os.getenv("CUSTOM_TOPIC", "")
        
        print(f"Gemini Model: {self.model}")
        print(f"Content Type: {self.content_type}")
        if self.book_name:
            print(f"Book: {self.book_name}")
        if self.custom_topic:
            print(f"Custom Topic: {self.custom_topic}")

    def build_prompt(self, recent_posts: List[Dict[str, Any]]) -> str:
        memory = ""
        if recent_posts:
            memory = "\n\n**المنشورات السابقة (لا تكرر هذه الأفكار):**\n"
            for i, post in enumerate(recent_posts[:self.config.MEMORY_CONTEXT_LIMIT], 1):
                memory += f"\n{i}. {post.get('title', '')}\n"
                memory += f"   الفكرة: {post.get('core_idea', '')}\n"

        # تحديد الموضوع بناءً على النوع
        if self.content_type == "book_summary" and self.book_name:
            topic = f"ملخص كتاب: {self.book_name}"
            style = "ملخص احترافي يبرز الأفكار الرئيسية والدروس المستفادة"
        elif self.custom_topic:
            topic = self.custom_topic
            style = self.config.CONTENT_STYLE
        else:
            topic = self.config.CONTENT_TOPIC
            style = self.config.CONTENT_STYLE

        # تخصيص الـ prompt حسب النوع
        type_instructions = self._get_type_instructions()

        return f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة لـ {self.config.CONTENT_AUDIENCE}.

**نوع المحتوى:** {self.content_type}
{type_instructions}

**الموضوع:** {topic}
**الأسلوب:** {style}
**اللغة:** {self.config.CONTENT_LANGUAGE}

{memory}

**مهم جداً:** لا تكرر الأفكار السابقة. قدم زاوية جديدة تماماً.

**أعد النتيجة بصيغة JSON فقط** (بدون أي نص إضافي):

```json
{{
  "title": "العنوان",
  "topic": "الموضوع الفرعي",
  "angle": "الزاوية",
  "core_idea": "الفكرة الأساسية",
  "keywords": ["كلمة1", "كلمة2"],
  "content": "المحتوى الكامل هنا",
  "hashtags": ["#هاشتاج1", "#هاشتاج2"]
}}
```"""

    def _get_type_instructions(self) -> str:
        """تعليمات مخصصة حسب نوع المحتوى"""
        instructions = {
            "book_summary": "اكتب ملخصاً احترافياً للكتاب يبرز:\n- الأفكار الرئيسية\n- الدروس المستفادة\n- اقتباسات ملهمة\n- تطبيق عملي للأفكار",
            "article": "اكتب مقالاً احترافياً يحتوي على:\n- مقدمة جذابة\n- نقاط رئيسية منظمة\n- خاتمة قوية",
            "story": "اكتب قصة مشوقة تحتوي على:\n- بداية مثيرة\n- تطور الأحداث\n- نهاية مؤثرة أو درس مستفاد",
            "facts": "اكتب منشوراً يحتوي على:\n- 5-7 حقائق غريبة ومثيرة\n- شرح مختصر لكل حقيقة\n- مصدر أو سياق",
            "tips": "اكتب منشوراً يحتوي على:\n- 5-10 نصائح عملية\n- شرح مختصر لكل نصيحة\n- أمثلة تطبيقية",
            "news": "اكتب خبراً تقنياً يحتوي على:\n- العنوان الرئيسي\n- التفاصيل المهمة\n- التأثير على المستقبل",
            "philosophy": "اكتب منشوراً فلسفياً يحتوي على:\n- سؤال فلسفي عميق\n- تحليل متعدد الزوايا\n- استنتاج ملهم",
            "history": "اكتب منشوراً تاريخياً يحتوي على:\n- الحدث التاريخي\n- السياق والظروف\n- الدروس المستفادة",
            "science": "اكتب منشوراً علمياً يحتوي على:\n- الاكتشاف أو النظرية\n- الشرح المبسط\n- التطبيقات العملية",
            "psychology": "اكتب منشوراً عن علم النفس يحتوي على:\n- المفهوم النفسي\n- أمثلة من الحياة\n- تطبيقات عملية",
            "random": "اكتب منشوراً متنوعاً ومفيداً"
        }
        return instructions.get(self.content_type, "اكتب منشوراً احترافياً ومفيداً")

    def extract_json(self, text: str) -> Optional[Dict[str, Any]]:
        text = text.strip()
        text = re.sub(r'^```json\s*', '', text, flags=re.MULTILINE)
        text = re.sub(r'^```\s*', '', text, flags=re.MULTILINE)
        text = re.sub(r'```$', '', text, flags=re.MULTILINE)
        text = text.strip()

        try:
            return json.loads(text)
        except:
            pass

        match = re.search(r'\{[\s\S]*\}', text)
        if match:
            try:
                return json.loads(match.group(0))
            except:
                pass

        return None

    def generate(self, config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        if not self.gemini_key:
            print("No Gemini API key configured")
            return None

        prompt = self.build_prompt(recent_posts)

        max_retries = 6
        for attempt in range(1, max_retries + 1):
            print(f"\n Attempt {attempt}/{max_retries} with Gemini...")
            result = self._generate_gemini(prompt)
            
            if result:
                print(f"✅ Content generated with Gemini (attempt {attempt})")
                return result
            
            if attempt < max_retries:
                wait_time = 30
                print(f"  Waiting {wait_time}s before retry...")
                time.sleep(wait_time)

        print("\n❌ All attempts failed")
        return None

    def _generate_gemini(self, prompt: str) -> Optional[Dict[str, Any]]:
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{self.model}:generateContent"
        headers = {"Content-Type": "application/json"}
        params = {"key": self.gemini_key}
        data = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {
                "temperature": 0.8,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048,
            }
        }

        try:
            response = requests.post(url, headers=headers, params=params, json=data, timeout=90)

            if response.status_code == 429:
                print("  Rate limit exceeded")
                return None
            elif response.status_code == 503:
                print("  Service unavailable (high demand)")
                return None
            elif response.status_code != 200:
                print(f"  API error: {response.status_code}")
                print(f"  Response: {response.text[:200]}")
                return None

            result = response.json()
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                return self.extract_json(content_text)
            return None
        except Exception as e:
            print(f"  Error: {e}")
            return None


def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    generator = ContentGenerator(config)
    return generator.generate(config, recent_posts)
