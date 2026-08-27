import os
import json
import requests
from typing import Dict, Any, List, Optional
from src.config import Config


class ContentGenerator:
    """Generate content using Google Gemini API"""
    
    def __init__(self, api_key: str, model: str = "gemini-2.0-flash-exp"):
        self.api_key = api_key
        self.model = model
        self.api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    
    def build_prompt(self, config: Config, recent_posts: List[Dict[str, Any]]) -> str:
        """Build a comprehensive prompt for Gemini"""
        
        # Build memory context from recent posts
        memory_context = ""
        if recent_posts:
            memory_context = "\n\n**المنشورات السابقة (لا تكرر هذه الأفكار):**\n"
            for i, post in enumerate(recent_posts[:config.MEMORY_CONTEXT_LIMIT], 1):
                memory_context += f"\n{i}. العنوان: {post.get('title', '')}\n"
                memory_context += f"   الفكرة الأساسية: {post.get('core_idea', '')}\n"
                memory_context += f"   الزاوية: {post.get('angle', '')}\n"
                memory_context += f"   الكلمات المفتاحية: {post.get('keywords', '')}\n"
                memory_context += "---\n"
        
        prompt = f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة وغير مكررة لـ {config.CONTENT_AUDIENCE}.

**الموضوع العام:** {config.CONTENT_TOPIC}

**أسلوب الكتابة:** {config.CONTENT_STYLE}

**اللغة:** {config.CONTENT_LANGUAGE}

{memory_context}

**تعليمات مهمة جداً:**

1. **لا تكرر الأفكار السابقة** - حتى لو غيرت الكلمات، الفكرة يجب أن تكون جديدة 100%
2. **تغيير الكلمات فقط لا يعني أن الفكرة جديدة** - ركز على الجوهر
3. **ابحث عن زاوية جديدة تماماً** لم تُناقش في المنشورات السابقة
4. **استخدم أمثلة مختلفة** عن الأمثلة السابقة
5. **قدم منظوراً جديداً** ومختلفاً

**المطلوب:**

أنشئ منشوراً جديداً تماماً يتكون من:
- عنوان جذاب ومميز
- موضوع فرعي محدد
- زاوية فريدة في الطرح
- فكرة أساسية جديدة
- محتوى مفيد (300-500 كلمة)
- 3-5 كلمات مفتاحية
- 3-5 هاشتاجات

**تنبيه:** إذا كررت أي فكرة سابقة، سأرفض المنشور وأطلب منك محاولة أخرى.

**أعد النتيجة بصيغة JSON فقط** بهذا الشكل:

```json
{{
  "title": "العنوان هنا",
  "topic": "الموضوع الفرعي",
  "angle": "الزاوية",
  "core_idea": "الفكرة الأساسية",
  "keywords": ["كلمة1", "كلمة2", "كلمة3"],
  "content": "المحتوى الكامل هنا",
  "hashtags": ["#هاشتاج1", "#هاشتاج2"]
}}
```"""
        
        return prompt
    
    def generate(self, config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        """Generate content using Gemini API"""
        
        if not self.api_key:
            print("❌ GEMINI_API_KEY not set")
            return None
        
        prompt = self.build_prompt(config, recent_posts)
        
        headers = {
            "Content-Type": "application/json"
        }
        
        params = {
            "key": self.api_key
        }
        
        data = {
            "contents": [{
                "parts": [{
                    "text": prompt
                }]
            }],
            "generationConfig": {
                "temperature": 0.8,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 2048,
            }
        }
        
        try:
            print("📤 Sending request to Gemini API...")
            response = requests.post(
                self.api_url,
                headers=headers,
                params=params,
                json=data,
                timeout=30
            )
            
            if response.status_code == 401:
                print("❌ Invalid API key")
                return None
            elif response.status_code == 429:
                print("❌ Rate limit exceeded. Try again later.")
                return None
            elif response.status_code != 200:
                print(f"❌ API error: {response.status_code}")
                print(f"Response: {response.text}")
                return None
            
            result = response.json()
            
            # Extract text from response
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                
                # Try to parse as JSON
                try:
                    # Remove markdown code blocks if present
                    content_text = content_text.strip()
                    if content_text.startswith("```json"):
                        content_text = content_text[7:]
                    if content_text.startswith("```"):
                        content_text = content_text[3:]
                    if content_text.endswith("```"):
                        content_text = content_text[:-3]
                    content_text = content_text.strip()
                    
                    generated_content = json.loads(content_text)
                    
                    # Validate required fields
                    required_fields = ["title", "topic", "angle", "core_idea", "keywords", "content", "hashtags"]
                    missing_fields = [field for field in required_fields if field not in generated_content]
                    
                    if missing_fields:
                        print(f"️ Missing fields: {missing_fields}")
                        return None
                    
                    print("✓ Content generated successfully")
                    return generated_content
                    
                except json.JSONDecodeError as e:
                    print(f"❌ Failed to parse JSON response: {e}")
                    print(f"Raw response: {content_text[:200]}...")
                    return None
            else:
                print("❌ No content generated")
                return None
                
        except requests.exceptions.Timeout:
            print("❌ Request timeout")
            return None
        except requests.exceptions.RequestException as e:
            print(f"❌ Request failed: {e}")
            return None


def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    """Convenience function to generate content"""
    generator = ContentGenerator(config.GEMINI_API_KEY, config.GEMINI_MODEL)
    return generator.generate(config, recent_posts)
