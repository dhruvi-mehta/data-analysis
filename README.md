Mental Health Facility Access & Outcomes in the U.S.
Does building more facilities actually improve mental health?

Project Overview: 
Over 1 in 5 adults in the United States experience mental illness each year (NIMH, 2023), yet fewer than 50% of those adults were able to access care in 2021 (NAMI, 2023). These gaps are even more pronounced among marginalized groups, including LGBTQ+ communities, communities of color, and rural populations, who face compounding barriers such as provider shortages, affordability issues, and geographic inaccessibility. 
The consequences are significant. An estimated 33.5% of adults with mental illness also struggle with substance use, and 70% of youth in juvenile detention have been diagnosed with a mental health condition. 

This project investigates a simple question: 

Does the number of mental health treatment facilities in a state improve mental health outcomes for its residents? 

Using 2023 national data from two federal sources, this analysis tests whether facility availability is the solution or whether deeper structural factors are at play.

Research Question & Hypotheses: 

Research Question: How does the geographic distribution of mental health treatment facilities impact community mental health outcomes in the U.S.? 

Hypothesis Statement: 

H₀: There is no statistically significant relationship between facility access and mental health outcomes. 

H₁: There is a statistically significant relationship between mental health facility availability and mental health outcomes. 


Key Findings: 

Facility density alone is not enough. States with higher mental health facility density (e.g., Maine, Vermont) did not show significantly better mental health outcomes. The correlation between facility density and average poor mental health days was weak and non-significant (r = -0.19, p > 0.05).
A slight positive correlation was found between facility density and depression diagnosis rates (r = 0.19), but this was also not statistically significant.
Socioeconomic status is the real driver. A Principal Component Analysis (PCA)-derived SES index combining income, education, and insurance coverage was the only statistically significant predictor of mental health outcomes (p < 0.001) in the regression model.
Regional disparities are stark. States in the Southeast and parts of the Midwest showed alarmingly low facility density relative to their populations, while states in the Northeast had higher facility density. Yet facility density did not translate directly into better outcomes. 


Bottom line: Access to care is not the same as the ability to use it. Structural conditions, including income, education, and insurance coverage, shape mental health outcomes more than physical proximity to facilities.

Data Sources: 

1. Behavioural Risk Factor Surveillance System (BRFSS) 2023 

Source: Centers for Disease Control and Prevention (CDC) 
Unit: Individual survey responses, aggregated to the state level 
File: LLCP2023.XPT 
Download: https://www.cdc.gov/brfss/annual_data/annual_2023.html 

Variable Description: 

MENTHLTH: Number of poor mental health days in the past 30 days
ADDEPEV3: Ever diagnosed with depression (binary)
EDUCA: Education level 
INCOME3: Income bracket 
PRIMINS1: Primary health insurance status 

_STATE: State FIPS code

2. National Substance Use and Mental Health Services Survey (NSUMHSS) 2023 

Source: Substance Abuse and Mental Health Services Administration (SAMHSA) 

Unit: Facility-level data, aggregated to the state level 

File: NSUMHSS_2023_PUF_CSV.csv 

Download: https://www.samhsa.gov/data/ 


Variable Description: 

INMH: Indicator facility offers mental health services  

LOCATIONSTATE: State abbreviation of facility location 

3. State Population Data 

Source: U.S. Census Bureau, Population Estimates Program (2023) 

Note: Manually entered in script for normalization (facilities per 100k residents) 

Methods 

Data Preparation 

Filtered NSUMHSS to mental health facilities only (INMH == 1) 

Calculated facility density per 100,000 residents by state 

Cleaned BRFSS data by removing invalid/refused responses 

Aggregated BRFSS to the state level 


Socioeconomic Index (PCA) 

Combined income (INCOME3), education (EDUCA), and insurance coverage (PRIMINS1) into a single SES index using Principal Component Analysis 

Reduces multicollinearity and captures the broader structural environment 


Statistical Analysis 

Pearson correlation tests (facility density vs. mental health outcomes) 

Multiple linear regression: avg_mental_days ~ facility_density_per_100k + avg_income + avg_educ 

PCA regression: avg_mental_days ~ facility_density_per_100k + avg_pca_index 


Visualizations 

The project produces four key visualizations: 

Choropleth Map - Mental health facility density per 100k people by state 

Scatter Plot - Facility density vs. average poor mental health days 

Scatter Plot - Facility density vs. depression rate 

Scatter Plot - SES index (PCA) vs. facility density 


Download the raw data files (too large for GitHub) and place them in the data/ folder: 


BRFSS 2023: Download LLCP2023.XPT from the CDC BRFSS page 

NSUMHSS 2023: Download NSUMHSS_2023_PUF_CSV.csv from SAMHSA 



Open analysis. R and run the full script. It is recommended to use RStudio with the included. Rproj file, which sets the working directory automatically.

Limitations 

Self-reported data: BRFSS relies on self-reporting, which may introduce recall or social desirability bias, particularly for mental health measures 

Cross-sectional design: Data from a single year (2023) limits the ability to assess trends or establish causality 

State-level aggregation: Local and community-level nuances, such as urban/rural differences, are likely masked at the state level 


Future Directions 

Incorporate multi-year data to track trends over time 

Apply logistic regression or multilevel modeling to capture interaction effects between regional and individual factors 

Include qualitative data on stigma, cultural barriers, and perceived quality of care 

Explore the role of telehealth expansion post-COVID-19 and its impact on access in underserved regions 



References
Centers for Disease Control and Prevention (CDC). (2023). Behavioral Risk Factor Surveillance System (BRFSS). https://www.cdc.gov/brfss/index.html
National Alliance on Mental Illness (NAMI). (2023). Mental Health by the Numbers. https://www.nami.org/about-mental-illness/mental-health-by-the-numbers/
National Institute of Mental Health (NIMH). (2023). Mental Illness. https://www.nimh.nih.gov/health/statistics/mental-illness
Substance Abuse and Mental Health Services Administration (SAMHSA). (2023). National Substance Use and Mental Health Services Survey (NSUMHSS). https://www.samhsa.gov/
U.S. Census Bureau. (2023). Population Estimates Program. https://www.census.gov/programs-surveys/popest.html
