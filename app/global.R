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

####
# General Setup --------------------------------------------------------
####
consts <- config::get(file = "constants.yml")

intro <- as.character(consts$intro)
random_comments <- consts$random_comments

# options(mapbox.accessToken = consts$mapbox_token)


