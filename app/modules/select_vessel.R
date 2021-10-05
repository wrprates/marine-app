# _ Select Vessel --------
mod_select_vessel_ui <- function(id) {
  ns <- NS(id)
  return(
    uiOutput(NS(id, "vessel_selected"))
  )
  }

mod_select_vessel_server <-
  function(id) {
    moduleServer(id,
                 function(input, output, session) {

                   ns <- session$ns
                   
                   output$vessel_selected <- 
                     renderUI({
                       
                       # UI Objects
                       return(
                         selectizeInput(
                           inputId = "vessel",
                           label = "Vessel:",
                           choices = df_clean$SHIPNAME,
                           multiple = TRUE,
                           options = list(maxItems = 20 ),
                           width = "100%"
                         )
                       )
                       })
                 })
    }

