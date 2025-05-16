#set working directory
setwd("~/Desktop/DataAnalysis/FinalProject") # example of setwd() for Mac

# Install packages
install.packages("haven")
install.packages("tidyverse")
install.packages("maps")
install.packages("viridis")

# Load the library
library(haven)
library(tidyverse)
library(maps)
library(viridisLite)
library(dplyr)


# Load BRFSS data (survey responses)
brfss <- read_xpt("LLCP2023.XPT")

# Load NSUMHSS facility data (mental health facility locations)
nsumhss <- read.csv("NSUMHSS_2023_PUF_CSV.csv")

# Filter for mental health facilities only
mh_facilities <- nsumhss %>% filter(INMH == 1)

# Count facilities by state abbreviation
facility_counts <- mh_facilities %>%
  group_by(LOCATIONSTATE) %>%
  summarise(facility_count = n()) %>%
  rename(state_abbr = LOCATIONSTATE)

# Manually entered population data by state (used for normalization)
state_pop <- tibble(
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","FL","GA",
                 "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD",
                 "MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ",
                 "NM","NY","NC","ND","OH","OK","OR","PA","RI","SC",
                 "SD","TN","TX","UT","VT","VA","WA","WV","WI","WY","DC"),
  population = c(5039877,733391,7151502,3011524,39538223,5773714,3605944,989948,
                 21538187,10711908,1455271,1839106,12812508,6785528,3190369,
                 2937880,4505836,4657757,1362359,6177224,7029917,10077331,
                 5706494,2961279,6154913,1084225,1961504,3104614,1377529,
                 9288994,2117522,20201249,10439388,779094,11799448,3959353,
                 4237256,13002700,1097379,5118425,886667,6910840,29145505,
                 3271616,643077,8631393,7693612,1793716,5893718,576851,689545)
)

# Calculate facility density per 100k population
facility_density <- left_join(facility_counts, state_pop, by = "state_abbr") %>%
  mutate(facility_density_per_100k = (facility_count / population) * 100000)


# Select relevant variables and filter invalid responses
brfss_clean <- brfss %>%
  select(`_STATE`, MENTHLTH, GENHLTH, PRIMINS1, EXERANY2, INCOME3, EDUCA, ADDEPEV3, `_METSTAT`, `_URBSTAT`) %>%
  rename(STATE_FIPS = `_STATE`) %>%
  filter(
    !MENTHLTH %in% c(77, 88, 99),
    !GENHLTH %in% c(7, 9),
    !PRIMINS1 %in% c(7, 9),
    !EXERANY2 %in% c(7, 9),
    !INCOME3 %in% c(77, 99),
    !EDUCA %in% c(9),
    !ADDEPEV3 %in% c(7, 9),
    !`_METSTAT` %in% c(9),
    !`_URBSTAT` %in% c(9)
  )


#summarize BRFSS data at the state level
brfss_state_summary <- brfss_clean %>%
  group_by(STATE_FIPS) %>%
  summarise(
    avg_mental_days = mean(MENTHLTH, na.rm = TRUE),
    depression_rate = mean(ADDEPEV3 == 1, na.rm = TRUE),
    avg_income = mean(INCOME3, na.rm = TRUE),
    avg_educ = mean(EDUCA, na.rm = TRUE),
    .groups = "drop"  # ensures grouping column is retained
  )


#Lookup table to convert FIPS to state abbreviation
fips_lookup <- tibble(
  STATE_FIPS = c(1, 2, 4, 5, 6, 8, 9, 10, 11, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
                 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 44,
                 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56),
  state_abbr = c("AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA",
                 "HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA",
                 "MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY",
                 "NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX",
                 "UT","VT","VA","WA","WV","WI","WY")
)

# Merge to add abbreviation
brfss_state_summary <- brfss_state_summary %>%
  left_join(fips_lookup, by = "STATE_FIPS")


# merge mental health outcome data with facility density
mental_health_combined <- left_join(brfss_state_summary, facility_density, by = "state_abbr")


