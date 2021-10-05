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
consts <- config::get(file = "constants.yml")

intro <- as.character(consts$intro)
random_comments <- consts$random_comments

# options(mapbox.accessToken = consts$mapbox_token)

# Reading data
df_clean <- 
  readr::read_rds("https://gitlab.com/wrprates/marine-app/-/raw/main/data/clean/df_ship_clean.RDS") %>% 
  dplyr::mutate(vessel_distance = base::round(vessel_distance, 0))

####
# Load Modules -------------------------------------------------------
####

base::source("modules/counter.R")
# base::source("modules/select_ship.R")
base::source("modules/select_vessel.R")

