# LEA Mortality Shiny App

Interactive web mapping of mortality rates across Ireland's 166 Local Electoral Areas (LEAs).

## Files for Student Use

- `LEA_Mortality_Shiny.R` - R code for creating interactive maps and a Shiny web application
- `LEA_Health_Data.geojson` - Spatial data containing LEA boundaries and health/socioeconomic indicators

## Getting Started

### Option 1: Posit Cloud (Recommended for Class)

1. Go to [Posit Cloud](https://posit.cloud) and sign up for a free account
2. Click "New Project" > "New Project from Git Repository"
3. Enter this repository URL
4. Open `LEA_Mortality_Shiny.R` and click "Install" when prompted to install required packages
5. Run the code section by section (Cmd+Enter on Mac, Ctrl+Enter on Windows)

### Option 2: Local R Studio

1. Clone or download this repository
2. Open `LEA_Mortality_Shiny.R` in R Studio
3. Install required packages: `install.packages(c("shiny", "leaflet", "sf", "dplyr", "RColorBrewer"))`
4. Run the code

## Data Description

| Variable | Description |
|----------|-------------|
| LEA_Name | Name of the Local Electoral Area |
| County | County the LEA is located in |
| Population | Total population (Census 2022) |
| Total_Mortality_Rate | All-cause deaths per 100,000 population (2021-2022) |
| COVID_Rate | COVID-19 deaths per 100,000 population |
| Cancer_Rate | Cancer deaths per 100,000 population |
| Circulatory_Rate | Heart/circulatory disease deaths per 100,000 |
| Respiratory_Rate | Respiratory disease deaths per 100,000 |
| Pct_Over65 | Percentage of population aged 65 and older |
| Pct_ThirdLevel | Percentage with third-level education |
| Unemployment_Rate | Percentage unemployed |
| Pct_SolidFuel | Percentage of homes using solid fuel heating |
| Pct_Renting | Percentage of households renting |

## Data Sources

- **Mortality Data**: CSO Vital Statistics 2021-2022
- **Population & Socioeconomic Data**: CSO Census 2022 Small Area Population Statistics (SAPS)
- **Spatial Boundaries**: CSO Local Electoral Areas 2022

## Module

GY638: Geographical Information Systems in Practice

## License

Educational use only. Data sourced from the Central Statistics Office Ireland.
