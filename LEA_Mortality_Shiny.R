# =============================================================================
# GY638: Geographic Information in Practice
# Practical 4: Interactive Web Mapping with R Shiny
# =============================================================================
#
# OVERVIEW
# --------
# In this practical, you will create an interactive web map showing mortality
# rates across Ireland's 166 Local Electoral Areas (LEAs). You will:
#
#   1. Load and explore spatial health data
#   2. Create a basic interactive map using Leaflet
#   3. Add interactivity with popup information
#   4. Compare mortality patterns with socioeconomic variables
#   5. Build a complete Shiny web application
#
# The data includes:
#   - Mortality rates (total, COVID-19, cancer, circulatory, respiratory)
#   - Socioeconomic variables (age structure, education, unemployment, housing)
#
# =============================================================================


# =============================================================================
# SECTION 1: SETTING UP THE R ENVIRONMENT
# =============================================================================
#
# Before we can work with data, we need to load the packages (libraries) that
# provide the functions we will use. In R, packages are collections of code
# that extend R's capabilities.
#
# The main packages we'll use are:
#   - sf: For working with spatial (geographic) data
#   - leaflet: For creating interactive web maps
#   - shiny: For building web applications
#   - dplyr: For data manipulation
#   - RColorBrewer: For colour palettes
#
# Run the code below by placing your cursor on the line and pressing:
#   - Mac: Cmd + Enter
#   - Windows: Ctrl + Enter
# =============================================================================

# Load the required packages
# (These should already be installed in Posit Cloud)
library(shiny)      # For building web applications
library(leaflet)    # For interactive maps
library(sf)         # For spatial data
library(dplyr)      # For data manipulation
library(RColorBrewer) # For colour palettes


# =============================================================================
# SECTION 2: LOADING AND EXPLORING THE DATA
# =============================================================================
#
# Our data is stored in a GeoJSON file - a common format for geographic data
# that includes both the map boundaries (geometry) and associated data values.
#
# The file contains data for all 166 Local Electoral Areas in Ireland with:
#   - LEA_Name: Name of the Local Electoral Area
#   - County: County the LEA is located in
#   - Population: Total population (Census 2022)
#   - Total_Mortality_Rate: Deaths per 100,000 population (2021-2022)
#   - COVID_Rate: COVID-19 deaths per 100,000 population
#   - Cancer_Rate: Cancer deaths per 100,000 population
#   - Circulatory_Rate: Heart/circulatory disease deaths per 100,000
#   - Respiratory_Rate: Respiratory disease deaths per 100,000
#   - Pct_Over65: Percentage of population aged 65 and older
#   - Pct_ThirdLevel: Percentage with third-level education
#   - Unemployment_Rate: Percentage unemployed
#   - Pct_SolidFuel: Percentage of homes using solid fuel heating
#   - Pct_Renting: Percentage of households renting
# =============================================================================

# Read the GeoJSON file containing LEA boundaries and health data
# The st_read() function reads spatial data files
lea_data <- st_read("LEA_Health_Data.geojson")

# Let's explore the data
# The head() function shows the first few rows of data
head(lea_data)

# How many LEAs are in our dataset?
nrow(lea_data)

# What are all the column names in our data?
names(lea_data)

# Get a statistical summary of the mortality rate variable
summary(lea_data$Total_Mortality_Rate)


# =============================================================================
# SECTION 3: CREATING A BASIC INTERACTIVE MAP
# =============================================================================
#
# Leaflet is a JavaScript library for interactive maps. The leaflet package
# in R allows us to create Leaflet maps using R code.
#
# A basic Leaflet map has three components:
#   1. leaflet() - Creates an empty map object
#   2. addTiles() - Adds the base map (e.g., OpenStreetMap)
#   3. addPolygons() - Adds our LEA boundaries with data
#
# The pipe operator %>% is used to chain these steps together.
# Think of it as "then do this next".
# =============================================================================

