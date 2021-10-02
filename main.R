####
# PACKAGES ----------------------------------------------------------------
####
# Root path for the Project
project_root_path <- getwd()

# General encoding
encoding <- "UTF-8"

# Inicializar biblioteca privada do projeto
initialize_project <- FALSE

# Verificar se o projeto já tem uma biblioteca privada ou criá-la
source(paste0(getwd(), "/environment/initialize_project.R"))

# Adicioanar ou atualizar a biblioteca privada do projeto além de carregar pacotes necessários
source(paste0(getwd(), "/environment/renv_init.R"))

