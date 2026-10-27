-- =============================================================
-- Hamburg Road Accident Analysis 2025
-- File: 05_analysis_risk.sql
-- Question: WHO is involved and WHAT makes accidents severe? (PostgreSQL)
-- =============================================================

-- -------------------------------------------------------------
-- Q10) Who is involved?
-- -------------------------------------------------------------
-- One accident can involve several groups, so the numbers add up to more than 7,057.
SELECT SUM(is_car)        AS car,
       SUM(is_bicycle)    AS bicycle,
       SUM(is_pedestrian) AS pedestrian,
       SUM(is_motorcycle) AS motorcycle,
       SUM(is_truck)      AS truck,
       SUM(is_other)      AS other
FROM hamburg_accidents;

-- Result:
--  car  | bicycle | pedestrian | motorcycle | truck | other
-- ------+---------+------------+------------+-------+-------
--  4441 |    2867 |        881 |        633 |   294 |  1688
--
-- A car is involved in 63 % of accidents, a bicycle in 41 % (2,867 of 7,057),
-- a pedestrian in 12 %.

-- -------------------------------------------------------------
-- Q11) How severe are accidents per road user group?
-- -------------------------------------------------------------

SELECT 'Bicycle' AS involved,
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_severe
FROM hamburg_accidents
WHERE is_bicycle = 1
UNION ALL
SELECT 'Pedestrian',
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1)
FROM hamburg_accidents
WHERE is_pedestrian = 1
UNION ALL
SELECT 'Motorcycle',
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1)
FROM hamburg_accidents
WHERE is_motorcycle = 1
UNION ALL
SELECT 'All accidents',
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1)
FROM hamburg_accidents
ORDER BY pct_severe DESC;

-- Result:
--  involved      | pct_severe
-- ---------------+------------
--  Pedestrian    |       13.7
--  Motorcycle    |       12.0
--  All accidents |        8.4
--  Bicycle       |        7.9
--
-- Pedestrian accidents are most often severe: 13.7 % (about 1 in 7).
-- That is 1.6x the Hamburg average (8.4 %).
-- Motorcycle accidents are also above average (12.0 %).
-- Pedestrians and motorcyclists have no protection, so injuries are worse.
-- Bicycle accidents happen very often (41 % of all accidents, see Q10),
-- but they are slightly less severe than average (7.9 %).

-- -------------------------------------------------------------
-- Q12) Darkness vs daylight: are accidents in the dark more severe?
-- -------------------------------------------------------------

SELECT light,
       COUNT(*) AS accidents,
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_severe
FROM hamburg_accidents
GROUP BY light
ORDER BY pct_severe DESC;

-- Result:
--  light    | accidents | pct_severe
-- ----------+-----------+------------
--  Twilight |       389 |       11.6
--  Darkness |      1423 |       10.4
--  Daylight |      5245 |        7.6
--
-- Accidents in darkness are more often severe than in daylight:
-- 10.4 % vs 7.6 %, that is 1.4x higher.
-- Twilight has the highest rate (11.6 %), but only 389 cases,
-- so this number is less reliable.

-- -------------------------------------------------------------
-- Q13) Which accident kinds are most frequent and most severe?
-- -------------------------------------------------------------

SELECT accident_kind,
       COUNT(*) AS accidents,
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_severe
FROM hamburg_accidents
GROUP BY accident_kind
ORDER BY accidents DESC;

-- Result:
--  accident_kind                        | accidents | pct_severe
-- --------------------------------------+-----------+------------
--  Other                                |      1775 |        9.1
--  Turning or crossing collision        |      1764 |        7.9
--  Rear-end collision                   |      1118 |        2.8
--  Side collision, same direction       |       852 |        6.5
--  Vehicle vs pedestrian                |       782 |       13.4
--  Hit starting/stopping/parked vehicle |       278 |        7.9
--  Head-on collision                    |       267 |       12.0
--  Left road to the right               |       114 |       21.1
--  Left road to the left                |        77 |       22.1
--  Hit obstacle on road                 |        30 |       10.0
--
-- Rear-end collisions happen often (1,118), but are rarely severe (2.8 %).
-- They usually happen at low speed, in traffic.
-- Leaving the road happens rarely (191 cases), but about 1 in 5 is severe (21–22 %).
-- These accidents probably happen at higher speed, against trees or walls.
-- "Other" is the largest group (1,775, about 25 %). The data does not say
-- what kind of accident these are. This is a limitation of the data.

-- -------------------------------------------------------------
-- Q14) Cyclists: which accident types hit them most?
-- -------------------------------------------------------------

SELECT accident_type,
       COUNT(*) AS bicycle_accidents
FROM hamburg_accidents
WHERE is_bicycle = 1
GROUP BY accident_type
ORDER BY bicycle_accidents DESC;

-- Result:
--  accident_type         | bicycle_accidents
-- -----------------------+-------------------
--  Other                 |               918
--  Turning in / crossing |               587
--  Turning off           |               462
--  Along the road        |               330
--  Stationary vehicle    |               268
--  Driving accident      |               225
--  Pedestrian crossing   |                77
--
-- Turning in / crossing (587) + turning off (462) = 1,049 of 2,867
-- bicycle accidents (37 %, more than 1 in 3).
-- Both happen at junctions, so junctions are the biggest known danger for cyclists.
-- ("Other" is also large (918), but the data does not say what these accidents are.)
