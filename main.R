####
# PACKAGES ----------------------------------------------------------------
####
# Root path for the Project
project_root_path <- getwd()

# General encoding
encoding <- "UTF-8"

# Initialize Project Private Library
initialize_project <- FALSE

# Check if the project already has a private library or create one
source(paste0(project_root_path, "/environment/initialize_project.R"))

# Add or update the project's private library in addition to uploading required packages
source(paste0(project_root_path, "/environment/renv_init.R"))

# Loading local functions
source(paste0(project_root_path, "/sources/functions.R"))
