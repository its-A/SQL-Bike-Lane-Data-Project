# City Bike Lane Safety & Infrastructure Review

## Overview
SQL-driven exploratory analysis of city bike lane safety ratings. This project evaluates 30 bike corridors across 
60 rider-submitted ratings (ficticious) to classify infrastructure performance, measure the impact of physical protection and lane
width, and prioritize corridors for intervention.

## Business Problem
City transportation planners need a consistent, data-backed framework to allocate maintenance and redesign budgets across the bike lane network. Without standardized thresholds and structural context (protection status and lane width), it is difficult to separate isolated low scores from systemic design issues.

## Dataset & Schema
- **Source File:** `city_bike_lanes.csv` (table: `CityBikeLanes`)
- **Scope:** 60 total records covering 30 unique streets (2 ratings per street), installed between 2002 and 2016 and updated in 2020–2021.
- **Key Columns:**
  - `id` (INT): Unique rating record identifier
  - `street` (VARCHAR): Street name of the bike lane corridor
  - `width_feet` (DECIMAL): Lane width in feet (`3.4` to `4.5` ft)
  - `safety_rating` (DECIMAL): Rider-submitted safety score (`2.0` to `5.0`)
  - `protected` (VARCHAR): Whether the lane has physical protection (`Yes` / `No`)
  - `year_installed` / `year_updated` (INT): Installation and last update years

## Data Standardization
- **Null-Safe Counting:** Used `COUNT(safety_rating)` rather than `COUNT(*)` in aggregations so missing ratings would not skew sample-size counts.

## Business Rules & Methodology
Each street is evaluated by its mean safety rating using a two-stage Common Table Expression (CTE) pipeline:
| Average Safety Rating | Recommendation | Action |
| :--- | :--- | :--- |
| `>= 4.0` | **Leave As-Is** | Meets safety standards; routine maintenance only. |
| `2.5` to `3.99` | **Improvements Needed** | Target for signage, striping, or barrier upgrades. |
| `< 2.5` | **Remove** | Critical safety deficit; evaluate for removal or full redesign. |

**SQL Techniques Applied:**
- **CTEs (`WITH`)** to compute street-level averages once and reuse them cleanly across classification and rollup queries.
- **Window Functions** (`AVG() OVER (PARTITION BY street)`, `SUM(COUNT(*)) OVER ()`) for row-level benchmarking (`recommendation.csv`) and network-wide percentage shares (`recommendation_pct.csv`).
- **Conditional Logic (`CASE`)** to map continuous safety scores to actionable operational tiers.


## Key Findings
1. **Majority Meet Standards, 43% Need Action:** Out of 30 streets, **56.67% (17 streets)** are rated **Leave As-Is**, **23.33% (7 streets)** require **Improvements Needed**, and **20.00% (6 streets)** are flagged for **Remove**.
2. **Highest & Lowest Performers:** **Pine** and **Kensington** tied for the highest average rating (**4.95**), while **Market** and **Altin** tied for the lowest (**2.00**).
3. **Protection Drives Higher Safety:** Protected lanes averaged **4.32** compared to **3.33** for unprotected lanes (**+0.99 points**). None of the protected lanes fell into the `Remove` tier.
4. **Lane Width Is a Structural Dividing Line:** All 6 `Remove` streets (**Market, Altin, Parker, Beaver, Lombard, Manning**) are both **unprotected** and **under 4.0 ft wide** (`3.4–3.8 ft`). Conversely, every unprotected street that achieved **Leave As-Is** (6 streets) measured **4.5 ft** wide (averaging **4.47**).

## Recommendations
1. **Prioritize Sub-4 ft Unprotected Corridors:** Target **Market, Altin, Parker, Beaver, Lombard, and Manning** first—either widen them to at least 4.0–4.5 ft, add physical barriers, or decommission the lanes.
2. **Upgrade the "Improvements Needed" Tier:** Because all 7 streets in this tier (e.g., **2nd**, **Museum**, **Walnut**, **Addison**, **MLK**) are already `4.0 ft` wide and protected, targeted visibility, intersection, or surface upgrades are likely more cost-effective than full reconstruction.
3. **Enforce Minimum Design Standards:** Require new bike lanes to meet a **4.0 ft minimum width** (or **4.5 ft** when physical protection is not feasible) and enforce `Yes`/`No` constraints at data entry.

## Repository Files
- `city_bike_lanes.csv` — Raw dataset (60 rows, 30 streets)
- `safety_rating_4higher.csv` — Streets averaging `>= 4.0` (`Safe Lane`)
- `recommendation.csv` — Row-level street ratings with window-function averages and tiers
- `recommendation_pct.csv` — Executive summary of street counts, network percentages, and total ratings by tier

## Tools Used
- **Database:** MySQL
- **IDE:** MySQL Workbench