-- =============================================================
-- Hamburg Road Accident Analysis 2025
-- File: 03_analysis_time.sql
-- Question: WHEN do accidents happen in Hamburg? (PostgreSQL)
-- =============================================================

-- -------------------------------------------------------------
-- Q1) Overview KPIs
-- -------------------------------------------------------------
SELECT COUNT(*) AS total_accidents,
       SUM(CASE WHEN severity = 'Fatal'   THEN 1 ELSE 0 END) AS fatal,
       SUM(CASE WHEN severity = 'Serious injury' THEN 1 ELSE 0 END) AS serious,
       SUM(CASE WHEN severity = 'Slight injury'  THEN 1 ELSE 0 END) AS slight,
       SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END) AS severe,
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_severe,
       ROUND(COUNT(*) / 365.0, 1)  AS accidents_per_day
FROM hamburg_accidents;

-- Result:
--  total_accidents | fatal | serious | slight | severe | pct_severe | accidents_per_day
-- -----------------+-------+---------+--------+--------+------------+-------------------
--             7057 |    21 |     569 |   6467 |    590 |        8.4 |              19.3
--
-- About 19 accidents with injuries every day. 590 accidents (8.4 %) were severe.

-- -------------------------------------------------------------
-- Q2) Accidents per month (seasonal pattern)
-- -------------------------------------------------------------
-- month_name is text and would sort alphabetically (Apr, Aug, Dec ...),
-- so the month number from the date is used for sorting.

SELECT EXTRACT(MONTH FROM accident_date) AS month_no, month_name,
         COUNT(*)     AS accidents
FROM hamburg_accidents
GROUP BY 1, 2
ORDER BY 1;

-- Result:
--  month_no | month_name | accidents
-- ----------+------------+-----------
--         1 | Jan        |       457
--         2 | Feb        |       393
--         3 | Mar        |       495
--         4 | Apr        |       589
--         5 | May        |       686
--         6 | Jun        |       755
--         7 | Jul        |       764
--         8 | Aug        |       592
--         9 | Sep        |       733
--        10 | Oct        |       602
--        11 | Nov        |       543
--        12 | Dec        |       448
--
-- Most accidents happen in summer: July has 764 accidents, February 393 (fewest in winter).
-- July: about 25 accidents per day, February: about 14.
-- So a summer day has almost twice as many accidents as a winter day.
-- The next query (Q3) checks if cyclists are the reason.

-- -------------------------------------------------------------
-- Q3) Is the summer peak caused by cycling?
-- -------------------------------------------------------------

SELECT EXTRACT(MONTH FROM accident_date) AS month_no, month_name,
       SUM(is_bicycle)  AS bicycle_accidents,
       COUNT(*) - SUM(is_bicycle)  AS other_accidents
FROM hamburg_accidents
GROUP BY 1, 2
ORDER BY 1;

-- Result:
--  month_no | month_name | bicycle_accidents | other_accidents
-- ----------+------------+-------------------+-----------------
--         1 | Jan        |               150 |             307
--         2 | Feb        |               125 |             268
--         3 | Mar        |               199 |             296
--         4 | Apr        |               254 |             335
--         5 | May        |               323 |             363
--         6 | Jun        |               360 |             395
--         7 | Jul        |               347 |             417
--         8 | Aug        |               243 |             349
--         9 | Sep        |               304 |             429
--        10 | Oct        |               239 |             363
--        11 | Nov        |               181 |             362
--        12 | Dec        |               142 |             306
--
--   Winter (Dec–Feb) vs summer (Jun–Aug):
--   bicycle accidents  417 ->   950  (2.3x)
--   other accidents    881 -> 1,161  (1.3x)
--  (Summer has 2,111 accidents and winter 1,298, so summer has 813 more.
--  Of these 813 extra accidents, 533 are bicycle accidents (950 − 417).
-- 533 ÷ 813 = 66 %, so 2 out of 3 extra summer accidents involve a bicycle.)
-- The summer peak is driven mainly by cycling.
-- Bicycle accidents drop in August (243). Possible reason: summer
-- school holidays, when fewer people commute (not proven).

