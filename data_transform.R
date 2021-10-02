####
# Read Raw Data -----------------------------------------------------------
####

# List to receive data
dfs <- list()

dfs$raw <- readr::read_csv(file = base::paste0(project_root_path,"/data/raw/ships.csv"))

# Cleaning data
# dfs$clean <- 
dfs$raw %>% 
  dplyr::group_by(SHIP_ID) %>% 
  dplyr::arrange(DATETIME, .by_group = TRUE) %>% 
  # Find the observation when it sailed the longest distance between two consecutive observations
  dplyr::mutate(LAT_lag = dplyr::lag(LAT),
                LON_lag = dplyr::lag(LON)) %>% 
  dplyr::mutate(vessel_distance)
  # If there is a situation when a vessel moves exactly the same amount of meters, please select the most recent

  