semanticPage(
  useShinyjs(),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
  ),
  # uiOutput("welcomeModal"),
  grid(
    grid_template = grid_template(
      default = list(
        areas = rbind(
          c("title", "map"),
          c("info", "map"),
          c("user", "map")
        ),
        cols_width = c("400px", "1fr"),
        rows_height = c("50px", "auto", "200px")
      ),
      mobile = list(
        areas = rbind(
          "title",
          "map",
          "info",
          "user"
        ),
        rows_height = c("70px", "400px", "auto", "200px"),
        cols_width = c("100%")
      )
    ),
    area_styles = list(title = "margin: 20px;", info = "margin: 20px;", user = "margin: 20px;"),
    
    title = h2(class = "ui header", icon("ship"), div(class = "content", "Marine App")),
    info = uiOutput("sidebar"),
    user = card(
      style = "border-radius: 0; width: 100%; background: #efefef",
      div(class = "content", 
          h4(class = "ui header", "Author"),
          div(class = "header", style = "margin-bottom: 10px", 
              tags$img(src = "https://cienciaenegocios.com/wp-content/uploads/wlademir_profile.jpeg", 
                       class = "ui avatar image"), 
    
              "Wlademir Prates", 
              span(style = "color: #0099f9; font-size: 13px;", 
                   HTML("<a target = '_blank' href = 'https://www.linkedin.com/in/wlademir-ribeiro-prates/'>"), icon("linkedin") ,HTML("</a>")))
      )
    ),
    map = leafletOutput("main_map")
  )
)
