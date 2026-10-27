# Hamburg Road Accident Analysis 2025

Analysis of all **7,057 road accidents with injured people in Hamburg in 2025**, using official open data.
I cleaned the raw data in **Excel**, checked and analysed it with **SQL (PostgreSQL)** and built a two-page dashboard in **Power BI**.

![Dashboard page 1](dashboard/dashboard_page1_when.png)

---

## Goal

The goal is to answer three questions that a city traffic department would ask:

- **When** do accidents happen? (month, weekday, hour)
- **Where** do they happen, and where are they most **severe**?
- **Who** is most at risk, and which situations are most dangerous?

"Severe" in this project means **fatal or serious injury**.

---

## Key Numbers

| Accidents | Fatal | Severe | Severe rate | Bicycle involved |
|---|---|---|---|---|
| 7,057 | 21 | 590 | 8.4 % | 40.6 % |

That is about **19 accidents with injuries every day**.

---

## Main Findings

**1. Accidents follow working life.**
Monday to Friday have 1,054 to 1,166 accidents each. Sunday has only 617, about half of Friday.
On working days there is a clear morning peak at 7-8 h. **25 % of all accidents happen between 15:00 and 18:00.**

**2. Weekend nights are riskier.**
Between 00:00 and 04:00, weekends have about **3x more accidents per night** than working days.

**3. The summer peak comes mainly from cyclists.**
July has 764 accidents, February 393. From winter to summer, bicycle accidents grow 2.3x, other accidents only 1.3x.
**2 out of 3 extra summer accidents involve a bicycle.**

**4. Bicycles are involved in 41 % of all accidents.**
In Altona, Eimsbüttel and Hamburg-Nord it is almost every second accident.

**5. Junctions are the biggest known danger for cyclists.**
37 % of bicycle accidents happen when a vehicle turns off, turns in or crosses.

**6. Most accidents does not mean most dangerous.**
Hamburg-Mitte has the most accidents (24 %), but only 8.4 % are severe.
Bergedorf has the fewest accidents, but **17.7 % are severe**, 3x more than Eimsbüttel (5.9 %).

**7. Pedestrians and darkness make accidents more severe.**
Accidents with pedestrians are severe in 13.7 % of cases (1.6x the average).
In darkness, 10.4 % of accidents are severe, compared to 7.6 % in daylight.

![Dashboard page 2](dashboard/dashboard_page2_where_who.png)

---

## Recommendations

1. **Safer junctions for cyclists**, especially in Altona, Eimsbüttel and Hamburg-Nord.
2. **Speed checks in the outer districts** (Bergedorf, Harburg), where accidents are more often severe.
3. **Start cyclist safety campaigns in spring**, before the summer peak.
4. **More traffic controls on weekday afternoons (15-18 h) and on weekend nights.**
5. **Better protection for pedestrians in the dark**, for example lighting at crossings.

These recommendations are based on accident data only. They should be checked with traffic and speed data before decisions are made.

---

## How I Worked

### 1. Data cleaning (Excel)
- Imported the national CSV file (semicolon separator, German decimal commas)
- Kept IDs and codes as text, so leading zeros were not lost
- Filtered to Hamburg only: 7,057 accidents
- Checked for duplicates, empty cells and impossible values: none found
- Turned codes into readable labels with lookup tables (for example 1 = Fatal) and kept the original meaning documented
- Renamed the German column names to clear English names
- Removed columns without value for the analysis
- **Found that the accident ID contains the date** (for example `0225`**`0226`**`...` = 26 Feb 2025) and created a date column from it

### 2. Data quality checks (SQL)
Before the analysis, I checked the data with 7 SQL checks: row count, duplicates, date range, missing values, impossible hours, labels and coordinates.
I also checked the new date column against the month and weekday from the source: **0 mismatches in 7,057 rows**.

### 3. Analysis (SQL)
14 queries, each with its result and a short explanation written under the query.

### 4. Dashboard (Power BI)
- **Page 1 – When:** KPIs, weekday chart, monthly trend, heatmap (weekday x hour)
- **Page 2 – Where and for whom:** map of severe accidents, districts, severe rate with Hamburg average, bicycle accident types, road user groups

---

## Problems I Solved

| Problem | Solution |
|---|---|
| The CSV opened wrongly in Excel (all data in one column) | Imported it with the text import wizard: semicolon separator, IDs and codes as text |
| "Eimsbüttel" showed as broken characters in PostgreSQL and Power BI | Set the encoding to WIN1252 / 1252 |
| My weekday check first showed **7,057 errors** | The check used full day names (Wednesday), the table had short names (Wed). After fixing the format: 0 errors |
| The Power BI map can show only about 3,500 points | The map shows the 590 severe accidents only |

---

## Limitations

- The data contains **only accidents with injured people**. Accidents with only damage to vehicles are not included.
- There is **no traffic data**. I can show where accidents happen, but not the risk per kilometre driven.
- About **25 % of accidents are "Other"** in the accident type, so their type is unknown.
- Some groups are small (for example 21 fatal accidents), so I did not analyse them in detail.
- Reasons like "higher speed in outer districts" are possible explanations, not proven results.

---

## Tools

| Tool | Used for |
|---|---|
| Excel | Import, cleaning, lookup tables (VLOOKUP), date extraction |
| PostgreSQL | Data quality checks and analysis: `CASE WHEN`, `FILTER`, `UNION ALL`, subqueries, date functions |
| Power BI | Dashboard: DAX measures, heatmap, map, average line, slicers |

---

## Project Structure

```
hamburg-road-accident-analysis/
├── data/
│   └── hamburg_accidents_2025_clean.csv
├── excel/
│   └── hamburg_accidents_2025.xlsx
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_data_quality_checks.sql
│   ├── 03_analysis_time.sql
│   ├── 04_analysis_location.sql
│   └── 05_analysis_risk.sql
├── dashboard/
│   ├── hamburg_road_accidents_2025.pbix
│   ├── dashboard_page1_when.png
│   └── dashboard_page2_where_who.png
└── README.md
```

## How to Run

1. Create a database in PostgreSQL and run `sql/01_create_table.sql`.
2. Import `data/hamburg_accidents_2025_clean.csv` (Header: on, Delimiter: `,`, Encoding: `WIN1252`).
3. Run the other SQL files in order. The expected result is written under each query.
4. Open `dashboard/hamburg_road_accidents_2025.pbix` in Power BI Desktop.

---

## Data Source

**Unfallatlas** – Statistische Ämter des Bundes und der Länder
Download: [opengeodata.nrw.de/produkte/transport_verkehr/unfallatlas](https://www.opengeodata.nrw.de/produkte/transport_verkehr/unfallatlas/) (file `Unfallorte2025_EPSG25832_CSV.zip`)
Description of the columns: [DSB_Unfallatlas_EN.pdf](https://www.opengeodata.nrw.de/produkte/transport_verkehr/unfallatlas/DSB_Unfallatlas_EN.pdf)

---

## Contact

**Dolly**
Data Analyst, Hamburg
[dollykhanna3210@gmail.com](mailto:dollykhanna3210@gmail.com)
