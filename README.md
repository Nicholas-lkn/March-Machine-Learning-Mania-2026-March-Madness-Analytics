# March Madness Analytics

NCAA March Madness analytics project exploring team performance trends, streakiness, and tournament outcome prediction using historical NCAA data. Combines R for EDA and visualization with Python for predictive modeling (logistic regression, random forest, XGBoost).

## Dataset
Download from: https://www.kaggle.com/competitions/march-machine-learning-mania-2026/data
Place all CSVs into `data/raw/`

## Tools Used
- **R** — ETL, cleaning, EDA, visualizations
- **Python** — predictive modeling (logistic regression, random forest, XGBoost)
- **SQLite** — local queryable storage layer
- **Google BigQuery** — cloud storage (bonus)

## Folder Structure
```
├── data/
│   ├── raw/          ← original Kaggle CSVs
│   └── cleaned/      ← processed datasets and data dictionary as csv file
├── r/
│   ├── explore.R
│   ├── clean.R
│   ├── eda.R
│   ├── sqlite.R
│   └── report.Rmd
├── notebooks/
│   └── modelling.ipynb
├── models/         ← pretrained models
├── reports/        ← images of all created plots
└── README.md
```

## How to Run
1. Download dataset from Kaggle and place CSVs in `data/raw/`
2. Run R scripts in order: `01_explore.R` → `02_clean.R` → `03_eda.R` → `04_sqlite.R`
3. Run `notebooks/01_modeling.ipynb` for modeling
4. Knit `r/04_report.Rmd` to generate PDF report

## Requirements
**R packages:** tidyverse, RSQLite, DBI
**Python packages:** pandas, scikit-learn, xgboost, matplotlib, seaborn

## AI Disclosure
Claude was used as a coding assistant for guidance in project structure

## References
- Kaggle March Machine Learning Mania 2026
