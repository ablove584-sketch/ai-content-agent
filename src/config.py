import os
from typing import List

class Config:
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")
    TELEGRAM_BOT_TOKEN: str = os.getenv("TELEGRAM_BOT_TOKEN", "")
    TELEGRAM_CHANNEL_ID: str = os.getenv("TELEGRAM_CHANNEL_ID", "")
    CONTENT_LANGUAGE: str = os.getenv("CONTENT_LANGUAGE", "ar")
    CONTENT_TOPIC: str = os.getenv("CONTENT_TOPIC", "العلوم والتقنية")
    CONTENT_STYLE: str = os.getenv("CONTENT_STYLE", "احترافي ومفيد")
    CONTENT_AUDIENCE: str = os.getenv("CONTENT_AUDIENCE", "الجمهور العربي")
    DUPLICATE_THRESHOLD: float = float(os.getenv("DUPLICATE_THRESHOLD", "0.78"))
    MAX_GENERATION_ATTEMPTS: int = int(os.getenv("MAX_GENERATION_ATTEMPTS", "3"))
    MEMORY_CONTEXT_LIMIT: int = int(os.getenv("MEMORY_CONTEXT_LIMIT", "100"))
    MAX_HASHTAGS: int = int(os.getenv("MAX_HASHTAGS", "5"))
    DRY_RUN: bool = os.getenv("DRY_RUN", "false").lower() == "true"

    @classmethod
    def validate(cls) -> bool:
        required = []
        if not cls.GEMINI_API_KEY:
            required.append("GEMINI_API_KEY")
        if not cls.TELEGRAM_BOT_TOKEN:
            required.append("TELEGRAM_BOT_TOKEN")
        if not cls.TELEGRAM_CHANNEL_ID:
            required.append("TELEGRAM_CHANNEL_ID")
        if required:
            print(f"Missing required configuration: {', '.join(required)}")
            return False
        return True
