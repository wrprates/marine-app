##############################################
#########         PACKAGES             #######
##############################################

# This script in R checks if the packages needed to run the project's code
# are installed. Otherwise, install them. If the packages are already
# installed, the script just loads them.

#######
####   SETTINGS
#######

# Do not check difference between binary and source
options(install.packages.check.source = "no")


#######
####   PACKAGES
#######

message("Checking availability of default packages for the project...")

# List of packages (CRAN and GitHub)
.packages <-
  c(
    "shiny",
    "shiny.semantic",
    "modules",
    "config",
    "sass",
    "leaflet",
    "highcharter",
    "anytime",
    "dplyr",
    "readr",
    "shinyjs",
    "httr",
    "glue",
    "lubridate",
    "reactable",
    
    # For ShinyApps publishing
    "rstudioapi",
    "packrat", 
    "rsconnect",
    
    # Geo
    "geosphere"
  )

#.devpackages <- NULL

.devpackages <-
  c(

  )

#######
####   CHECK AND INSTALL
#######

# Check which of the required packages are already installed. To do this, use the function
# installed.packages() which returns a dataframe with the list of packages installed on the
# R running. As a result, we have a vector the same size as the packet vector.
# of interest with TRUE (package already installed) or FALSE (package not installed)
.inst <- .packages %in% installed.packages(lib.loc = private_library_dir)

# If the vector of packages not installed (difference between the packages of interest and the
# packages installed) has a size greater than 0, install only the packages not installed
if (length(.packages[!.inst]) > 0) {
  message("Installing packages you don't already have in your environment ...")
  install.packages(.packages[!.inst], lib = private_library_dir, dependencies = TRUE, type = "binary")
  #renv::install(packages = .packages[!.inst], library = private_library_dir, rebuild = TRUE)
  # pak::pkg_install(pkg = .packages[!.inst], lib = private_library_dir, ask = FALSE)
  message("Packages Installed....")
} else {
  message("Your environment already has the necessary packages ...")
}

# Check which of the repository packages are already installed.
if (!is.null(.devpackages)) {
  .spl.pkg <- strsplit(.devpackages, split = "/")
  .dev.pkg <- unlist(lapply(1:length(.devpackages), function(x) .spl.pkg[[x]][2]))
  .inst.dev.pkg <- .dev.pkg %in% installed.packages(lib.loc = private_library_dir)
  
  if (length(.devpackages[!.inst.dev.pkg]) > 0) {
    message("Installing packages from repositories you don't already have in your environment ...")
    remotes::install_github(repo = .devpackages[!.inst.dev.pkg], lib = private_library_dir, dependencies = TRUE)
    message("Packages Installed ...")
  } else {
    message("Your environment already has the repository packages installed ...")
  }
} 

#######
####   LOAD PACKAGES
#######

# After confirming that all packages are installed, we guarantee they are available.
# for use by loading them into R
.total_packages <- c(.packages, if(!is.null(.devpackages)).dev.pkg)

for (package in 1:length(.total_packages)) {
  suppressWarnings(suppressMessages(require(.total_packages[package], character.only = TRUE, lib.loc = private_library_dir)))
}

message("Packages loaded for the project....")
print(.total_packages)

######################################
######    PACKAGES OPTIONS      ######
######################################

# Adicionar a opção de paser de POSIX mais rápida
options(lubridate.fastime = TRUE)

##############################################
##   CREATE OBJECT WITH INSTALLED VERSIONS  ##
##############################################

all_pckgs_versions <-
  dplyr::tibble(pacote = base::loadedNamespaces()) %>%
  dplyr::rowwise() %>%
  dplyr::mutate(
    versao = utils::packageVersion(pacote),
    pct_data = utils::packageDate(pacote),
    pct_declarado = dplyr::if_else(pacote %in% .packages, 1, false = 0)
  ) %>% 
  dplyr::arrange(pct_data)

declared_pckgs_versions <- 
  all_pckgs_versions %>% 
  dplyr::filter(pct_declarado == 1) %>% 
  dplyr::select(-pct_declarado) 


