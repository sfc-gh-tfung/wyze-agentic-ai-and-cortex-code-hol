-- ============================================================
-- Step 7: Create Semantic View for Cortex Analyst
-- ============================================================
-- Enables natural language queries over marketplace data.
-- Includes 10 tables: sales, promos, traffic, channels, products,
-- brands, subcategories, segments, and brand-level review sentiment.

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

CREATE OR REPLACE SEMANTIC VIEW WYZE_COMP_ANALYSIS.FINAL.COMP_ANALYSIS_SEMANTIC_VIEW

  TABLES (
    sales AS WYZE_COMP_ANALYSIS.FINAL.SALES_ENRICHED
      PRIMARY KEY (SALE_ID)
      WITH SYNONYMS ('weekly sales', 'sales data', 'sales performance')
      COMMENT = 'Weekly sales performance by SKU with product enrichment and content scores. Each row = one product in one week. Use this table for sales trends, ASP analysis, market share, and content quality analysis. IS_WYZE_COMPETITOR=FALSE means it is Wyze (our brand), TRUE means it is a competitor. To compare Wyze vs competitors, group or filter by IS_WYZE_COMPETITOR.',

    promos AS WYZE_COMP_ANALYSIS.FINAL.PROMO_ENRICHED
      PRIMARY KEY (PROMO_ID)
      WITH SYNONYMS ('promotions', 'deals', 'coupons', 'discounts')
      COMMENT = 'Promotion events with lift analysis and ASP compression metrics. Each row = one promotion event for a product in a week. Contains PROMO_ASP (price during promo), BASELINE_ASP (price without promo), and ASP_COMPRESSION (difference). Use this table alone for all promotion questions including ASP compression — do not join to sales.',

    traffic AS WYZE_COMP_ANALYSIS.RAW.ATLAS_TRAFFIC
      PRIMARY KEY (TRAFFIC_ID)
      WITH SYNONYMS ('search traffic', 'advertising', 'ad data')
      COMMENT = 'Weekly search traffic by term with organic vs paid breakdown. Each row = one search term for one product in one week.',

    channel_category AS WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_CATEGORY
      PRIMARY KEY (CHANNEL_ID)
      WITH SYNONYMS ('1P 3P by category', 'channel mix category', '1P 3P by subcategory')
      COMMENT = '1P vs 3P sales split by subcategory and week. Join to subcategories table to get subcategory names.',

    channel_segment AS WYZE_COMP_ANALYSIS.RAW.ATLAS_CHANNEL_SEGMENT
      PRIMARY KEY (CHANNEL_SEG_ID)
      WITH SYNONYMS ('1P 3P by segment', 'channel mix segment')
      COMMENT = '1P vs 3P sales split by segment and week. Join to segments table to get segment names.',

    products AS WYZE_COMP_ANALYSIS.RAW.PRODUCTS
      PRIMARY KEY (PRODUCT_ID)
      WITH SYNONYMS ('SKUs', 'product catalog', 'items')
      COMMENT = 'Product catalog with pricing, ratings, review counts, and content quality scores',

    brands AS WYZE_COMP_ANALYSIS.RAW.BRANDS
      PRIMARY KEY (BRAND_ID)
      WITH SYNONYMS ('competitors', 'companies')
      COMMENT = 'Brand reference data for Security & Surveillance category',

    subcategories AS WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES
      PRIMARY KEY (SUBCATEGORY_ID)
      WITH SYNONYMS ('product categories', 'category names')
      COMMENT = 'Subcategory reference table (e.g., Indoor Cameras, Doorbell Cameras). Join to channel_category for names.',

    segments AS WYZE_COMP_ANALYSIS.RAW.SEGMENTS
      PRIMARY KEY (SEGMENT_ID)
      WITH SYNONYMS ('product segments', 'segment names')
      COMMENT = 'Segment reference table (e.g., Budget Indoor Cam, Premium Outdoor Cam). Join to channel_segment for names.',

    brand_sentiment AS WYZE_COMP_ANALYSIS.FINAL.BRAND_REVIEW_SENTIMENT
      PRIMARY KEY (BRAND_ID)
      WITH SYNONYMS ('review sentiment', 'customer feedback', 'brand perception')
      COMMENT = 'Brand-level sentiment scores from AI analysis of product reviews'
  )

  RELATIONSHIPS (
    sales_to_products AS
      sales (PRODUCT_ID) REFERENCES products,
    promos_to_products AS
      promos (PRODUCT_ID) REFERENCES products,
    traffic_to_products AS
      traffic (PRODUCT_ID) REFERENCES products,
    traffic_to_brands AS
      traffic (BRAND_ID) REFERENCES brands,
    channel_category_to_brands AS
      channel_category (BRAND_ID) REFERENCES brands,
    channel_category_to_subcategories AS
      channel_category (SUBCATEGORY_ID) REFERENCES subcategories,
    channel_segment_to_brands AS
      channel_segment (BRAND_ID) REFERENCES brands,
    channel_segment_to_segments AS
      channel_segment (SEGMENT_ID) REFERENCES segments,
    segments_to_subcategories AS
      segments (SUBCATEGORY_ID) REFERENCES subcategories,
    products_to_brands AS
      products (BRAND_ID) REFERENCES brands,
    brand_sentiment_to_brands AS
      brand_sentiment (BRAND_ID) REFERENCES brands
  )

  FACTS (
    sales.retail_sales_amount AS RETAIL_SALES
      COMMENT = 'Total retail sales dollars for the week',
    sales.units_sold_count AS UNITS_SOLD
      COMMENT = 'Number of units sold in the week',
    sales.retail_price_amount AS RETAIL_PRICE
      COMMENT = 'Average retail price for the week',
    sales.organic_sales_amount AS ORGANIC_SALES
      COMMENT = 'Sales from organic (non-paid) traffic',
    sales.paid_sales_amount AS PAID_SALES
      COMMENT = 'Sales from paid advertising traffic',
    sales.asp_value AS ASP
      COMMENT = 'Average selling price (retail_sales / units_sold)',

    promos.discount_pct_value AS DISCOUNT_PCT
      COMMENT = 'Promotion discount percentage',
    promos.promo_sales_amount AS PROMO_SALES
      COMMENT = 'Sales during promotion period',
    promos.promo_units_count AS PROMO_UNITS
      COMMENT = 'Units sold during promotion',
    promos.baseline_sales_amount AS BASELINE_SALES
      COMMENT = 'Baseline sales without promotion',
    promos.sales_lift AS SALES_LIFT_PCT
      COMMENT = 'Percentage sales lift from promotion vs baseline',
    promos.asp_compression_amount AS ASP_COMPRESSION
      COMMENT = 'ASP change during promotion vs baseline (negative = price compressed). Use this to measure how much promotions reduce price.',
    promos.promo_asp_value AS PROMO_ASP
      COMMENT = 'Average selling price during the promotion period',
    promos.baseline_asp_value AS BASELINE_ASP
      COMMENT = 'Average selling price before the promotion (baseline price). Compare with PROMO_ASP to see price recovery.',
    promos.baseline_units_count AS BASELINE_UNITS
      COMMENT = 'Units sold in the baseline (non-promo) period',
    promos.unit_lift_value AS UNIT_LIFT_PCT
      COMMENT = 'Percentage unit volume lift from promotion vs baseline',

    traffic.organic_impressions_count AS ORGANIC_IMPRESSIONS
      COMMENT = 'Number of organic search impressions',
    traffic.paid_impressions_count AS PAID_IMPRESSIONS
      COMMENT = 'Number of paid search impressions',
    traffic.organic_clicks_count AS ORGANIC_CLICKS
      COMMENT = 'Number of organic clicks',
    traffic.paid_clicks_count AS PAID_CLICKS
      COMMENT = 'Number of paid clicks',
    traffic.ad_spend_amount AS AD_SPEND
      COMMENT = 'Advertising spend in dollars',

    channel_category.onep_sales_amount AS channel_category.ONEP_SALES
      COMMENT = '1P (first party / Amazon direct) sales by subcategory',
    channel_category.threep_sales_amount AS channel_category.THREEP_SALES
      COMMENT = '3P (third party / marketplace seller) sales by subcategory',
    channel_category.onep_units AS channel_category.ONEP_UNITS_SOLD
      COMMENT = '1P units sold by subcategory',
    channel_category.threep_units AS channel_category.THREEP_UNITS_SOLD
      COMMENT = '3P units sold by subcategory',
    channel_category.retail_sales_amount AS channel_category.RETAIL_SALES
      COMMENT = 'Total retail sales (1P + 3P) by subcategory',
    channel_category.units_sold_count AS channel_category.UNITS_SOLD
      COMMENT = 'Total units sold (1P + 3P) by subcategory',

    channel_segment.onep_sales_amount AS channel_segment.ONEP_SALES
      COMMENT = '1P sales by segment',
    channel_segment.threep_sales_amount AS channel_segment.THREEP_SALES
      COMMENT = '3P sales by segment',
    channel_segment.onep_units AS channel_segment.ONEP_UNITS_SOLD
      COMMENT = '1P units sold by segment',
    channel_segment.threep_units AS channel_segment.THREEP_UNITS_SOLD
      COMMENT = '3P units sold by segment',
    channel_segment.retail_sales_amount AS channel_segment.RETAIL_SALES
      COMMENT = 'Total retail sales (1P + 3P) by segment',
    channel_segment.units_sold_count AS channel_segment.UNITS_SOLD
      COMMENT = 'Total units sold (1P + 3P) by segment',

    products.rating_value AS products.RATING
      COMMENT = 'Product star rating (1-5)',
    products.review_count_value AS products.REVIEW_COUNT
      COMMENT = 'Number of customer reviews',
    products.content_score_value AS products.CONTENT_SCORE
      COMMENT = 'Overall content quality score (0-1)',
    products.title_score_value AS products.TITLE_SCORE
      COMMENT = 'Product title quality score (0-1)',
    products.image_score_value AS products.IMAGE_SCORE
      COMMENT = 'Product image quality score (0-1)',
    products.video_score_value AS products.VIDEO_SCORE
      COMMENT = 'Product video quality score (0-1)',
    products.aplus_score_value AS products.APLUS_SCORE
      COMMENT = 'A+ content quality score (0-1)',

    brand_sentiment.TOTAL_REVIEWS AS brand_sentiment.TOTAL_REVIEWS
      COMMENT = 'Total number of product reviews analyzed for the brand',
    brand_sentiment.POSITIVE_REVIEWS AS brand_sentiment.POSITIVE_REVIEWS
      COMMENT = 'Number of reviews with positive sentiment',
    brand_sentiment.NEGATIVE_REVIEWS AS brand_sentiment.NEGATIVE_REVIEWS
      COMMENT = 'Number of reviews with negative sentiment',
    brand_sentiment.SENTIMENT_SCORE AS brand_sentiment.SENTIMENT_SCORE
      COMMENT = 'Net sentiment score from -1 (all negative) to +1 (all positive)'
  )

  DIMENSIONS (
    sales.week AS sales.WEEK_ID
      WITH SYNONYMS = ('week', 'time period', 'week number')
      COMMENT = 'Week identifier in YYYYWW format (e.g., 202614 = week 14 of 2026)',
    sales.product_name AS sales.PRODUCT_NAME
      WITH SYNONYMS = ('SKU name', 'item name')
      COMMENT = 'Full product name including brand and variant',
    sales.brand_name AS sales.BRAND_NAME
      WITH SYNONYMS = ('brand', 'manufacturer', 'company')
      COMMENT = 'Brand name of the product',
    sales.subcategory_name AS sales.SUBCATEGORY_NAME
      WITH SYNONYMS = ('subcategory', 'product type')
      COMMENT = 'Product subcategory (e.g., Indoor Cameras, Doorbell Cameras)',
    sales.segment_name AS sales.SEGMENT_NAME
      WITH SYNONYMS = ('segment', 'product segment')
      COMMENT = 'Product segment (e.g., Budget Indoor Cam, Premium Outdoor Cam)',
    sales.is_competitor AS sales.IS_WYZE_COMPETITOR
      COMMENT = 'FALSE = Wyze (our brand), TRUE = competitor brand. Filter IS_WYZE_COMPETITOR=FALSE for Wyze data. Group by this flag to compare Wyze vs competitors without a self-join.',
    sales.content_quality AS sales.CONTENT_QUALITY_TIER
      WITH SYNONYMS = ('content tier', 'listing quality')
      COMMENT = 'Content quality tier: Below Threshold, Acceptable, Strong',
    sales.rating_quality AS sales.RATING_TIER
      COMMENT = 'Rating tier: Poor, Below Average, Good, Excellent',

    promos.promo_type AS PROMO_TYPE
      WITH SYNONYMS = ('promotion type', 'deal type')
      COMMENT = 'Type of promotion: COUPON, BEST_DEAL, PRIME_MEMBER, LIGHTNING_DEAL',
    promos.promo_week AS promos.WEEK_ID
      COMMENT = 'Week of the promotion in YYYYWW format',
    promos.promo_brand AS promos.BRAND_NAME
      COMMENT = 'Brand running the promotion',
    promos.promo_product AS promos.PRODUCT_NAME
      COMMENT = 'Product name for the promotion',
    promos.promo_segment AS promos.SEGMENT_NAME
      COMMENT = 'Segment of the promoted product',
    promos.promo_subcategory AS promos.SUBCATEGORY_NAME
      COMMENT = 'Subcategory of the promoted product',
    promos.promo_is_competitor AS promos.IS_WYZE_COMPETITOR
      COMMENT = 'FALSE = Wyze (our brand), TRUE = competitor brand',

    traffic.search_term AS SEARCH_TERM
      WITH SYNONYMS = ('keyword', 'search keyword', 'query')
      COMMENT = 'Amazon search term driving traffic',
    traffic.traffic_week AS traffic.WEEK_ID
      COMMENT = 'Week of the traffic data',

    channel_category.channel_week AS channel_category.WEEK_ID
      COMMENT = 'Week of channel data',

    channel_segment.segment_week AS channel_segment.WEEK_ID
      COMMENT = 'Week of segment channel data',

    brands.brand_name AS brands.BRAND_NAME
      COMMENT = 'Brand name',
    brands.brand_category AS brands.BRAND_CATEGORY
      COMMENT = 'Brand product category focus',
    brands.is_competitor AS brands.IS_WYZE_COMPETITOR
      COMMENT = 'FALSE = Wyze (our brand), TRUE = competitor. Filter FALSE for Wyze data.',

    subcategories.subcategory_name AS subcategories.SUBCATEGORY_NAME
      WITH SYNONYMS = ('category name', 'product category')
      COMMENT = 'Subcategory name (e.g., Indoor Cameras, Doorbell Cameras)',

    segments.segment_name AS segments.SEGMENT_NAME
      WITH SYNONYMS = ('segment name', 'market segment')
      COMMENT = 'Segment name (e.g., Budget Indoor Cam, Premium Outdoor Cam)',

    products.product_name AS products.PRODUCT_NAME
      COMMENT = 'Product catalog name',
    products.asin AS products.ASIN
      WITH SYNONYMS = ('Amazon ID', 'product identifier')
      COMMENT = 'Amazon Standard Identification Number',

    brand_sentiment.BRAND_NAME AS brand_sentiment.BRAND_NAME
      COMMENT = 'Brand name for sentiment lookup',
    brand_sentiment.SENTIMENT_TIER AS brand_sentiment.SENTIMENT_TIER
      WITH SYNONYMS = ('sentiment category', 'customer perception')
      COMMENT = 'Sentiment tier: Strong Positive, Leaning Positive, Leaning Negative, Strong Negative'
  )

  METRICS (
    sales.total_sales AS SUM(sales.retail_sales_amount)
      COMMENT = 'Total retail sales across selected products/weeks',
    sales.total_units AS SUM(sales.units_sold_count)
      COMMENT = 'Total units sold',
    sales.avg_asp AS AVG(sales.asp_value)
      COMMENT = 'Average selling price',
    sales.total_organic_sales AS SUM(sales.organic_sales_amount)
      COMMENT = 'Total organic sales',
    sales.total_paid_sales AS SUM(sales.paid_sales_amount)
      COMMENT = 'Total paid/advertising sales',
    sales.sku_count AS COUNT(DISTINCT sales.PRODUCT_ID)
      COMMENT = 'Number of distinct SKUs',

    promos.total_promo_sales AS SUM(promos.promo_sales_amount)
      COMMENT = 'Total sales during promotions',
    promos.avg_sales_lift AS AVG(promos.sales_lift)
      COMMENT = 'Average sales lift percentage from promotions',
    promos.avg_discount AS AVG(promos.discount_pct_value)
      COMMENT = 'Average promotion discount percentage',
    promos.promo_count AS COUNT(PROMO_ID)
      COMMENT = 'Number of promotion events',
    promos.avg_asp_compression AS AVG(promos.asp_compression_amount)
      COMMENT = 'Average ASP compression across promotions (negative = price decreased)',

    traffic.total_organic_impressions AS SUM(traffic.organic_impressions_count)
      COMMENT = 'Total organic search impressions',
    traffic.total_paid_impressions AS SUM(traffic.paid_impressions_count)
      COMMENT = 'Total paid search impressions',
    traffic.total_ad_spend AS SUM(traffic.ad_spend_amount)
      COMMENT = 'Total advertising spend',
    traffic.total_organic_clicks AS SUM(traffic.organic_clicks_count)
      COMMENT = 'Total organic clicks',

    channel_category.total_1p_sales AS SUM(channel_category.onep_sales_amount)
      COMMENT = 'Total 1P (first party) sales by category',
    channel_category.total_3p_sales AS SUM(channel_category.threep_sales_amount)
      COMMENT = 'Total 3P (third party) sales by category',

    channel_segment.total_1p_sales AS SUM(channel_segment.onep_sales_amount)
      COMMENT = 'Total 1P (first party) sales by segment',
    channel_segment.total_3p_sales AS SUM(channel_segment.threep_sales_amount)
      COMMENT = 'Total 3P (third party) sales by segment',

    brand_sentiment.avg_sentiment AS AVG(brand_sentiment.SENTIMENT_SCORE)
      COMMENT = 'Average brand sentiment score across reviews'
  )

  COMMENT = 'Amazon marketplace competitive analysis for Security & Surveillance category. Covers sales performance, promotions, traffic, content quality, 1P/3P channel mix, and AI-powered review sentiment across 25 brands and 250+ SKUs.';

SHOW SEMANTIC VIEWS IN SCHEMA WYZE_COMP_ANALYSIS.FINAL;
DESCRIBE SEMANTIC VIEW WYZE_COMP_ANALYSIS.FINAL.COMP_ANALYSIS_SEMANTIC_VIEW;