-- -------------------------------------------------------------
-- Q4) Accidents per weekday (1 = Monday ... 7 = Sunday)
-- -------------------------------------------------------------

SELECT EXTRACT(ISODOW FROM accident_date) AS weekday_no,
       TO_CHAR(accident_date, 'Dy')    AS weekday,
       COUNT(*)  AS accidents
FROM hamburg_accidents
GROUP BY 1, 2
ORDER BY 1;

-- Result:
--  weekday_no | weekday | accidents
-- ------------+---------+-----------
--           1 | Mon     |      1054
--           2 | Tue     |      1127
--           3 | Wed     |      1132
--           4 | Thu     |      1067
--           5 | Fri     |      1166
--           6 | Sat     |       894
--           7 | Sun     |       617
--
-- Monday to Friday have a similar number of accidents (1,054 to 1,166).
-- Friday has the most (1,166).
-- Sunday has the fewest (617), about half as many as Friday.
-- Likely reason: less traffic on Sundays (no work commute, shops closed).

-- -------------------------------------------------------------
-- Q5) Accidents per hour
-- -------------------------------------------------------------

SELECT hour,
       COUNT(*) AS accidents
FROM hamburg_accidents
GROUP BY hour
ORDER BY hour;

-- Result:
--  hour | accidents      hour | accidents
-- ------+-----------    ------+-----------
--     0 |        80        12 |       433
--     1 |        72        13 |       509
--     2 |        39        14 |       499
--     3 |        32        15 |       573
--     4 |        42        16 |       602
--     5 |        86        17 |       591
--     6 |       150        18 |       509
--     7 |       371        19 |       322
--     8 |       396        20 |       265
--     9 |       308        21 |       206
--    10 |       308        22 |       152
--    11 |       399        23 |       113
--
-- Peak at 16:00. The three hours 15:00–18:00 have 1,766 accidents,
-- 25 % of the whole year (probably people driving home from work).
-- Second, smaller peak at 7–8 (people going to work and school).

-- -------------------------------------------------------------
-- Q6) Working days vs weekend: different peak hours?
-- -------------------------------------------------------------

SELECT hour,
       SUM(CASE WHEN EXTRACT(ISODOW FROM accident_date) <= 5 THEN 1 ELSE 0 END) AS weekday_accidents,
       SUM(CASE WHEN EXTRACT(ISODOW FROM accident_date) >= 6 THEN 1 ELSE 0 END) AS weekend_accidents
FROM hamburg_accidents
GROUP BY hour
ORDER BY hour;

-- Result:
--  hour | weekday | weekend      hour | weekday | weekend
-- ------+---------+---------    ------+---------+---------
--     0 |      35 |      45        12 |     334 |      99
--     1 |      35 |      37        13 |     385 |     124
--     2 |      13 |      26        14 |     377 |     122
--     3 |      15 |      17        15 |     456 |     117
--     4 |      23 |      19        16 |     489 |     113
--     5 |      65 |      21        17 |     457 |     134
--     6 |     139 |      11        18 |     402 |     107
--     7 |     359 |      12        19 |     242 |      80
--     8 |     374 |      22        20 |     199 |      66
--     9 |     274 |      34        21 |     148 |      58
--    10 |     248 |      60        22 |      96 |      56
--    11 |     308 |      91        23 |      73 |      40
--
-- Working days: strong morning peak at 7–8 (359, 374), almost absent at
-- weekends (12, 22). This is commuter traffic.
-- Weekend nights: 00:00–04:00 has 125 accidents on weekends vs 98 on
-- working days. 2025 had 104 weekend days and 261 working days, so per
-- night weekends have about 3x more accidents.
