##############################################
#########         PACOTES              #######
##############################################

# Este script em R verifica se os pacotes necessários para executar os códigos do projeto
# estão instalados. Caso contrário, faz a instalação dos mesmos. Se os pacotes já estão 
# instalados, o script apenas carrega-os. 

#######
####   OPÇÃO PARA A INSTALAÇÃO
#######

# Não verificar diferenças entre as versões do binário e source dos pacotes
options(install.packages.check.source = "no")


#######
####   PACOTES
#######

message("Verificando disponibilidade dos pacotes default para o projeto...")

# Lista de pacotes necessários (do CRAN e do GitHub)
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
    
    # For ShinyApps publishing
    "rstudioapi",
    "packrat", 
    "rsconnect"
  )

#.devpackages <- NULL

.devpackages <-
  c(

  )

#######
####   VERIFICAR E INSTALAR
#######

# Verificar quais dos pacotes necessários já estão instalados. Para isso, usa a função
# installed.packages() que retorna um dataframe com a lista dos pacotes instaldos no
# R em execução. Como resultado, temos um vetor do mesmo tamanho do vetor de pacotes
# de interesse com TRUE (pacote já instalado) ou FALSE (pacote não instalado)
.inst <- .packages %in% installed.packages(lib.loc = private_library_dir)

# Se o vetor de pacotes não instalados (diferença entre os pacotes de interesse e os
# pacotes instalados) tiver tamanho maior que 0, instalar apenas os pacotes não instalados
if (length(.packages[!.inst]) > 0) {
  message("Instalando pacotes que você ainda não tem no seu ambiente....")
  install.packages(.packages[!.inst], lib = private_library_dir, dependencies = TRUE, type = "binary")
  #renv::install(packages = .packages[!.inst], library = private_library_dir, rebuild = TRUE)
  # pak::pkg_install(pkg = .packages[!.inst], lib = private_library_dir, ask = FALSE)
  message("Pacotes instalados....")
} else {
  message("Seu ambiente já tem os pacotes necessários....")
}

# Verificar quais dos pacotes de repositórios já estão instalados. 
if (!is.null(.devpackages)) {
  # split da string do github para pesquisar se o pacote já está instalado
  .spl.pkg <- strsplit(.devpackages, split = "/")
  .dev.pkg <- unlist(lapply(1:length(.devpackages), function(x) .spl.pkg[[x]][2]))
  .inst.dev.pkg <- .dev.pkg %in% installed.packages(lib.loc = private_library_dir)
  
  if (length(.devpackages[!.inst.dev.pkg]) > 0) {
    message("Instalando pacotes de repositórios que você ainda não tem no seu ambiente ...")
    remotes::install_github(repo = .devpackages[!.inst.dev.pkg], lib = private_library_dir, dependencies = TRUE)
    message("Pacotes de repositórios instalados ...")
  } else {
    message("Seu ambiente já tem os pacotes de repositórios instalados ...")
  }
} 

#######
####   CARREGAR PACOTES NO AMBIENTE 
#######


# Após confirmar que todos os pacotes estão instaldos, garantimos que eles estão disponíveis
# para uso fazendo a carga dos mesmos no R 
.total_packages <- c(.packages, if(!is.null(.devpackages)).dev.pkg)

for (package in 1:length(.total_packages)) {
  suppressWarnings(suppressMessages(require(.total_packages[package], character.only = TRUE, lib.loc = private_library_dir)))
}

# message("Pacotes carregados para o projeto....")
print(.total_packages)

########################################
######    OPÇÕES DE PACOTES       ######
########################################

# Adicionar a opção de paser de POSIX mais rápida
options(lubridate.fastime = TRUE)

#############################################
##   CRIAR OBJETO COM VERSÕES INSTALADAS   ##
#############################################

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


