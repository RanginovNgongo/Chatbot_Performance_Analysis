# Chatbot Performance Analytics Dashboard

## 📊 Project Overview
This project transforms raw, messy chatbot interaction logs into a high-level Business Intelligence dashboard. The goal was to analyze the performance, user satisfaction, and system efficiency across different corporate departments.

## 🛠️ The Data Engineering Challenge
The raw dataset arrived with several "real-world" data quality issues that required a robust SQL transformation pipeline:

- **Time Formatting:** Timestamps were in a non-standard `Min:Sec.ms` format (e.g., `29:31.9`).
- **Data Integrity:** Confidence scores and user ratings contained `NULL` values and inconsistent scales.
- **Consistency:** Department names and User Roles had inconsistent casing.
- **Business Logic:** No existing markers for "Success" or "Speed Performance" tiers.

## ⚙️ Technical Solution: SQL Transformation
I built a comprehensive SQL script to clean and engineer the data before it reached Power BI.

### Key Features of the SQL Pipeline:
1. **DateTime Reconstruction:** Unified the date and time while rounding fractional milliseconds to the nearest whole second (e.g., `29:31.9` -> `00:29:32`).
2. **Performance Tiering:** Categorized system speed:
   - **Instant:** < 300ms
   - **Fast:** 300ms - 600ms
   - **Slow:** > 600ms
3. **AI Success Flag:** Developed a success metric based on a combination of **Confidence** (> 0.50) and **User Feedback** (>= 3).

## 📈 Power BI Insights
The final dashboard provides deep-dives into:

- **KPIs:** Total Queries (3200), Avg Confidence (79.5%), AI Success Rate (64.25%), and Response Time (1364ms).
- **Departmental Analysis:** HR and Operations lead in query volume.
- **Satisfaction Trends:** Visualizing positive vs. negative sentiment ratios by department.
- **User Seniority:** Breaking down usage patterns between Interns, Managers, and Executives.

## 📸 PowerBI Dashboard

<img width="616" height="344" alt="image" src="https://github.com/user-attachments/assets/d3542992-4c38-480a-a553-c3c66b6d09e5" />

