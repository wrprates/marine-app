# # _ Select Vessel --------
# mod_select_vessel_ui <- function(id) {
# 
#     # selectInput(NS(id, "var"), "Variable", choices = names(mtcars))
#     
#     selectizeInput(
#       inputId = NS(id, "vessel"),
#       label = "Vessel:",
#       choices = df_clean$SHIPNAME,
#       multiple = TRUE,
#       options = list(maxItems = 20 ),
#       width = "100%"
#     )
#     
#     
# }
# 
# mod_select_vessel_server <-
#   function(id) {
#     moduleServer(id,
#                  function(input, output, session) {
#   
#                    observe({
#                      req(input$ship_type)
#                      ship <-
#                        reactive(
#                          df_clean %>%
#                            dplyr::filter(ship_type == input$ship_type) %>%
#                            dplyr::arrange(dplyr::desc(vessel_distance)) %>%
#                            dplyr::select(SHIPNAME) %>%
#                            dplyr::pull()
#                        )
#                        
#                      
#                      # Can use character(0) to remove all choices
#                      if (is.null(ship()))
#                        ship <- function(){character(0)}
#                      
#                      # Can also set the label and select items
#                      updateSelectizeInput(
#                        session, "vessel",
#                        label = "Vessel:",
#                        choices = ship(),
#                        selected = head(ship(), 1)
#                      )
#                      
#                    })
#                    
#                  })
#   }

  