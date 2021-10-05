####
# Loading Packages --------------------------------------------------------
####
library(shiny)
library(shiny.semantic)
library(modules)
library(config)
library(sass)
library(leaflet)
library(highcharter)
library(anytime)
library(dplyr)
library(shinyjs)
library(httr)
library(glue)
library(lubridate)
library(reactable)

####
# General Setup --------------------------------------------------------
####

# Reading data
df_clean <- 
  readr::read_rds("https://gitlab.com/wrprates/marine-app/-/raw/main/data/clean/df_ship_clean.RDS") %>% 
  dplyr::mutate(vessel_distance = base::round(vessel_distance, 0)) %>% 
  # Delete rows without destination
  dplyr::filter(!is.na(DESTINATION) & !is.na(PORT)) #%>% 

####
# Load Modules -------------------------------------------------------
####

base::source("modules/select_vessel.R")

