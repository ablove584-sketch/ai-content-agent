import os
import json
import re
import random
import requests
from typing import Dict, Any, List, Optional
from src.config import Config

class ContentGenerator:
    def __init__(self, config: Config):
        self.config = config
        
        # Get multiple Gemini keys
        gemini_keys_str = os.getenv("GEMINI_API_KEYS", "")
        self.gemini_keys = [k.strip() for k in gemini_keys_str.split(",") if k.strip()]
        
        # OpenRouter fallback
        self.openrouter_key = os.getenv("OPENROUTER_API_KEY", "")
        
        # Shuffle keys for rotation
        random.shuffle(self.gemini_keys)
        self.current_key_index = 0
        
        print(f"Loaded {len(self.gemini_keys)} Gemini key(s)")
        if self.openrouter_key:
            print("OpenRouter fallback enabled")
    
    def get_next_gemini_key(self) -> Optional[str]:
        if not self.gemini_keys:
            return None
        key = self.gemini_keys[self.current_key_index]
        self.current_key_index = (self.current_key_index + 1) % len(self.gemini_keys)
        return key
    
    def build_prompt(self, recent_posts: List[Dict[str, Any]]) -> str:
        memory_context = ""
        if recent_posts:
            memory_context = "\n\n**المنشورات السابقة:**\n"
            for i, post in enumerate(recent_posts[:self.config.MEMORY_CONTEXT_LIMIT], 1):
                memory_context += f"\n{i}. {post.get('title', '')}\n"
        
        prompt = f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة لـ {self.config.CONTENT_AUDIENCE}.

