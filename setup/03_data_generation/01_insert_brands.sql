-- ============================================================
-- Step 3a: Insert Brand Reference Data
-- ============================================================
-- 26 Security & Surveillance brands on Amazon (Wyze + 25 competitors/others)

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.BRANDS;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.BRANDS (
    BRAND_ID, BRAND_NAME, BRAND_CATEGORY, HEADQUARTERS, FOUNDED_YEAR, IS_WYZE_COMPETITOR
)
VALUES
    (1000, 'Wyze', 'Smart Home Security', 'Kirkland, WA', 2017, FALSE),
    (1001, 'Ring', 'Smart Home Security', 'Santa Monica, CA', 2013, TRUE),
    (1002, 'Blink', 'Smart Home Security', 'Andover, MA', 2009, TRUE),
    (1003, 'Arlo', 'Smart Home Security', 'Carlsbad, CA', 2014, TRUE),
    (1004, 'Google Nest', 'Smart Home', 'Mountain View, CA', 2010, TRUE),
    (1005, 'eufy', 'Smart Home Security', 'Bellevue, WA', 2016, TRUE),
    (1006, 'Reolink', 'IP Cameras', 'Shenzhen, China', 2009, TRUE),
    (1007, 'TP-Link Tapo', 'Smart Home', 'Shenzhen, China', 1996, TRUE),
    (1008, 'SimpliSafe', 'Home Security Systems', 'Boston, MA', 2006, TRUE),
    (1009, 'Lorex', 'Surveillance Systems', 'Markham, Canada', 1991, TRUE),
    (1010, 'Amcrest', 'IP Cameras', 'Houston, TX', 2014, TRUE),
    (1011, 'ZOSI', 'CCTV Systems', 'Shenzhen, China', 2013, TRUE),
    (1012, 'Hikvision', 'Professional Surveillance', 'Hangzhou, China', 2001, TRUE),
    (1013, 'Swann', 'Security Systems', 'Melbourne, Australia', 1987, TRUE),
    (1014, 'YI Technology', 'Smart Cameras', 'Shanghai, China', 2014, TRUE),
    (1015, 'Kasa Smart', 'Smart Home', 'Shenzhen, China', 1996, TRUE),
    (1016, 'Hiseeu', 'CCTV Systems', 'Shenzhen, China', 2015, TRUE),
    (1017, 'LaView', 'Surveillance Systems', 'Jupiter, FL', 2011, TRUE),
    (1018, 'Night Owl', 'Security Systems', 'Boca Raton, FL', 2009, TRUE),
    (1019, 'Noorio', 'Smart Cameras', 'Shenzhen, China', 2021, TRUE),
    (1020, 'Aosu', 'Smart Doorbells', 'Shenzhen, China', 2020, TRUE),
    (1021, 'Blink Mini', 'Indoor Cameras', 'Andover, MA', 2009, TRUE),
    (1022, 'Furbo', 'Pet Cameras', 'Taipei, Taiwan', 2016, TRUE),
    (1023, 'Canary', 'Smart Security', 'New York, NY', 2012, TRUE),
    (1024, 'Abode', 'Home Security Systems', 'Palo Alto, CA', 2015, TRUE),
    (1025, 'Vivint', 'Smart Home Security', 'Provo, UT', 1999, TRUE);

SELECT BRAND_ID, BRAND_NAME, IS_WYZE_COMPETITOR FROM WYZE_COMP_ANALYSIS.RAW.BRANDS ORDER BY BRAND_ID;
