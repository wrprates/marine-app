# _ Select Ship --------
selectShip <- function(id, label = "Select Ship", choices) {
  ns <- NS(id)
  
  div(
    shiny.semantic::selectInput(
      inputId = ns("ship_type"),
      label = label,
      choices = choices,
      multiple = FALSE
    )
  )
  
}

selectShipServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      
      # input$ship_type
      # 
      
      # df_filtered <- reactive(
      #   df_clean %>% dplyr::filter(ship_type == input$ship_type) 
      # )
      
      
    }
  )
}