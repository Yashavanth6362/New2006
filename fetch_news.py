import json
import requests

def fetch_news():
    # Hacker News API (no API key required)
    top_stories_url = "https://hacker-news.firebaseio.com/v0/topstories.json"
    
    # Get list of top story IDs
    response = requests.get(top_stories_url)
    story_ids = response.json()[:10]  # Get top 10
    
    news_list = []
    for story_id in story_ids:
        story_url = f"https://hacker-news.firebaseio.com/v0/item/{story_id}.json"
        story_data = requests.get(story_url).json()
        news_list.append({
            "id": story_id,
            "title": story_data.get("title"),
            "url": story_data.get("url"),
            "score": story_data.get("score"),
            "time": story_data.get("time")
        })
    
    # Save to JSON file (overwrites every run)
    with open("news.json", "w") as f:
        json.dump(news_list, f, indent=2)
    
    print(f"Saved {len(news_list)} news items to news.json")

if __name__ == "__main__":
    fetch_news()