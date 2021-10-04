# _ Select Vessel --------
select_vessel <- function(id, label = "Select Vessel") {
  ns <- NS(id)
  
  div(
    shiny.semantic::selectInput(ns("vessel"), label = label, choices = )
  )
  
  tagList(
    actionButton(ns("button"), label = label),
    verbatimTextOutput(ns("out"))
  )
}

counterServer <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      count <- reactiveVal(0)
      observeEvent(input$button, {
        count(count() + 1)
      })
      output$out <- renderText({
        count()
      })
      count
    }
  )
}