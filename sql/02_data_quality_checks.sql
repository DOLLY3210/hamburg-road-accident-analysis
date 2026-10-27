-- =============================================================
-- Hamburg Road Accident Analysis 2025
-- File: 02_data_quality_checks.sql
-- Data quality checks before any analysis (PostgreSQL)
-- =============================================================

-- -------------------------------------------------------------
-- 1) Rows, unique IDs and date range
-- -------------------------------------------------------------

SELECT COUNT(*)  AS total_rows,
       COUNT(DISTINCT accident_id) AS unique_ids,
       MIN(accident_date)  AS first_date,
       MAX(accident_date) AS last_date
FROM hamburg_accidents;

-- Result:
--  total_rows | unique_ids | first_date | last_date
-- ------------+------------+------------+------------
--        7057 |       7057 | 2025-01-01 | 2025-12-31
--
-- No duplicate IDs.

-- -------------------------------------------------------------
-- 2) Are all 12 months present?
-- -------------------------------------------------------------

SELECT COUNT(DISTINCT EXTRACT(MONTH FROM accident_date)) AS months_present
FROM hamburg_accidents;

-- Result:
--  months_present
-- ----------------
--              12
--
-- All months are present.

-- -------------------------------------------------------------
-- 3) Missing values
-- -------------------------------------------------------------

SELECT COUNT(*) FILTER (WHERE accident_date IS NULL) AS missing_date,
       COUNT(*) FILTER (WHERE hour IS NULL) AS missing_hour,
       COUNT(*) FILTER (WHERE district IS NULL) AS missing_district,
       COUNT(*) FILTER (WHERE severity  IS NULL) AS missing_severity,
       COUNT(*) FILTER (WHERE longitude  IS NULL) AS missing_longitude,
       COUNT(*) FILTER (WHERE latitude IS NULL) AS missing_latitude
FROM hamburg_accidents;

-- Result:
--  missing_date | missing_hour | missing_district | missing_severity | missing_longitude | missing_latitude
-- --------------+--------------+------------------+------------------+-------------------+------------------
--             0 |            0 |                0 |                0 |                 0 |                0

-- -------------------------------------------------------------
-- 4) Impossible hours
-- -------------------------------------------------------------

SELECT COUNT(*) AS wrong_hour
FROM hamburg_accidents
WHERE hour NOT BETWEEN 0 AND 23;

-- Result:
--  wrong_hour
-- ------------
--           0

-- -------------------------------------------------------------
-- 5) Do month_name and weekday match accident_date?
-- -------------------------------------------------------------
-- accident_date was extracted from accident_id in Excel. This check
-- proves the extraction is correct by comparing it with the month and
-- weekday columns that came from the source.

SELECT COUNT(*) FILTER (WHERE TO_CHAR(accident_date, 'Mon') <> month_name)    AS wrong_month,
       COUNT(*) FILTER (WHERE TRIM(TO_CHAR(accident_date, 'Dy')) <> weekday)  AS wrong_weekday
FROM hamburg_accidents;

-- Result:
--  wrong_month | wrong_weekday
-- -------------+---------------
--            0 |             0

-- Note: the first time, this check showed 7057 wrong weekdays (every row).
-- Reason: the query used full day names (Wednesday), but the table has
-- short names (Wed). I changed 'Day' to 'Dy' in the query.
-- After that: 0 wrong rows. The date from the ID is correct for all rows.

-- -------------------------------------------------------------
-- 6) Do the label columns contain only expected values?
-- -------------------------------------------------------------

SELECT 'severity' AS column_name, severity AS value, COUNT(*) FROM hamburg_accidents GROUP BY severity
UNION ALL
SELECT 'light', light, COUNT(*) FROM hamburg_accidents GROUP BY light
UNION ALL
SELECT 'road_condition', road_condition, COUNT(*) FROM hamburg_accidents GROUP BY road_condition
UNION ALL
SELECT 'district', district, COUNT(*) FROM hamburg_accidents GROUP BY district
ORDER BY column_name, value;

-- Result:
--  column_name    | value          | count
-- ----------------+----------------+-------
--  district       | Altona         |   912
--  district       | Bergedorf      |   396
--  district       | Eimsbüttel     |  1043
--  district       | Hamburg-Mitte  |  1696
--  district       | Hamburg-Nord   |  1140
--  district       | Harburg        |   555
--  district       | Wandsbek       |  1315
--  light          | Darkness       |  1423
--  light          | Daylight       |  5245
--  light          | Twilight       |   389
--  road_condition | Dry            |  5265
--  road_condition | Icy (winter)   |   113
--  road_condition | Wet            |  1679
--  severity       | Fatal          |    21
--  severity       | Serious injury |   569
--  severity       | Slight injury  |  6467
--
-- All columns have only the expected values: no #N/A, no empty cells, no spelling mistakes.
-- In every column the numbers add up to 7,057, so no row is missing a value.

-- -------------------------------------------------------------
-- 7) Accidents without any participant
-- -------------------------------------------------------------

-- Plausibility check: every accident needs at least one road user.

SELECT COUNT(*) AS without_participant
FROM hamburg_accidents
WHERE is_bicycle + is_car + is_pedestrian + is_motorcycle + is_truck + is_other = 0;

-- Result:
--  without_participant
-- ---------------------
--                    0
-- Every accident has at least one road user marked.
