import os
import json
import re
import time
import requests
from typing import Dict, Any, List, Optional
from src.config import Config

class ContentGenerator:
    def __init__(self, api_key: str, model: str = "gemini-1.5-flash"):
        self.api_key = api_key
        self.model = model
        self.api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    
    def build_prompt(self, config: Config, recent_posts: List[Dict[str, Any]]) -> str:
        memory_context = ""
        if recent_posts:
            memory_context = "\n\n**المنشورات السابقة:**\n"
            for i, post in enumerate(recent_posts[:config.MEMORY_CONTEXT_LIMIT], 1):
                memory_context += f"\n{i}. {post.get('title', '')}\n"
        
        prompt = f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة لـ {config.CONTENT_AUDIENCE}.

**الموضوع:** {config.CONTENT_TOPIC}
**الأسلوب:** {config.CONTENT_STYLE}
**اللغة:** {config.CONTENT_LANGUAGE}

{memory_context}

**مهم:** لا تكرر الأفكار السابقة. قدم زاوية جديدة تماماً.

**أعد النتيجة بصيغة JSON فقط** بهذا الشكل:

```json
{{
  "title": "العنوان",
  "topic": "الموضوع",
  "angle": "الزاوية",
  "core_idea": "الفكرة الأساسية",
  "keywords": ["كلمة1", "كلمة2"],
  "content": "المحتوى الكامل",
  "hashtags": ["#هاشتاج1", "#هاشتاج2"]
}}
```"""
        
        return prompt
    
    def extract_json(self, text: str) -> Optional[Dict[str, Any]]:
        text = text.strip()
        
        try:
            return json.loads(text)
        except:
            pass
        
        text = re.sub(r'```json\s*', '', text)
        text = re.sub(r'```\s*', '', text)
        text = text.strip()
        
        try:
            return json.loads(text)
        except:
            pass
        
        json_match = re.search(r'\{[\s\S]*\}', text)
        if json_match:
            try:
                return json.loads(json_match.group(0))
            except:
                pass
        
        return None
    
    def generate(self, config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
        if not self.api_key:
            print("GEMINI_API_KEY not set")
            return None
        
        prompt = self.build_prompt(config, recent_posts)
        
        headers = {"Content-Type": "application/json"}
        params = {"key": self.api_key}
        
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
            print("Sending request to Gemini API...")
            response = requests.post(
                self.api_url, 
                headers=headers, 
                params=params, 
                json=data, 
                timeout=120
            )
            
            if response.status_code == 429:
                print("Rate limit exceeded. Waiting 120 seconds...")
                time.sleep(120)
                return None
            elif response.status_code != 200:
                print(f"API error: {response.status_code}")
                return None
            
            result = response.json()
            
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                generated_content = self.extract_json(content_text)
                
                if not generated_content:
                    print("Failed to parse JSON")
                    return None
                
                print("Content generated successfully")
                return generated_content
            else:
                return None
                
        except requests.exceptions.Timeout:
            print("Request timeout (120s).")
            return None
        except Exception as e:
            print(f"Error: {e}")
            return None

def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    generator = ContentGenerator(config.GEMINI_API_KEY, config.GEMINI_MODEL)
    return generator.generate(config, recent_posts)
