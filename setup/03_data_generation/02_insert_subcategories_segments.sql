-- ============================================================
-- Step 3b: Insert Subcategories and Segments
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE WYZE_COMP_WH;

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES (SUBCATEGORY_ID, SUBCATEGORY_NAME) VALUES
    (2001, 'Dome Cameras'),
    (2002, 'Bullet Cameras'),
    (2003, 'PTZ Cameras'),
    (2004, 'Doorbell Cameras'),
    (2005, 'Indoor Cameras'),
    (2006, 'Outdoor Cameras'),
    (2007, 'Floodlight Cameras'),
    (2008, 'Security Camera Systems'),
    (2009, 'Baby Monitors'),
    (2010, 'Pet Cameras'),
    (2011, 'Solar-Powered Cameras'),
    (2012, 'Battery Cameras');

TRUNCATE TABLE IF EXISTS WYZE_COMP_ANALYSIS.RAW.SEGMENTS;

INSERT INTO WYZE_COMP_ANALYSIS.RAW.SEGMENTS (SEGMENT_ID, SEGMENT_NAME, SUBCATEGORY_ID) VALUES
    (3001, 'Budget Indoor Cam', 2005),
    (3002, 'Premium Indoor Cam', 2005),
    (3003, 'Budget Outdoor Cam', 2006),
    (3004, 'Premium Outdoor Cam', 2006),
    (3005, 'Wired Doorbell', 2004),
    (3006, 'Battery Doorbell', 2004),
    (3007, 'Pan-Tilt Indoor', 2003),
    (3008, 'Pan-Tilt Outdoor', 2003),
    (3009, 'Floodlight Cam', 2007),
    (3010, 'NVR System 4ch', 2008),
    (3011, 'NVR System 8ch', 2008),
    (3012, 'Baby Monitor Cam', 2009),
    (3013, 'Pet Monitor Cam', 2010),
    (3014, 'Solar Outdoor Cam', 2011),
    (3015, 'Battery Outdoor Cam', 2012);

SELECT * FROM WYZE_COMP_ANALYSIS.RAW.SUBCATEGORIES ORDER BY SUBCATEGORY_ID;
SELECT * FROM WYZE_COMP_ANALYSIS.RAW.SEGMENTS ORDER BY SEGMENT_ID;
