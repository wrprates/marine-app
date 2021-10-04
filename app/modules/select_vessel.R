# _ Select Vessel --------
mod_select_vessel_ui <- function(id) {
  ns <- NS(id)
  uiOutput('select2_out')
}

mod_select_vessel_server <-
  function(id) {
    moduleServer(id,
                 function(input, output, session) {
                   output$select2_out <- renderUI({
                     div(shiny.semantic::selectInput(ns("select2"), label = label, choices = ""))
                     
                     # selectInput(
                     #   inputId = session$ns('select2'),
                     #   label = 'Select Cat 2',
                     #   choices = ''
                     # )
                     
                   })
                   
                   observe({
                     req(input$ship_type)
                     ship <- 
                       df_clean %>% 
                       dplyr::filter(ship_type == input$ship_type) %>% 
                       dplyr::arrange(dplyr::desc(vessel_distance)) %>% 
                       dplyr::select(SHIPNAME) %>% 
                       dplyr::pull()
                     
                     # Can use character(0) to remove all choices
                     if (is.null(ship))
                       ship <- character(0)
                     
                     # Can also set the label and select items
                     
                     shiny.semantic::updateSelectInput(
                       session, "select2", label = "Vessel:",
                       
                       choices = ship,
                       # choices = vessels_filtered(),
                       selected = head(ship, 1)#,
                       # multiple = TRUE
                     )
                     
                     # updateSelectInput(session, "inSelect",
                     #                   label = paste("Select input label", length(x)),
                     #                   choices = x,
                     #                   selected = tail(x, 1)
                     # )
                   })
                  
                   # observeEvent(input$select1, {
                   #   df2 <- data %>%
                   #     filter(C1 == input$select1)
                   #   
                   #   updateSelectInput(
                   #     session,
                   #     inputId = 'select2',
                   #     label = 'Select Cat 2',
                   #     choices = unique(df2$C2)
                   #   )
                   #   
                   #   
                   # })
                  
                   return(reactive({ input$select2}))
                   
                 })
  }

  