**الموضوع:** {self.config.CONTENT_TOPIC}
**الأسلوب:** {self.config.CONTENT_STYLE}
**اللغة:** {self.config.CONTENT_LANGUAGE}

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
        if not self.gemini_keys and not self.openrouter_key:
            print("No API keys set")
            return None
        
        prompt = self.build_prompt(recent_posts)
        
        # Try Gemini with key rotation
        if self.gemini_keys:
            for i in range(len(self.gemini_keys)):
                result = self.generate_with_gemini(prompt)
                if result:
                    print(f"✓ Content generated with Gemini (key {i + 1})")
                    return result
                print(f"Key {i + 1} failed, trying next...")
        
        # Fallback to OpenRouter
        if self.openrouter_key:
            result = self.generate_with_openrouter(prompt)
            if result:
                print("✓ Content generated with OpenRouter")
                return result
        
        return None
    
    def generate_with_gemini(self, prompt: str) -> Optional[Dict[str, Any]]:
        api_key = self.get_next_gemini_key()
        if not api_key:
            return None
        
        model = self.config.GEMINI_MODEL
        api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
        
        headers = {"Content-Type": "application/json"}
        params = {"key": api_key}
        
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
            response = requests.post(
                api_url, 
                headers=headers, 
                params=params, 
                json=data, 
                timeout=60
            )
            
            if response.status_code == 429:
                print("Rate limit hit, rotating key...")
                return None
            elif response.status_code != 200:
                print(f"Gemini API error: {response.status_code}")
                return None
            
            result = response.json()
            
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                return self.extract_json(content_text)
            return None
                
        except Exception as e:
            print(f"Gemini error: {e}")
            return None
    
    def generate_with_openrouter(self, prompt: str) -> Optional[Dict[str, Any]]:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.openrouter_key}"
        }
        
        data = {
            "model": "meta-llama/llama-3-8b-instruct:free",
            "messages": [
                {"role": "system", "content": "أنت كاتب محتوى محترف. أعد النتيجة بصيغة JSON فقط."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.8,
            "max_tokens": 2048,
        }
        
        try:
            response = requests.post(
                "https://openrouter.ai/api/v1/chat/completions", 
                headers=headers, 
                json=data, 
                timeout=60
            )
            
            if response.status_code != 200:
                print(f"OpenRouter API error: {response.status_code}")
                return None
            
            result = response.json()
            content_text = result["choices"][0]["message"]["content"]
            return self.extract_json(content_text)
                
        except Exception as e:
            print(f"OpenRouter error: {e}")
            return None

def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    generator = ContentGenerator(config)
    return generator.generate(config, recent_posts)
ENDOFFILEcat > src/generator.py << 'ENDOFFILE'
import os
import json
import re
import random
import requests
from typing import Dict, Any, List, Optional
from src.config import Config

class ContentGenerator:
    def __init__(self, config: Config):
        self.config = config
        
        # Get multiple Gemini keys
        gemini_keys_str = os.getenv("GEMINI_API_KEYS", "")
        self.gemini_keys = [k.strip() for k in gemini_keys_str.split(",") if k.strip()]
        
        # OpenRouter fallback
        self.openrouter_key = os.getenv("OPENROUTER_API_KEY", "")
        
        # Shuffle keys for rotation
        random.shuffle(self.gemini_keys)
        self.current_key_index = 0
        
        print(f"Loaded {len(self.gemini_keys)} Gemini key(s)")
        if self.openrouter_key:
            print("OpenRouter fallback enabled")
    
    def get_next_gemini_key(self) -> Optional[str]:
        if not self.gemini_keys:
            return None
        key = self.gemini_keys[self.current_key_index]
        self.current_key_index = (self.current_key_index + 1) % len(self.gemini_keys)
        return key
    
    def build_prompt(self, recent_posts: List[Dict[str, Any]]) -> str:
        memory_context = ""
        if recent_posts:
            memory_context = "\n\n**المنشورات السابقة:**\n"
            for i, post in enumerate(recent_posts[:self.config.MEMORY_CONTEXT_LIMIT], 1):
                memory_context += f"\n{i}. {post.get('title', '')}\n"
        
        prompt = f"""أنت كاتب محتوى محترف تنشئ منشورات فريدة لـ {self.config.CONTENT_AUDIENCE}.

**الموضوع:** {self.config.CONTENT_TOPIC}
**الأسلوب:** {self.config.CONTENT_STYLE}
**اللغة:** {self.config.CONTENT_LANGUAGE}

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
        if not self.gemini_keys and not self.openrouter_key:
            print("No API keys set")
            return None
        
        prompt = self.build_prompt(recent_posts)
        
        # Try Gemini with key rotation
        if self.gemini_keys:
            for i in range(len(self.gemini_keys)):
                result = self.generate_with_gemini(prompt)
                if result:
                    print(f"✓ Content generated with Gemini (key {i + 1})")
                    return result
                print(f"Key {i + 1} failed, trying next...")
        
        # Fallback to OpenRouter
        if self.openrouter_key:
            result = self.generate_with_openrouter(prompt)
            if result:
                print("✓ Content generated with OpenRouter")
                return result
        
        return None
    
    def generate_with_gemini(self, prompt: str) -> Optional[Dict[str, Any]]:
        api_key = self.get_next_gemini_key()
        if not api_key:
            return None
        
        model = self.config.GEMINI_MODEL
        api_url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
        
        headers = {"Content-Type": "application/json"}
        params = {"key": api_key}
        
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
            response = requests.post(
                api_url, 
                headers=headers, 
                params=params, 
                json=data, 
                timeout=60
            )
            
            if response.status_code == 429:
                print("Rate limit hit, rotating key...")
                return None
            elif response.status_code != 200:
                print(f"Gemini API error: {response.status_code}")
                return None
            
            result = response.json()
            
            if "candidates" in result and len(result["candidates"]) > 0:
                content_text = result["candidates"][0]["content"]["parts"][0]["text"]
                return self.extract_json(content_text)
            return None
                
        except Exception as e:
            print(f"Gemini error: {e}")
            return None
    
    def generate_with_openrouter(self, prompt: str) -> Optional[Dict[str, Any]]:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {self.openrouter_key}"
        }
        
        data = {
            "model": "meta-llama/llama-3-8b-instruct:free",
            "messages": [
                {"role": "system", "content": "أنت كاتب محتوى محترف. أعد النتيجة بصيغة JSON فقط."},
                {"role": "user", "content": prompt}
            ],
            "temperature": 0.8,
            "max_tokens": 2048,
        }
        
        try:
            response = requests.post(
                "https://openrouter.ai/api/v1/chat/completions", 
                headers=headers, 
                json=data, 
                timeout=60
            )
            
            if response.status_code != 200:
                print(f"OpenRouter API error: {response.status_code}")
                return None
            
            result = response.json()
            content_text = result["choices"][0]["message"]["content"]
            return self.extract_json(content_text)
                
        except Exception as e:
            print(f"OpenRouter error: {e}")
            return None

def generate_content(config: Config, recent_posts: List[Dict[str, Any]]) -> Optional[Dict[str, Any]]:
    generator = ContentGenerator(config)
    return generator.generate(config, recent_posts)