# Create a simple map showing LEA boundaries
# Run this code to see your first interactive map!
leaflet(lea_data) %>%
  addTiles() %>%
  addPolygons()


# =============================================================================
# SECTION 4: ADDING COLOUR TO SHOW DATA VALUES
# =============================================================================
#
# To visualise mortality rates, we'll colour each LEA based on its value in a choropleth map.
#
# Steps:
#   1. Create a colour palette that maps data values to colours
#   2. Use fillColor to apply colours to each polygon
#   3. Add a legend to explain the colours
#
# We'll use the "YlOrRd" (Yellow-Orange-Red) palette where:
#   - Yellow = Lower mortality rates
#   - Red = Higher mortality rates
# =============================================================================

# Create a colour palette based on mortality rate values
# colorQuantile() divides the data into equal groups (quantiles)
mortality_palette <- colorQuantile(
  palette = "YlOrRd",      # Yellow to Red colour scheme
  domain = lea_data$Total_Mortality_Rate,  # The data values to map
  n = 5                    # Number of colour categories
)

# Create a choropleth map of total mortality rates
leaflet(lea_data) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~mortality_palette(Total_Mortality_Rate),  # Colour by mortality
    fillOpacity = 0.7,     # Transparency of fill (0 = invisible, 1 = solid)
    color = "white",       # Border colour
    weight = 1,            # Border thickness
    opacity = 1            # Border transparency
  ) %>%
  addLegend(
    position = "bottomright",
    pal = mortality_palette,
    values = ~Total_Mortality_Rate,
    title = "Total Mortality Rate<br>(per 100,000)",
    opacity = 0.7
  )


# =============================================================================
# SECTION 5: ADDING POPUP INFORMATION
# =============================================================================
#
# Interactive maps become more useful when users can click on areas to get
# more information. We can add popups that display when a user clicks on
# an LEA.
#
# We'll use HTML formatting to make the popup look nice:
#   - <b></b> makes text bold
#   - <br> creates a line break
# =============================================================================

# Create popup text for each LEA
# The paste0() function combines text and data values
popup_text <- paste0(
  "<b>", lea_data$LEA_Name, "</b><br>",
  "County: ", lea_data$County, "<br>",
  "Population: ", format(lea_data$Population, big.mark = ","), "<br>",
  "<br>",
  "<b>Mortality Rate: </b>", round(lea_data$Total_Mortality_Rate, 1), " per 100,000<br>",
  "% Over 65: ", round(lea_data$Pct_Over65, 1), "%<br>",
  "% Solid Fuel Heating: ", round(lea_data$Pct_SolidFuel, 1), "%"
)

# Create the map with popups
leaflet(lea_data) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~mortality_palette(Total_Mortality_Rate),
    fillOpacity = 0.7,
    color = "white",
    weight = 1,
    opacity = 1,
    popup = popup_text,    # Add the popup text
    highlightOptions = highlightOptions(  # Highlight on hover
      weight = 3,
      color = "#666",
      fillOpacity = 0.8
    )
  ) %>%
  addLegend(
    position = "bottomright",
    pal = mortality_palette,
    values = ~Total_Mortality_Rate,
    title = "Total Mortality Rate<br>(per 100,000)",
    opacity = 0.7
  )


# =============================================================================
# SECTION 6: COMPARING MORTALITY WITH OTHER VARIABLES
# =============================================================================
#
# Now let's explore whether mortality rates are related to specific factors
# that might influence health outcomes. We'll create maps of:
#   1. Age structure (% over 65) - older populations have higher mortality
#   2. Solid fuel heating (%) - a proxy for air pollution exposure
#
# Solid fuel (coal, peat, wood) burning is a major source of particulate
# matter air pollution in Ireland, which is associated with respiratory
# and cardiovascular disease.
# =============================================================================

# --- Map 1: Age Structure (% Population Over 65) ---

# Create a new colour palette for age data
age_palette <- colorQuantile(
  palette = "Blues",
  domain = lea_data$Pct_Over65,
  n = 5
)

