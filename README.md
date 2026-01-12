# End-to-End-Clinical-Trial-Safety-and-Time-to-Event-Analysis-Using-SAS-ADaM-Aligned-
📖 Project Overview

This project demonstrates an end-to-end statistical programming workflow for a simulated Phase II oncology clinical trial, following industry-standard CRO practices. The focus is on building analysis-ready ADaM datasets, performing safety and efficacy analyses, generating tables, listings, and figures (TLFs), and applying independent QC validation.

The project was intentionally designed to mirror the day-to-day responsibilities of a Statistical Analyst / Statistical Programmer in a CRO environment.

🎯 Study Design (Simulated)

Phase: Phase II

Therapeutic Area: Oncology

Design: Randomized, Treatment vs Placebo

Primary Endpoint: Overall Survival (OS)

Safety Population: All treated subjects

All data used in this project are simulated to allow full control over derivations and to avoid privacy concerns.

🧩 Analysis Workflow

1️⃣ Subject-Level Dataset (ADSL)

Derived core demographics, treatment assignment, key dates, and population flags

Key derivations include:

Age groups

Planned and actual treatment variables

Randomization date

First and last treatment dates

ITT, Safety, and Efficacy population flags

Purpose: Provide a clean foundation for all downstream analyses.

2️⃣ Adverse Events Dataset (ADAE)

Built by merging AE data with ADSL

Derived Treatment-Emergent Adverse Event Flag (TRTEMFL) based on AE start date relative to first treatment date

Supports safety summaries by:

System Organ Class (SOC)

Preferred Term (PT)

Treatment group

Purpose: Enable regulatory-style safety analyses and AE summary tables.

3️⃣ Time-to-Event Dataset (ADTTE)

Created for Overall Survival (OS)

Event defined as death

Subjects without a death record are censored

Time calculated from randomization to event or censoring

Purpose: Serve as direct input to Kaplan–Meier survival analyses.

📊 Tables, Listings, and Figures (TLFs)
🔹 Kaplan–Meier Plot

Generated using PROC LIFETEST

Stratified by treatment group

Demonstrates correct handling of censoring and event indicators

🔹 AE Summary Table

Treatment-emergent adverse events summarized by SOC and PT

Counts based on unique subjects per treatment group

✅ Quality Control (QC)

Independent QC programs were created to validate key results:

AE counts validated using an independent method (PROC FREQ vs PROC SQL)

Population flags and treatment assignments verified using frequency checks

This reflects standard CRO practice for ensuring data accuracy and traceability.
