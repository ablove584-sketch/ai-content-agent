from datetime import datetime
from typing import Optional, Dict, Any, List
from src.config import Config
from src.database import initialize_database, get_recent_posts, save_post, save_run
from src.duplicate_detector import DuplicateDetector
from src.generator import ContentGenerator
from src.telegram_publisher import TelegramPublisher


class ContentAgent:
    def __init__(self, config: Config):
        self.config = config
        self.detector = DuplicateDetector(threshold=config.DUPLICATE_THRESHOLD)
        self.generator = ContentGenerator(config)
        self.publisher = TelegramPublisher(config.TELEGRAM_BOT_TOKEN, config.TELEGRAM_CHANNEL_ID)

    def run(self) -> bool:
        started_at = datetime.utcnow().isoformat()
        print("=" * 60)
        print("AI Content Agent - Starting")
        print(f"Started at: {started_at}")
        print(f"Dry Run: {self.config.DRY_RUN}")
        print("=" * 60)

        if not self.config.validate():
            print("Configuration validation failed")
            save_run(started_at, status="FAILED", error_message="Configuration validation failed")
            return False

        initialize_database()
        recent_posts = get_recent_posts(self.config.MEMORY_CONTEXT_LIMIT)
        print(f"Loaded {len(recent_posts)} recent posts from database")

        generated_content = None
        attempts = 0
        max_attempts = self.config.MAX_GENERATION_ATTEMPTS

        while attempts < max_attempts:
            attempts += 1
            print(f"\nGeneration attempt {attempts}/{max_attempts}")

            generated_content = self.generator.generate(self.config, recent_posts)

            if not generated_content:
                print(f"Generation failed on attempt {attempts}")
                continue

            print(f"Content generated: {generated_content.get('title', 'Untitled')}")

            is_duplicate, score, details = self.detector.check_duplicate(generated_content, recent_posts)

            if is_duplicate:
                print(f"Content detected as duplicate (score: {score:.2f})")
                generated_content = None
                continue
            else:
                print(f"Content is unique (score: {score:.2f})")
                break

        if not generated_content:
            print(f"Failed to generate unique content after {max_attempts} attempts")
            save_run(started_at, status="GENERATION_FAILED", attempts=max_attempts)
            return False

        print("\n" + "=" * 60)
        print("GENERATED CONTENT")
        print("=" * 60)
        print(f"Title: {generated_content.get('title')}")
        print(f"Topic: {generated_content.get('topic')}")
        print(f"Angle: {generated_content.get('angle')}")
        print(f"Core Idea: {generated_content.get('core_idea')}")
        print(f"Keywords: {', '.join(generated_content.get('keywords', []))}")
        print(f"Content: {generated_content.get('content', '')[:200]}...")
        print(f"Hashtags: {', '.join(generated_content.get('hashtags', []))}")
        print("=" * 60)

        if self.config.DRY_RUN:
            print("\nDRY RUN MODE - Skipping publication")
            published = True
        else:
            print("\nPublishing to Telegram...")
            published = self.publisher.send_message(generated_content)

        if not published:
            print("Failed to publish to Telegram")
            save_run(started_at, status="PUBLISH_FAILED", attempts=attempts)
            return False

        fingerprint = self.detector.generate_fingerprint(generated_content)

        post_id = save_post(
            title=generated_content.get('title'),
            topic=generated_content.get('topic'),
            angle=generated_content.get('angle'),
            core_idea=generated_content.get('core_idea'),
            keywords=generated_content.get('keywords', []),
            content=generated_content.get('content'),
            hashtags=generated_content.get('hashtags', []),
            fingerprint=fingerprint,
            duplicate_score=score,
            platform="telegram",
            status="published"
        )

        if post_id == -1:
            print("Failed to save post to database")
            save_run(started_at, status="DATABASE_ERROR", attempts=attempts)
            return False

        save_run(started_at, status="SUCCESS", attempts=attempts)

        print("\n" + "=" * 60)
        print("AI Content Agent - Completed Successfully")
        print(f"Post ID: {post_id}")
        print(f"Attempts: {attempts}")
        print(f"Duplicate Score: {score:.2f}")
        print(f"Published: {'Yes' if not self.config.DRY_RUN else 'No (Dry Run)'}")
        print("=" * 60)

        return True


def run_agent():
    config = Config()
    agent = ContentAgent(config)
    success = agent.run()
    return 0 if success else 1


if __name__ == "__main__":
    exit(run_agent())
