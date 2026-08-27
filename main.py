#!/usr/bin/env python3
"""
AI Content Agent - Main Entry Point
Generates and publishes unique content to Telegram
"""

from src.content_agent import run_agent


def main():
    """Main entry point"""
    print("=" * 50)
    print("AI Content Agent")
    print("=" * 50)
    print("✓ Starting content agent...")
    print("=" * 50)
    
    # Run the agent
    exit_code = run_agent()
    
    return exit_code


if __name__ == "__main__":
    exit(main())
