import os
import json
import re
import requests
import random
from typing import Dict, Any, List, Optional
from src.config import Config

# قائمة النماذج المجانية على OpenRouter (مرتبة حسب الجودة)
OPENROUTER_FREE_MODELS = [
    "meta-llama/llama-3.1-8b-instruct:free",  # الأفضل
    "meta-llama/llama-3-8b-instruct:free",    # جيد جداً
    "google/gemma-7b-it:free",                # جيد
    "mistralai/mistral-7b-instruct:free",     # جيد
    "qwen/qwen-2-7b-instruct:free",           # جيد للعربية
    "microsoft/phi-3-mini-128k-instruct:free", # سريع
]

class ContentGenerator:
    def __init__(self, config: Config):
        self.config = config
        self.gemini_key = config.GEMINI_API_KEY
        self.openrouter_key = os.getenv("OPENROUTER_API_KEY", "")
        self.model = config.GEMINI_MODEL
        
        # خلط النماذج عشوائياً لتوزيع الحمل
        self.openrouter_models = OPENROUTER_FREE_MODELS.copy()
        random.shuffle(self.openrouter_models)
        
        print(f"Gemini Model: {self.model}")
        if self.openrouter_key:
            print(f"OpenRouter: {len(self.openrouter_models)} free models available")
            print("Models: " + ", ".join(self.openrouter_models[:3]) + "...")

    def build_prompt(self, recent_posts: List[Dict[str, Any]]) -> str:
        memory = ""
        if recent_posts:
            memory = "\n\n**المنشورات السابقة (لا تكرر هذه الأفكار):**\n"
            for i, post in enumerate(recent_posts[:self.config.MEMORY_CONTEXT_LIMIT], 1):
                memory += f"\n{i}. {post.get('title', '')}\n"
                memory += f"   الفكرة: {post.get('core_idea', '')}\n"

        return f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة لـ {self.config.CONTENT_AUDIENCE}.

**الموضوع:** {self.config.CONTENT_TOPIC}
**الأسلوب:** {self.config.CONTENT_STYLE}
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
        if not self.gemini_key and not self.openrouter_key:
            print("No API keys configured")
            return None

        prompt = self.build_prompt(recent_posts)

        # 1️⃣ حاول مع Gemini أولاً
        if self.gemini_key:
            print("\n Trying Gemini API...")
            result = self._generate_gemini(prompt)
            if result:
                print("✅ Content generated with Gemini")
                return result
            print(" Gemini failed, trying OpenRouter...")

        # 2️⃣ حاول مع نماذج OpenRouter المجانية
        if self.openrouter_key:
            print(f"\n Trying {len(self.openrouter_models)} OpenRouter free models...")
            for i, model in enumerate(self.openrouter_models, 1):
                print(f"\n  Attempt {i}/{len(self.openrouter_models)}: {model}")
                result = self._generate_openrouter(prompt, model)
                if result:
                    print(f"✅ Content generated with OpenRouter ({model})")
                    return result
                print(f"  ❌ {model} failed, trying next...")

        print("\n❌ All models failed")
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
                return None

            result = response.json()
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                return self.extract_json(content_text)
            return None
        except Exception as e:
            print(f"  Error: {e}")
            return None

    def _generate_openrouter(self, prompt: str, model: str) -> Optional[Dict[str, Any]]:
        url = "https://openrouter.ai/api/v1/chat/completions"
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.openrouter_key}",
            "HTTP-Referer": "https://github.com/ablove584-sketch/ai-content-agent",
        }
        data = {
            "model": model,
            "messages": [
                {"role": "system", "content": "أنت كاتب محتوى محترف. أعد النتيجة بصيغة JSON فقط."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.8,
            "max_tokens": 2048,
        }

        try:
            response = requests.post(url, headers=headers, json=data, timeout=90)

            if response.status_code != 200:
                print(f"    API error: {response.status_code}")
                return None

            result = response.json()
            content_text = result["choices"][0]["message"]["content"]
            return self.extract_json(content_text)
        except Exception as e:
            print(f"    Error: {e}")
            return None


def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    generator = ContentGenerator(config)
    return generator.generate(config, recent_posts)
