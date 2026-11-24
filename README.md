# Olist delivery analysis

Which orders arrive after the date the customer was promised, and which customer states have the highest late rate?

I built this as a learning project with Python (Jupyter), SQL Server Express and Power BI Desktop, using the public Olist Brazilian e-commerce data from Kaggle.

## What I did

1. **Python:** loaded the orders table, checked duplicates and missing values, and worked out the late-delivery rate.
2. **SQL Server:** imported the orders and customers tables as raw text, checked the join, calculated the late rate by customer state, and checked that the state rows add back to the Python totals.
3. **Power BI:** loaded a SQL view and built a one-page report with a late-rate measure, a bar chart by state and summary cards.

## The rule

- **Eligible order:** status is `delivered` and both the actual and the estimated delivery dates exist.
- **Late order:** actual delivery date is after the estimated date, compared by calendar day. Delivered on the promised day counts as on time.
- **Late rate:** late orders divided by eligible orders.

## Results

- 99,441 orders in the file. 96,470 are eligible.
- 6,534 were late: **6.77%**.
- Among late orders, the median delay was 7 days and the average was 10.62 days.
- Highest late rates by customer state: AL 21.41% (397 orders), MA 17.43% (717), SE 15.22% (335).
- RJ has 12,350 eligible orders at 12.11%, far more orders than AL (397) even with a lower rate. RR shows 12.20%, but that is only 5 late out of 41 orders, so small states need care.

![Power BI report](images/power_bi_dashboard.jpg)

## Repository contents

| Path | What it is |
| --- | --- |
| `notebooks/01_data_check.ipynb` | Python checks and the late-rate calculation |
| `sql/01_checks_and_state_volume.sql` | Row counts, key checks, join check, eligible orders per state |
| `sql/02_state_late_rate.sql` | Eligible orders, late orders and late rate by customer state |
| `sql/03_reconciliation.sql` | Checks that the state rows add up to the overall totals |
| `images/power_bi_dashboard.jpg` | Screenshot of the report |

## Limits

- It shows where deliveries were late, not why. Courier, seller, distance and season were not tested.
- Descriptive analysis only. No prediction or machine learning.
- The state is the customer's state. Only the orders and customers tables were used.
- The data covers 2016 to 2018, so it does not describe current Olist performance.
- About 100,000 rows. Good practice for joins and reporting, not large-scale data engineering.

## Data

The data is not included in this repository. Download "Brazilian E-Commerce Public Dataset by Olist" from Kaggle: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/ (CC BY-NC-SA 4.0).
