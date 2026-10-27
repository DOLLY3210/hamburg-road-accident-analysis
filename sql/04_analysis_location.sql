-- =============================================================
-- Hamburg Road Accident Analysis 2025
-- File: 04_analysis_location.sql
-- Question: WHERE do accidents happen in Hamburg? (PostgreSQL)
--
-- =============================================================

-- -------------------------------------------------------------
-- Q7) Accidents per district and share of total
-- -------------------------------------------------------------

SELECT district,
       COUNT(*) AS accidents,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM hamburg_accidents), 1) AS pct_of_total
FROM hamburg_accidents
GROUP BY district
ORDER BY accidents DESC;

-- Result:
--  district      | accidents | pct_of_total
-- ---------------+-----------+--------------
--  Hamburg-Mitte |      1696 |         24.0
--  Wandsbek      |      1315 |         18.6
--  Hamburg-Nord  |      1140 |         16.2
--  Eimsbüttel    |      1043 |         14.8
--  Altona        |       912 |         12.9
--  Harburg       |       555 |          7.9
--  Bergedorf     |       396 |          5.6
-- Hamburg-Mitte has the most accidents (24 %, almost 1 in 4).
-- Note: Hamburg-Mitte also has the most traffic. I have no traffic data,
-- so I can say where most accidents happen, but not where driving is most risky.

-- -------------------------------------------------------------
-- Q8) Which district has the most SEVERE accidents?
-- -------------------------------------------------------------

SELECT district,
       COUNT(*) AS accidents,
       SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END) AS severe,
       ROUND(100.0 * SUM(CASE WHEN severity IN ('Fatal', 'Serious injury') THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_severe
FROM hamburg_accidents
GROUP BY district
ORDER BY pct_severe DESC;

-- Result:
--  district      | accidents | severe | pct_severe
-- ---------------+-----------+--------+------------
--  Bergedorf     |       396 |     70 |       17.7
--  Harburg       |       555 |     62 |       11.2
--  Hamburg-Mitte |      1696 |    142 |        8.4
--  Wandsbek      |      1315 |    109 |        8.3
--  Altona        |       912 |     67 |        7.3
--  Hamburg-Nord  |      1140 |     78 |        6.8
--  Eimsbüttel    |      1043 |     62 |        5.9
--
-- More accidents does not mean more dangerous.
-- Bergedorf has the fewest accidents (396), but 17.7 % of them are severe.
-- That is 3x more than Eimsbüttel (5.9 %) and about 2x the Hamburg average (8.4 %).
-- Harburg is also above average (11.2 %).
-- Possible reason: higher speeds on the roads outside the city centre.
-- This is only a guess, because I have no speed data.

-- -------------------------------------------------------------
-- Q9) Bicycle accidents per district
-- -------------------------------------------------------------

SELECT district,
       SUM(is_bicycle) AS bicycle_accidents,
       ROUND(100.0 * SUM(is_bicycle) / COUNT(*), 1) AS pct_bicycle
FROM hamburg_accidents
GROUP BY district
ORDER BY bicycle_accidents DESC;

-- Result:
--  district      | bicycle_accidents | pct_bicycle
-- ---------------+-------------------+-------------
--  Hamburg-Mitte |               599 |        35.3
--  Hamburg-Nord  |               528 |        46.3
--  Eimsbüttel    |               494 |        47.4
--  Wandsbek      |               491 |        37.3
--  Altona        |               452 |        49.6
--  Bergedorf     |               159 |        40.2
--  Harburg       |               144 |        25.9
--
-- In Altona (49.6 %), Eimsbüttel (47.4 %) and Hamburg-Nord (46.3 %)
-- almost every second accident involves a bicycle (about 1 in 2).
-- In Harburg it is only about 1 in 4 (25.9 %).
-- Hamburg-Mitte has the most bicycle accidents in number (599),
-- but a lower share (35.3 %), because it also has many car accidents.
-- Bicycle safety measures would help most in Altona, Eimsbüttel and Hamburg-Nord.
