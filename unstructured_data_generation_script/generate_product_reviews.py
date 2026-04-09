import os
import hashlib
import random

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "unstructured_data", "product_reviews")
os.makedirs(OUTPUT_DIR, exist_ok=True)

BRANDS_SEGMENTS = [
    ("Wyze", ["Budget Indoor Cam", "Budget Outdoor Cam", "Wired Doorbell", "Pan-Tilt Indoor", "Battery Outdoor Cam", "Pan-Tilt Outdoor"]),
    ("Ring", ["Budget Indoor Cam", "Premium Outdoor Cam", "Wired Doorbell", "Battery Doorbell", "Floodlight Cam"]),
    ("Blink", ["Budget Indoor Cam", "Budget Outdoor Cam", "Battery Outdoor Cam"]),
    ("Arlo", ["Premium Indoor Cam", "Premium Outdoor Cam", "Battery Doorbell", "Floodlight Cam", "Solar Outdoor Cam"]),
    ("Google-Nest", ["Premium Indoor Cam", "Wired Doorbell", "Battery Doorbell", "Floodlight Cam"]),
    ("eufy", ["Budget Indoor Cam", "Premium Outdoor Cam", "Wired Doorbell", "Battery Doorbell", "Pan-Tilt Indoor", "Solar Outdoor Cam"]),
    ("Reolink", ["Budget Outdoor Cam", "Premium Outdoor Cam", "Pan-Tilt Outdoor", "NVR System 4ch", "NVR System 8ch", "Solar Outdoor Cam"]),
    ("TP-Link-Tapo", ["Budget Indoor Cam", "Budget Outdoor Cam", "Pan-Tilt Indoor"]),
    ("SimpliSafe", ["Budget Indoor Cam", "Premium Outdoor Cam", "Wired Doorbell"]),
    ("Lorex", ["NVR System 4ch", "NVR System 8ch", "Bullet Cameras"]),
    ("Amcrest", ["Budget Outdoor Cam", "Pan-Tilt Indoor", "NVR System 4ch"]),
    ("Night-Owl", ["NVR System 8ch", "Premium Outdoor Cam"]),
    ("Noorio", ["Battery Outdoor Cam", "Solar Outdoor Cam"]),
    ("Aosu", ["Battery Doorbell", "Battery Outdoor Cam"]),
    ("Furbo", ["Pet Monitor Cam"]),
    ("Abode", ["Budget Indoor Cam", "Wired Doorbell"]),
]

DATES = [
    "2025-10-15", "2025-11-02", "2025-11-20", "2025-12-05", "2025-12-22",
    "2026-01-10", "2026-01-28", "2026-02-14", "2026-03-01", "2026-03-18",
]

POSITIVE_TEMPLATES = [
    """Product Review Summary: {brand} {segment}
Review Period: {date}
Overall Sentiment: Positive
Average Rating: {rating}/5 ({review_count} reviews analyzed)

Key Strengths:
- Excellent video quality with clear night vision capabilities
- Easy setup process that most customers complete in under 15 minutes
- Reliable motion detection with minimal false alerts
- Good value for the price point compared to competitors
- Responsive customer support team

Customer Highlights:
- "{brand} {segment} exceeded my expectations for home security"
- "The app is intuitive and notifications are timely"
- "Picture quality is surprisingly good for this price range"

Areas for Minor Improvement:
- Some users wish the field of view was slightly wider
- Occasional cloud connectivity delays during peak hours
- Battery life could be longer for outdoor models

Recommendation: Customers overwhelmingly recommend this product for budget-conscious buyers looking for reliable home security. The {brand} {segment} consistently ranks among the top sellers in its category.""",

    """Product Review Summary: {brand} {segment}
Review Period: {date}
Overall Sentiment: Positive
Average Rating: {rating}/5 ({review_count} reviews analyzed)

Key Strengths:
- Superior build quality and weather resistance for outdoor use
- Advanced AI detection (person, vehicle, package) with high accuracy
- Seamless smart home integration with Alexa and Google Home
- Crisp 2K/4K resolution with color night vision
- Local storage option reduces subscription dependency

Customer Highlights:
- "Best camera I've owned - the AI detection is spot on"
- "Survived a full winter outdoors without any issues"
- "Love that I don't need a subscription for basic features"

Areas for Minor Improvement:
- Premium pricing compared to some alternatives
- Initial firmware update can take 10-15 minutes
- The mounting bracket could be more adjustable

Recommendation: Highly recommended for users who want premium features and are willing to invest in quality. The {brand} {segment} delivers professional-grade security at a consumer price point.""",
]

