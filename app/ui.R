semanticPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
  ),
  shiny.semantic::grid(
    grid_template = shiny.semantic::grid_template(
      default = list(
        areas = rbind(
          c("title", "map"),
          c("info", "map"),
          c("user", "map")
        ),
        cols_width = c("400px", "1fr"),
        rows_height = c("50px", "auto", "auto")
      ),
      mobile = list(
        areas = rbind(
          "title",
          "map",
          "info",
          "user"
        ),
        rows_height = c("auto", "auto", "auto", "auto"),
        cols_width = c("100%")
      )
    ),
    area_styles = list(title = "margin: 20px;", map = "margin: 0px;", info = "margin: 20px;", user = "margin: 20px;"),
    
    title = h2(class = "ui header", icon("ship"), div(class = "content", "Marine App")),
    info = 
      div(
        uiOutput("sidebar")
      ),
    user = card(
      style = "border-radius: 0; width: 100%; background: #efefef",
      div(class = "content", 
          h4(class = "ui header", "Author"),
          div(class = "header", style = "margin-bottom: 10px", 
              tags$img(src = "https://cienciaenegocios.com/wp-content/uploads/wlademir_profile.jpeg", 
                       class = "ui avatar image"), 
    
              "Wlademir Prates", 
              htmltools::HTML("<a target = '_blank' href = 'https://www.linkedin.com/in/wlademir-ribeiro-prates/'>"), icon("linkedin") , htmltools::HTML("</a>"))
              
      )
    ),
    map = shiny::uiOutput("dash_body") 
  )
)