# Correlation analysis/tests
cor.test(mental_health_combined$facility_density_per_100k, mental_health_combined$avg_mental_days)
cor.test(mental_health_combined$facility_density_per_100k, mental_health_combined$depression_rate)

# Visualizations
ggplot(mental_health_combined, aes(x = facility_density_per_100k, y = avg_mental_days)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Facility Density vs. Avg Poor Mental Health Days",
       x = "Facilities per 100k People",
       y = "Avg Poor Mental Health Days (30 Days)")

ggplot(mental_health_combined, aes(x = facility_density_per_100k, y = depression_rate)) +
  geom_point() +
  geom_smooth(method = "lm", se = TRUE) +
  labs(title = "Facility Density vs. Depression Rate",
       x = "Facilities per 100k People",
       y = "Proportion Reporting Depression")


# Filter data for regression
mental_health_model_data <- mental_health_combined %>%
  filter(!is.na(avg_mental_days),
         !is.na(facility_density_per_100k),
         !is.na(avg_income),
         !is.na(avg_educ))

# Linear regression model
model <- lm(avg_mental_days ~ facility_density_per_100k + avg_income + avg_educ,
            data = mental_health_model_data)
summary(model)

# Prepare map data for facility density visualization
facility_density <- facility_density %>%
  mutate(region = tolower(state.name[match(state_abbr, state.abb)]))

us_map <- map_data("state")
map_data_density <- left_join(us_map, facility_density, by = "region")

# Plot facility density map
ggplot(map_data_density, aes(x = long, y = lat, group = group, fill = facility_density_per_100k)) +
  geom_polygon(color = "white") +
  coord_fixed(1.3) +
  theme_minimal() +
  scale_fill_viridis_c(option = "plasma", direction = -1, na.value = "grey90") +
  labs(title = "Mental Health Facility Density per 100,000 People (NSUMHSS 2023)",
       fill = "Facilities per 100k")

#PCA 
brfss_pca_data <- brfss_clean %>%
  select(STATE_FIPS, INCOME3, EDUCA, PRIMINS1, MENTHLTH, ADDEPEV3) %>%
  drop_na()

# STATE_FIPS
state_ids <- brfss_pca_data$STATE_FIPS

# Scale only the socioeconomic variables
brfss_pca_scaled <- scale(brfss_pca_data %>% select(INCOME3, EDUCA, PRIMINS1))

# PCA computation
pca_result <- prcomp(brfss_pca_scaled, center = TRUE, scale. = TRUE)
pca_scores <- as.data.frame(pca_result$x[, 1])
colnames(pca_scores) <- "pca_socioecon_index"

# Attach scores back
brfss_for_model <- brfss_pca_data %>%
  mutate(pca_socioecon_index = pca_scores$pca_socioecon_index)


# Summary stats by state
brfss_pca_summary <- brfss_for_model %>%
  group_by(STATE_FIPS) %>%
  summarise(
    avg_mental_days = mean(MENTHLTH, na.rm = TRUE),
    depression_rate = mean(ADDEPEV3 == 1, na.rm = TRUE),
    avg_pca_index = mean(pca_socioecon_index, na.rm = TRUE)
  )

# Join with FIPS lookup
brfss_pca_summary <- brfss_pca_summary %>%
  left_join(fips_lookup, by = c("STATE_FIPS" = "_STATE"))

# Merge with facility data
mental_health_combined <- left_join(brfss_pca_summary, facility_density, by = "state_abbr")

# Plot
ggplot(mental_health_combined, aes(x = avg_pca_index, y = facility_density_per_100k)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(
    title = "Socioeconomic Index (PCA) vs. Facility Density",
    x = "Avg PCA Socioeconomic Index",
    y = "Mental Health Facilities per 100k People"
  )

# Final regression
model_pca <- lm(avg_mental_days ~ facility_density_per_100k + avg_pca_index, data = mental_health_combined)
summary(model_pca)
