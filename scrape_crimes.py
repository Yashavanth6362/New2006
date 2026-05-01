#!/usr/bin/env python3
"""
Multi-source crime news scraper.
Fetches RSS feeds from 3-4 Indian news outlets,
extracts crime type (including rape) and location,
and saves the combined data to crimes.json.
"""

import json
import re
from datetime import datetime
import feedparser

# ─── CONFIGURATION ──────────────────────────────────────
OUTPUT_FILE = "crimes.json"

# List of RSS feeds – verify URLs are still active.
# You can add/remove feeds easily.
SITES = [
    {
        "name": "Times of India - Crime",
        "url": "https://timesofindia.indiatimes.com/rssfeeds/4719148.cms",
    },
    {
        "name": "NDTV - Crime",
        "url": "https://feeds.feedburner.com/ndtvnews-crime",
    },
    {
        "name": "India Today - Crime",
        "url": "https://www.indiatoday.in/feed/crime",
    },
    {
        "name": "Hindustan Times - Crime",
        "url": "https://www.hindustantimes.com/feeds/rss/crime/rssfeed.xml",
    },
    # Optional: The Hindu – uses region/city feeds
    # {"name": "The Hindu - Delhi Crime", "url": "https://www.thehindu.com/news/cities/Delhi/feeder/default.rss"},
]

# ─── KEYWORD LOOKUP TABLES ─────────────────────────────
# Crime type ↔ list of trigger words/phrases
CRIME_KEYWORDS = {
    "murder": ["murder", "homicide", "killed", "shot dead", "stabbed to death"],
    "rape": ["rape", "raped", "sexual assault", "molestation", "gang-raped", "sexual abuse", "outrage modesty"],
    "robbery": ["robbery", "robbed", "looting", "dacoity", "heist"],
    "theft": ["theft", "stolen", "bike theft", "phone snatch", "pickpocket"],
    "assault": ["assault", "attacked", "beaten", "thrashed", "manhandled"],
    "kidnapping": ["kidnap", "abducted", "hostage"],
    "fraud": ["fraud", "scam", "cheating", "cyber fraud", "phishing"],
    "drugs": ["drugs", "narcotics", "smuggling", "ndps"],
    "riot": ["riot", "violence", "clashes", "mob"],
    "cybercrime": ["cybercrime", "online fraud", "digital arrest", "phishing"],
    "accident": ["accident", "crash", "hit-and-run", "run over"],
    "suicide": ["suicide", "dies by suicide", "self-immolation"],
    "terrorism": ["terror", "blast", "ied", "terrorist"],
    "unknown": [],   # fallback
}

# ─── HELPER FUNCTIONS ──────────────────────────────────
def clean_text(text):
    """Collapse whitespace and strip HTML tags."""
    # Remove HTML tags
    clean = re.sub(r"<[^>]+>", "", text)
    # Normalise spaces
    clean = re.sub(r"\s+", " ", clean).strip()
    return clean

def detect_crime_type(text):
    """Return the most likely crime type based on keyword matching."""
    text_lower = text.lower()
    for crime_type, keywords in CRIME_KEYWORDS.items():
        if crime_type == "unknown":
            continue
        if any(kw in text_lower for kw in keywords):
            return crime_type
    return "unknown"

def extract_location(text):
    """
    Try to extract a location from phrases like 'in Delhi', 'near Bandra', 'at Mumbai'.
    Returns the first match or 'unknown'.
    """
    # Common Indian location prefixes
    patterns = [
        r"\b(?:in|near|at|from|of)\s+([A-Z][a-z]+(?:\s?[A-Z][a-z]+)*)",  # e.g., in New Delhi
        r"([A-Z][a-z]+(?: [A-Z][a-z]+)*)\s*(?:,|:|-|—)",                 # name followed by separator
    ]
    for pat in patterns:
        match = re.search(pat, text)
        if match:
            loc = match.group(1).strip()
            # Filter out very common non-location words
            if loc.lower() not in ("the", "a", "an", "and", "with", "this", "that"):
                return loc
    return "unknown"

def process_entry(entry, source_name):
    """Extract data from a single RSS entry."""
    title = clean_text(entry.get("title", ""))
    summary = clean_text(entry.get("summary", ""))
    full_text = title + " " + summary

    crime_type = detect_crime_type(full_text)
    location = extract_location(full_text)

    return {
        "headline": title,
        "source": source_name,
        "url": entry.get("link", ""),
        "published": entry.get("published", ""),
        "type": crime_type,
        "location": location,
    }

# ─── MAIN SCRAPER ──────────────────────────────────────
def main():
    all_crimes = []
    seen_urls = set()   # simple deduplication by URL

    for site in SITES:
        print(f"Fetching {site['name']} ({site['url']})...")
        try:
            feed = feedparser.parse(site["url"])
            if feed.bozo:
                print(f"  ⚠️  Parse warning: {feed.bozo_exception}")
            for entry in feed.entries:
                url = entry.get("link", "")
                if url and url not in seen_urls:
                    seen_urls.add(url)
                    crime_data = process_entry(entry, site["name"])
                    if crime_data["type"] != "unknown" or crime_data["location"] != "unknown":
                        all_crimes.append(crime_data)
            print(f"  → Found {len(feed.entries)} entries (new: {len(all_crimes) - sum(1 for s in SITES if s == site)} total so far: {len(all_crimes)})")
        except Exception as e:
            print(f"  ❌ Error fetching {site['name']}: {e}")

    # Sort by published date descending (if available)
    all_crimes.sort(key=lambda x: x.get("published", ""), reverse=True)

    output = {
        "last_updated": datetime.utcnow().isoformat() + "Z",
        "total_articles": len(all_crimes),
        "crimes": all_crimes,
    }

    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\n✔ Saved {len(all_crimes)} crime articles to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()