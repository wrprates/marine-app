####
# Read Raw Data -----------------------------------------------------------
####

# List to receive data
dfs <- list()

dfs$raw <- readr::read_csv(file = base::paste0(project_root_path,"/data/raw/ships.csv"))

# Cleaning data
dfs$clean <-
# st = Sys.time()
  dfs$raw %>% 
  dplyr::mutate(SHIP_ID = base::as.character(SHIP_ID)) %>% 
  # head(10000) %>% 
  dplyr::group_by(SHIP_ID) %>% 
  dplyr::arrange(DATETIME, .by_group = TRUE) %>% 
  dplyr::mutate(LAT_lag = dplyr::lag(LAT),
                LON_lag = dplyr::lag(LON)) %>% 
  
  # First Distance Calculation - SLOW
  # dplyr::rowwise() %>%
  # dplyr::mutate(vessel_distance = geosphere::distm(x = c(LON, LAT), y = c(LON_lag, LAT_lag), fun=distHaversine)) #%>%
  
  # Second Distance Calculation - FAST, same result.
  dplyr::mutate(vessel_distance = earth.dist(LON, LAT, LON_lag, LAT_lag)*1000) %>% # Same result of distm, but much faster.
  
  # Find the observation when it sailed the longest distance between two consecutive observations
  dplyr::slice_max(vessel_distance) %>% 
  dplyr::ungroup() %>% 
  dplyr::group_by(SHIP_ID, vessel_distance) %>% 
  
  # If there is a situation when a vessel moves exactly the same amount of meters, please select the most recent
  dplyr::slice_max(DATETIME) %>% 
  dplyr::ungroup() 

# end = Sys.time()
# end-st
  
# Write clean CSV
# readr::write_csv(dfs$clean, file = base::paste0(project_root_path,"/data/clean/df_ship_clean.csv") )
readr::write_rds(dfs$clean, file = base::paste0(project_root_path,"/data/clean/df_ship_clean.RDS"))

  
  