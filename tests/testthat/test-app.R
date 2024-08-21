library("testthat")

test_that("Check sepcies dataframe structure",
          {
            biodiversity_data <- read.csv("../../poland_biodiversity.csv",
                                          sep = ",", header = TRUE)
            variable_names <- c("longitudeDecimal", "latitudeDecimal",
                                "vernacularName", "scientificName", "time")
            biodiversity_data$time <- paste(biodiversity_data$eventDate,
                                            biodiversity_data$eventTime, sep = " ")
            biodiversity_data$time <- as.POSIXct(biodiversity_data$time,
                                                 format = "%Y-%m-%d %H:%M")
            test_df <- get_species_data("Burbot", common=TRUE)
            expect_equal(colnames(test_df), variable_names)
          })