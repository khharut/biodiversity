library("shiny")
library("leaflet")
library("dplyr")


ui <- fluidPage(
  tags$head(tags$link(rel = "stylesheet", type = "text/css",
                      href = "sass.min.css")),
  sidebarPanel(
    uiOutput("species_sc_selection"),
    uiOutput("species_hm_selection")
  ),
  titlePanel("Biodiversity of Poland"),
  leafletOutput("map"),
  tableOutput("table_species")
)

server <- function(input, output, session) {
  biodiversity_data <- read.csv("poland_biodiversity.csv",
                                sep = ",", header = TRUE)
  variable_names <- c("longitudeDecimal", "latitudeDecimal",
                      "vernacularName", "scientificName", "time")
  biodiversity_data$time <- paste(biodiversity_data$eventDate,
                                  biodiversity_data$eventTime, sep = " ")
  biodiversity_data$time <- as.POSIXct(biodiversity_data$time,
                                       format = "%Y-%m-%d %H:%M")
  species_sc <- unique(biodiversity_data$scientificName)
  species_hm <- unique(biodiversity_data$vernacularName)

  get_species_data <- function(species, common=TRUE) {
    if (common) {
      species_loc <- which(biodiversity_data$vernacularName == species)
    } else {
      species_loc <- which(biodiversity_data$scientificName == species)
    }
    if (length(species_loc) > 0) {
      species_data <- biodiversity_data[species_loc, ]
      species_data <- species_data[variable_names]
      species_data <- species_data[
                                   order(species_data$time,
                                         decreasing = FALSE), ]
      species_data$time <- as.character(species_data$time)
    } else {
      species_data <- data.frame(matrix(ncol = length(variable_names),
                                        nrow = 0))
      colnames(species_data) <- variable_names
    }
    return(species_data)
  }

  get_random_sample <- function(n = -1) {
    random_sample <- biodiversity_data
    random_sample <- random_sample[sample(nrow(random_sample)), ]
    random_sample <- (random_sample %>%
                        distinct(scientificName, .keep_all = TRUE))
    random_sample <- random_sample[variable_names]
    if (n > 0) {
      random_sample <- random_sample[1:n, ]
    }
    random_sample$time <- as.character(random_sample$time)
    return(random_sample)
  }

  observeEvent(input$sc_name, {
    dataset_sc <- get_species_data(input$sc_name, common = FALSE)
    output$map <- renderLeaflet({
      leaflet(data = dataset_sc) %>%
        addTiles() %>%
        addMarkers(~longitudeDecimal, ~latitudeDecimal, popup = ~vernacularName)
    })
    output$table_species <- renderTable({
      dataset_sc
    })
  })

  observeEvent(input$hm_name, {
    dataset_hm <- get_species_data(input$hm_name, common = TRUE)
    output$map <- renderLeaflet({
      leaflet(data = dataset_hm) %>%
        addTiles() %>%
        addMarkers(~longitudeDecimal, ~latitudeDecimal, popup = ~vernacularName)
    })
    output$table_species <- renderTable({
      dataset_hm
    })
  })

  dataset <- get_random_sample()

  output$species_sc_selection <- (
    renderUI(selectInput("sc_name",
                         "Choose a species by scientific name",
                         choices = species_sc,
                         selected = species_sc[1]))
  )

  output$species_hm_selection <- (
    renderUI(selectInput("hm_name",
                         "Choose a species by common name",
                         choices = species_hm,
                         selected = NULL))
  )

  output$map <- renderLeaflet({
    leaflet(data = dataset) %>%
      addTiles() %>%
      addMarkers(~longitudeDecimal, ~latitudeDecimal, popup = ~vernacularName)
  })

  output$table_species <- renderTable({
    dataset
  })
}

shinyApp(ui, server)
