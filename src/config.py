#!/usr/bin/env python3
"""
Configuration Manager - Reads environment variables
"""

import os
from typing import Optional


class Config:
    """Configuration class for AI Content Agent"""
    
    # API Keys (Required)
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")
    
    TELEGRAM_BOT_TOKEN: str = os.getenv("TELEGRAM_BOT_TOKEN", "")
    TELEGRAM_CHANNEL_ID: str = os.getenv("TELEGRAM_CHANNEL_ID", "")
    
    # Content Settings (Optional with defaults)
    CONTENT_LANGUAGE: str = os.getenv("CONTENT_LANGUAGE", "ar")
    CONTENT_TOPIC: str = os.getenv("CONTENT_TOPIC", "العلوم والتقنية وتطوير الذات")
    CONTENT_STYLE: str = os.getenv("CONTENT_STYLE", "احترافي، مفيد، واضح، طبيعي")
    CONTENT_AUDIENCE: str = os.getenv("CONTENT_AUDIENCE", "الجمهور العربي")
    
    # Duplicate Detection
    DUPLICATE_THRESHOLD: float = float(os.getenv("DUPLICATE_THRESHOLD", "0.78"))
    
    # Generation Limits
    MAX_GENERATION_ATTEMPTS: int = int(os.getenv("MAX_GENERATION_ATTEMPTS", "3"))
    MEMORY_CONTEXT_LIMIT: int = int(os.getenv("MEMORY_CONTEXT_LIMIT", "100"))
    MAX_HASHTAGS: int = int(os.getenv("MAX_HASHTAGS", "5"))
    
    # Debug Mode
    DRY_RUN: bool = os.getenv("DRY_RUN", "true").lower() == "true"
    
    @classmethod
    def validate(cls) -> bool:
        """Validate required configuration"""
        required = {
            "GEMINI_API_KEY": cls.GEMINI_API_KEY,
            "TELEGRAM_BOT_TOKEN": cls.TELEGRAM_BOT_TOKEN,
            "TELEGRAM_CHANNEL_ID": cls.TELEGRAM_CHANNEL_ID,
        }
        
        missing = [key for key, value in required.items() if not value]
        
        if missing:
            print(f"❌ Missing required configuration: {', '.join(missing)}")
            return False
        
        return True
    
    @classmethod
    def display(cls) -> None:
        """Display current configuration (without secrets)"""
        print("=" * 50)
        print("AI Content Agent - Configuration")
        print("=" * 50)
        print(f"✓ GEMINI_MODEL: {cls.GEMINI_MODEL}")
        print(f"✓ CONTENT_LANGUAGE: {cls.CONTENT_LANGUAGE}")
        print(f"✓ CONTENT_TOPIC: {cls.CONTENT_TOPIC}")
        print(f"✓ CONTENT_STYLE: {cls.CONTENT_STYLE}")
        print(f"✓ DUPLICATE_THRESHOLD: {cls.DUPLICATE_THRESHOLD}")
        print(f"✓ MAX_GENERATION_ATTEMPTS: {cls.MAX_GENERATION_ATTEMPTS}")
        print(f"✓ MEMORY_CONTEXT_LIMIT: {cls.MEMORY_CONTEXT_LIMIT}")
        print(f"✓ MAX_HASHTAGS: {cls.MAX_HASHTAGS}")
        print(f"✓ DRY_RUN: {cls.DRY_RUN}")
        print("=" * 50)
        
        # Check for missing secrets
        if not cls.GEMINI_API_KEY:
            print("⚠️  GEMINI_API_KEY not set")
        if not cls.TELEGRAM_BOT_TOKEN:
            print("⚠️  TELEGRAM_BOT_TOKEN not set")
        if not cls.TELEGRAM_CHANNEL_ID:
            print("⚠️  TELEGRAM_CHANNEL_ID not set")
        
        print("=" * 50)


# Convenience function
def get_config() -> Config:
    """Get configuration instance"""
    return Config()