NEGATIVE_TEMPLATES = [
    """Product Review Summary: {brand} {segment}
Review Period: {date}
Overall Sentiment: Negative
Average Rating: {rating}/5 ({review_count} reviews analyzed)

Key Complaints:
- Frequent disconnection issues with WiFi, especially at longer ranges
- Motion detection triggers too many false alerts from shadows and pets
- App crashes frequently and is slow to load live view
- Required subscription for basic features like person detection
- Poor customer support response times (3-5 day wait)

Customer Frustrations:
- "Camera goes offline multiple times a day and I have to power cycle it"
- "The subscription costs more than the camera itself over a year"
- "Night vision quality is grainy and nearly unusable past 15 feet"

Positive Notes:
- Affordable entry price attracted many buyers
- Physical design is compact and unobtrusive
- Easy initial setup out of the box

Recommendation: Many customers express buyer's remorse and recommend looking at alternatives. The connectivity issues and required subscription significantly diminish the value proposition of the {brand} {segment}.""",

    """Product Review Summary: {brand} {segment}
Review Period: {date}
Overall Sentiment: Negative
Average Rating: {rating}/5 ({review_count} reviews analyzed)

Key Complaints:
- Battery life far shorter than advertised (2 weeks vs claimed 6 months)
- Video quality degrades significantly in low light conditions
- Smart detection features miss events or trigger hours late
- Cloud storage is unreliable with missing video clips
- Mounting hardware feels cheap and does not hold in strong wind

Customer Frustrations:
- "Had to recharge the battery every 10 days, completely impractical"
- "Missed a package theft because the notification came 2 hours late"
- "The camera fell off the mount during a rainstorm"

Positive Notes:
- Sleek design looks good on the home exterior
- Two-way audio quality is decent
- Initial price seemed competitive

Recommendation: Significant reliability concerns. Customers frequently return this product within the first month. The {brand} {segment} needs substantial firmware and hardware improvements before it can compete effectively.""",
]

NEUTRAL_TEMPLATES = [
    """Product Review Summary: {brand} {segment}
Review Period: {date}
Overall Sentiment: Mixed
Average Rating: {rating}/5 ({review_count} reviews analyzed)

Balanced Assessment:
- Video quality is adequate for the price but not class-leading
- Setup is straightforward though some features require technical knowledge
- Motion detection works well during the day but has issues at night
- App functionality is basic but covers essential features
- Subscription adds value but many feel it should be included

Customer Perspectives:
- "It does what it's supposed to, nothing more nothing less"
- "Good for the price if you don't need advanced features"
- "Works fine as a secondary camera but I wouldn't rely on it alone"

Strengths vs Weaknesses:
+ Competitive pricing for the feature set
+ Compact form factor fits in tight spaces
+ Regular firmware updates show active development
- Audio quality could be better for two-way communication
- Integration with third-party platforms is limited
- No local storage option without additional hub purchase

Recommendation: A serviceable option for buyers with modest expectations. The {brand} {segment} occupies the middle ground - it won't disappoint but won't impress either. Best suited as a supplementary camera in a multi-camera setup.""",
]

def generate_reviews():
    count = 0
    for brand, segments in BRANDS_SEGMENTS:
        for segment in segments:
            seed = int(hashlib.md5(f"{brand}{segment}".encode()).hexdigest()[:8], 16)
            rng = random.Random(seed)

            num_reviews = rng.choice([1, 2, 3])
            selected_dates = rng.sample(DATES, min(num_reviews, len(DATES)))

            for date in selected_dates:
                date_seed = int(hashlib.md5(f"{brand}{segment}{date}".encode()).hexdigest()[:8], 16)
                date_rng = random.Random(date_seed)

                sentiment_roll = date_rng.randint(1, 100)
                if sentiment_roll <= 45:
                    template = date_rng.choice(POSITIVE_TEMPLATES)
                    rating = round(date_rng.uniform(4.0, 4.8), 1)
                elif sentiment_roll <= 75:
                    template = date_rng.choice(NEUTRAL_TEMPLATES)
                    rating = round(date_rng.uniform(3.2, 3.9), 1)
                else:
                    template = date_rng.choice(NEGATIVE_TEMPLATES)
                    rating = round(date_rng.uniform(2.1, 3.3), 1)

                review_count = date_rng.randint(50, 2000)
                content = template.format(
                    brand=brand.replace("-", " "),
                    segment=segment,
                    date=date,
                    rating=rating,
                    review_count=review_count,
                )

                safe_segment = segment.replace(" ", "_")
                filename = f"{brand}_{safe_segment}_{date}.txt"
                filepath = os.path.join(OUTPUT_DIR, filename)

                with open(filepath, "w") as f:
                    f.write(content)
                count += 1

    print(f"Generated {count} product review files in {OUTPUT_DIR}")

if __name__ == "__main__":
    generate_reviews()