# Create the age structure map
leaflet(lea_data) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~age_palette(Pct_Over65),
    fillOpacity = 0.7,
    color = "white",
    weight = 1,
    popup = paste0(
      "<b>", lea_data$LEA_Name, "</b><br>",
      "% Over 65: ", round(lea_data$Pct_Over65, 1), "%"
    ),
    highlightOptions = highlightOptions(weight = 3, color = "#666")
  ) %>%
  addLegend(
    position = "bottomright",
    pal = age_palette,
    values = ~Pct_Over65,
    title = "% Population<br>Over 65",
    opacity = 0.7
  )


# --- Map 2: Solid Fuel Heating ---

# Create a new colour palette for solid fuel data
fuel_palette <- colorQuantile(
  palette = "Oranges",
  domain = lea_data$Pct_SolidFuel,
  n = 5
)

# Create the solid fuel heating map
leaflet(lea_data) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~fuel_palette(Pct_SolidFuel),
    fillOpacity = 0.7,
    color = "white",
    weight = 1,
    popup = paste0(
      "<b>", lea_data$LEA_Name, "</b><br>",
      "% Using Solid Fuel: ", round(lea_data$Pct_SolidFuel, 1), "%"
    ),
    highlightOptions = highlightOptions(weight = 3, color = "#666")
  ) %>%
  addLegend(
    position = "bottomright",
    pal = fuel_palette,
    values = ~Pct_SolidFuel,
    title = "% Homes Using<br>Solid Fuel Heating",
    opacity = 0.7
  )


# =============================================================================
# SECTION 7: MAPPING A SPECIFIC CAUSE OF DEATH
# =============================================================================
#
# Respiratory diseases (like COPD, asthma, and pneumonia) are particularly
# linked to air pollution exposure. Let's map respiratory mortality rates.
#
# EXERCISE: After running this code, compare the spatial pattern of
# respiratory mortality to the solid fuel heating map. Do you see
# any similarities? What about to the age structure map?
# =============================================================================

# Create a colour palette for respiratory mortality
respiratory_palette <- colorQuantile(
  palette = "Purples",
  domain = lea_data$Respiratory_Rate,
  n = 5
)

# Create the respiratory mortality map
leaflet(lea_data) %>%
  addTiles() %>%
  addPolygons(
    fillColor = ~respiratory_palette(Respiratory_Rate),
    fillOpacity = 0.7,
    color = "white",
    weight = 1,
    popup = paste0(
      "<b>", lea_data$LEA_Name, "</b><br>",
      "County: ", lea_data$County, "<br>",
      "Respiratory Death Rate: ", round(lea_data$Respiratory_Rate, 1), " per 100,000<br>",
      "% Using Solid Fuel: ", round(lea_data$Pct_SolidFuel, 1), "%"
    ),
    highlightOptions = highlightOptions(weight = 3, color = "#666")
  ) %>%
  addLegend(
    position = "bottomright",
    pal = respiratory_palette,
    values = ~Respiratory_Rate,
    title = "Respiratory Mortality<br>(per 100,000)",
    opacity = 0.7
  )


# =============================================================================
# SECTION 8: BUILDING A SHINY WEB APPLICATION
# =============================================================================
#
# Now we'll combine everything into a Shiny application that allows users
# to select which variable to map.
#
# A Shiny app has two main components:
#   1. UI (User Interface) - What the user sees
#   2. Server - The code that runs in the background
#
# The UI creates a dropdown menu to select variables.
# The Server updates the map when the selection changes.
#
# To run the Shiny app, click the "Run App" button at the top of this script
# (or run the shinyApp() line at the bottom).
# =============================================================================

