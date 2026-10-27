-- =============================================================
-- Hamburg Road Accident Analysis 2025
-- File: 01_create_table.sql
-- Creates the table and loads the cleaned CSV (PostgreSQL)
--
-- Source:  Unfallatlas - Statistische Ämter des Bundes und der Länder
--          (road accidents with injured people, Hamburg, 2025)
-- =============================================================

DROP TABLE IF EXISTS hamburg_accidents;

CREATE TABLE hamburg_accidents (
    accident_id     VARCHAR(30) PRIMARY KEY,
    accident_date   DATE,                     -- extracted from accident_id in Excel
    year            INT,
    month_name      VARCHAR(5),               -- Jan ... Dec
    weekday         VARCHAR(10),
    hour            INT,                      -- 0 ... 23
    district        VARCHAR(20),              -- Hamburg district
    kreis_code      VARCHAR(3),
    area_code       VARCHAR(3),
    severity        VARCHAR(20),
    accident_kind   VARCHAR(50),
    accident_type   VARCHAR(30),
    light           VARCHAR(10),
    road_condition  VARCHAR(15),
    is_bicycle      INT,
    is_car          INT,
    is_pedestrian   INT,
    is_motorcycle   INT,
    is_truck        INT,
    is_other        INT,
    longitude       NUMERIC(10,7),
    latitude        NUMERIC(10,7)
);

-- -------------------------------------------------------------
-- Load the data
-- -------------------------------------------------------------
-- pgAdmin: right-click the table > Import/Export Data > Import
--   Format: csv | Header: ON | Delimiter: , | Encoding: WIN1252
--
-- WIN1252 is needed because Excel saved the CSV in Windows encoding.
-- With UTF-8, "Eimsbüttel" didn't load correctly.

-- -------------------------------------------------------------
-- Quick check after loading
-- -------------------------------------------------------------

SELECT *
FROM hamburg_accidents
LIMIT 5;

-- Expected: 5 rows with readable labels.
