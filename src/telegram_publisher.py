import requests
from typing import Dict, Any, Optional
from src.config import Config


class TelegramPublisher:
    """Publish content to Telegram using HTTP API"""
    
    def __init__(self, bot_token: str, channel_id: str):
        self.bot_token = bot_token
        self.channel_id = channel_id
        self.base_url = f"https://api.telegram.org/bot{bot_token}"
    
    def send_message(self, content: Dict[str, Any]) -> bool:
        """Send a message to Telegram channel"""
        
        if not self.bot_token or not self.channel_id:
            print("❌ Telegram credentials not set")
            return False
        
        # Build message
        title = content.get('title', '')
        body = content.get('content', '')
        hashtags = content.get('hashtags', [])
        
        # Format message
        message = f"📌 {title}\n\n{body}\n\n"
        if hashtags:
            message += " ".join(hashtags)
        
        # Truncate if too long (Telegram limit: 4096 chars)
        if len(message) > 4000:
            message = message[:3997] + "..."
        
        url = f"{self.base_url}/sendMessage"
        
        payload = {
            "chat_id": self.channel_id,
            "text": message,
            "parse_mode": "HTML",
            "disable_web_page_preview": False
        }
        
        try:
            print("📤 Sending to Telegram...")
            response = requests.post(url, json=payload, timeout=10)
            
            if response.status_code == 200:
                result = response.json()
                if result.get('ok'):
                    print(f"✓ Published to Telegram successfully")
                    return True
                else:
                    print(f"❌ Telegram API error: {result.get('description')}")
                    return False
            
            elif response.status_code == 401:
                print("❌ Invalid bot token")
                return False
            
            elif response.status_code == 403:
                print("❌ Bot is not a member of the channel or lacks permissions")
                return False
            
            elif response.status_code == 429:
                retry_after = response.json().get('parameters', {}).get('retry_after', 60)
                print(f"❌ Rate limit exceeded. Retry after {retry_after} seconds")
                return False
            
            elif response.status_code >= 500:
                print(f"❌ Telegram server error: {response.status_code}")
                return False
            
            else:
                print(f"❌ Unexpected error: {response.status_code}")
                print(f"Response: {response.text}")
                return False
                
        except requests.exceptions.Timeout:
            print("❌ Request timeout")
            return False
        except requests.exceptions.RequestException as e:
            print(f"❌ Request failed: {e}")
            return False
    
    def test_connection(self) -> bool:
        """Test if bot can connect to Telegram"""
        
        if not self.bot_token:
            print("❌ Bot token not set")
            return False
        
        url = f"{self.base_url}/getMe"
        
        try:
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                result = response.json()
                if result.get('ok'):
                    bot_info = result.get('result', {})
                    print(f"✓ Connected as @{bot_info.get('username')}")
                    return True
            print("❌ Connection failed")
            return False
        except Exception as e:
            print(f"❌ Connection error: {e}")
            return False


def publish_to_telegram(config: Config, content: Dict[str, Any]) -> bool:
    """Convenience function to publish to Telegram"""
    publisher = TelegramPublisher(config.TELEGRAM_BOT_TOKEN, config.TELEGRAM_CHANNEL_ID)
    return publisher.send_message(content)