# Define the User Interface (UI)
ui <- fluidPage(

  # Application title
  titlePanel("Ireland LEA Mortality and Associated Indicators"),

  # Sidebar with a dropdown menu
  sidebarLayout(
    sidebarPanel(
      # Dropdown to select which variable to map
      selectInput(
        inputId = "variable",
        label = "Select Variable to Map:",
        choices = c(
          "Total Mortality Rate" = "Total_Mortality_Rate",
          "COVID-19 Mortality" = "COVID_Rate",
          "Cancer Mortality" = "Cancer_Rate",
          "Circulatory Mortality" = "Circulatory_Rate",
          "Respiratory Mortality" = "Respiratory_Rate",
          "% Population Over 65" = "Pct_Over65",
          "% Third Level Education" = "Pct_ThirdLevel",
          "Unemployment Rate" = "Unemployment_Rate",
          "% Solid Fuel Heating" = "Pct_SolidFuel",
          "% Renting" = "Pct_Renting"
        )
      ),

      # Information text
      helpText("Data sources: CSO Census 2022, CSO Vital Statistics"),
      helpText("Mortality rates are per 100,000 population (2021-2022)")
    ),

    # Main panel shows the map
    mainPanel(
      leafletOutput("map", height = 600)
    )
  )
)

# Define the Server logic
server <- function(input, output) {

  # Render the map
  output$map <- renderLeaflet({

    # Get the selected variable
    var <- input$variable
    var_data <- lea_data[[var]]

    # Create a colour palette for the selected variable
    pal <- colorQuantile(
      palette = "YlGnBu",
      domain = var_data,
      n = 5
    )

    # Create popup text
    popup <- paste0(
      "<b>", lea_data$LEA_Name, "</b><br>",
      "County: ", lea_data$County, "<br>",
      "Population: ", format(lea_data$Population, big.mark = ","), "<br>",
      "<br>",
      "<b>Value: </b>", round(var_data, 1)
    )

    # Create the map
    leaflet(lea_data) %>%
      addTiles() %>%
      addPolygons(
        fillColor = ~pal(var_data),
        fillOpacity = 0.7,
        color = "white",
        weight = 1,
        opacity = 1,
        popup = popup,
        highlightOptions = highlightOptions(
          weight = 3,
          color = "#666",
          fillOpacity = 0.8
        )
      ) %>%
      addLegend(
        position = "bottomright",
        pal = pal,
        values = var_data,
        title = names(which(c(
          "Total Mortality Rate" = "Total_Mortality_Rate",
          "COVID-19 Mortality" = "COVID_Rate",
          "Cancer Mortality" = "Cancer_Rate",
          "Circulatory Mortality" = "Circulatory_Rate",
          "Respiratory Mortality" = "Respiratory_Rate",
          "% Population Over 65" = "Pct_Over65",
          "% Third Level Education" = "Pct_ThirdLevel",
          "Unemployment Rate" = "Unemployment_Rate",
          "% Solid Fuel Heating" = "Pct_SolidFuel",
          "% Renting" = "Pct_Renting"
        ) == var)),
        opacity = 0.7
      )
  })
}

# Run the Shiny application
# To launch the app, click "Run App" button above or run this line:
shinyApp(ui = ui, server = server)


# =============================================================================
# EXERCISES FOR SUBMISSION
# =============================================================================
#
# After completing this practical, answer the following questions:
#
# 1. DESCRIPTIVE ANALYSIS
#    Using the summary statistics and map, describe the spatial pattern of
#    total mortality rates across Ireland. Which regions appear to have the
#    highest and lowest rates?
#
# 2. SOCIOECONOMIC COMPARISON
#    Compare the map of total mortality rates with the age structure map
#    (% over 65). Describe any similarities or differences you observe.
#    Why might these patterns exist?
#
# 3. ENVIRONMENTAL HEALTH
#    Compare the respiratory mortality map with the solid fuel heating map.
#    Do you observe any relationship? Why might solid fuel use be related
#    to respiratory disease mortality?
#
# 4. CRITICAL REFLECTION
#    What are some limitations of using solid fuel heating as a proxy for
#    air pollution exposure? What other data might provide a more accurate
#    measure of air quality?
#
# =============================================================================
