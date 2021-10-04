server <- function(input, output, session) {
  

df_clean <- 
  readr::read_rds("https://gitlab.com/wrprates/marine-app/-/raw/main/data/clean/df_ship_clean.RDS") %>% 
  dplyr::mutate(vessel_distance = base::round(vessel_distance, 2))
 

df_filtered <- reactive(
  df_clean %>% dplyr::filter(ship_type == input$ship_type) %>% 
    dplyr::filter(SHIPNAME %in% input$vessel)
)



# observe({
#   shiny.semantic::updateSelectInput(session, "vessel", choices = df_filtered()$SHIPNAME)
# })

# values <- reactiveValues()
# 
# observe(
#   # values$ship_type = base::unique(df_clean$ship_type)
#   values$vessels = base::unique(df_filtered()$SHIPNAME)
# )




####
# SIDEBAR -----------------------------------------------------------------
####
  output$sidebar <- renderUI({
    grid(
      grid_template = grid_template(default = list(
        areas = rbind(
          c("status", "status"),
          c("card1", "card2"),
          c("plot", "plot")
        ),
        cols_width = c("50%", "50%"),
        rows_height = c("280px", "160px", "auto")
      )),
      area_styles = list(card1 = "padding-right: 5px", card2 = "padding-left: 5px"),
      
      status =
        div(
          class = "content",
          
          # div(selectShip("ship_type", "Ship Type:", base::unique(df_clean$ship_type))),
          
          div(
            shiny.semantic::selectInput(
              inputId = "ship_type",
              label = "Ship Type:",
              base::unique(df_clean$ship_type),
              multiple = FALSE
            )
          ),
          
          # div(uiOutput("vessel")),
          
          div(
            shiny.semantic::selectInput(
              inputId = "vessel",
              label = "Vessel:",
              choices = c("AGATH", "LOOKMAN", "LINDA", "BURO"),#df_filtered()$SHIPNAME,
              # choices = vessels_filtered(),
              selected = c("AGATH", "LOOKMAN", "LINDA", "BURO"),
              multiple = TRUE
            )
          ),

          div(
            counterButton("counter1", "Contador #1")
          )
          
        ),
      
      
      card1 = card(
        style = "border-radius: 0; width: 100%; height: 150px; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "Card 1")
        )
      ),
      
      card2 = card(
        style = "border-radius: 0; width: 100%; height: 150px; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "Card 2")
        )
      ),
      
      plot = card(
        style = "border-radius: 0; width: 100%; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "Chart Title"),
            div(class = "meta", "Chart Subtitle"),
            div(class = "description", style = "margin-top: 10px", 
                # highchartOutput("pollution", height = "200px")
            )
        )
      )
    )
  })
  

observe({
  req(input$ship_type)
  x <- df_clean %>% dplyr::filter(ship_type == input$ship_type) %>% dplyr::select(SHIPNAME) %>% dplyr::pull()
  
  # Can use character(0) to remove all choices
  if (is.null(x))
    x <- character(0)
  
  # Can also set the label and select items
  
  shiny.semantic::updateSelectInput(
    session, "vessel", label = "Vessel:",
    
          choices = x,
          # choices = vessels_filtered(),
          selected = tail(x, 1)#,
          # multiple = TRUE
        )
  
  # updateSelectInput(session, "inSelect",
  #                   label = paste("Select input label", length(x)),
  #                   choices = x,
  #                   selected = tail(x, 1)
  # )
})



# output$vessel <- renderUI({
#   
#   vessel_selected <- 
#       df_filtered() 
#   
#     
#   
#   div(
#     shiny.semantic::selectInput(
#       inputId = "vessel",
#       label = "Vessel:",
#       choices = vessel_selected,
#       # choices = vessels_filtered(),
#       selected = df_clean$SHIPNAME,
#       multiple = TRUE
#     )
#   )
# })
#   

####
# DASHBOARD BODY ----------------------------------------------------------
####
  output$dash_body <- shiny::renderUI({
    
    vessels_filtered <- eventReactive(input$ship_type, {
      req(input$ship_type)
      df_filtered %>% dplyr::select(SHIPNAME) %>% dplyr::pull()
      
    })
    
    
    # Creating Leaflet Map
    output$main_map <- leaflet::renderLeaflet({
      # df <- dfs$clean %>% head(1) #dplyr::filter(SHIPNAME == req(input$vessel))
      # df <- df_filtered() 
      # df_filtered <- function(){dfs$clean %>% head(5)}
      
      df_poly <- 
        df_filtered() %>% 
        dplyr::select(LAT_lag, LON_lag, everything(), -c("LAT", "LON")) %>% 
        dplyr::rename("LAT" = "LAT_lag", "LON" = "LON_lag") %>% 
        dplyr::mutate(group = "Start") %>% 
        dplyr::bind_rows(
          df_filtered() %>% 
            dplyr::select(LAT, LON, everything(), -c("LAT_lag", "LON_lag")) %>% 
            dplyr::mutate(group = "End")
        ) %>% 
        dplyr::arrange(SHIPNAME)
      
      
      # smokeIcon <- makeIcon(
      #   iconUrl = "images/smoke.gif",
      #   iconWidth = 60, iconHeight = 60,
      #   iconAnchorX = 22, iconAnchorY = 94
      # )
      
      ships_map <-
        leaflet::leaflet() %>% leaflet::addTiles() %>%
        # setView(lng = warsaw$lon, lat = warsaw$lat, zoom = 12) %>%
        leaflet::addCircleMarkers(
          data = df_filtered(),
          # label = ~ "Start",
          lng =  ~LON_lag,
          lat = ~LAT_lag,
          fillColor = "green",
          fillOpacity = .5,
          stroke = F
        ) %>% 
        
        leaflet::addCircleMarkers(
          data = df_filtered(),
          # label = ~ "End",
          lng =  ~LON,
          lat = ~LAT,
          fillColor = "red",
          fillOpacity = .5,
          stroke = F
        ) #%>%
      # addPolylines(data = df_poly, lng = ~LON, lat = ~LAT, group = ~group)
      
      for(i in 1:nrow(df_filtered())){
        ships_map <- addPolylines(ships_map, lat = as.numeric(df_filtered()[i, c("LAT_lag", "LAT")]),
                                  lng = as.numeric(df_filtered()[i, c("LON_lag", "LON")]))
      }
      
      ships_map
      
    })
    
    
    output$tab_ships <-
      reactable::renderReactable({
        reactable::reactable(
          df_filtered() %>% 
            dplyr::select(-c("COURSE", "HEADING", "SHIPTYPE", "DWT", "date", "PORT", "LAT_lag", "LON_lag", "LAT", "LON")),
          defaultPageSize = 5,
          resizable = TRUE
          # width = 960
        ) 
      })
    
    # Building UI
      div(
        leaflet::leafletOutput("main_map"),
        htmltools::HTML("Below, the data table:"),
        reactable::reactableOutput("tab_ships")
      )
    
  })
  
  

  
  # observe({
  #   click <- input$polluters_map_marker_click
  #   if (is.null(click)) return() # Unwanted event during map initialization
  #   selected_point$id <- click$id
  #   print(paste("Selected point", selected_point$id))
  #   
  #   circleIcon <- makeIcon(
  #     iconUrl = "images/red-loading-circle.gif",
  #     iconWidth = 30, iconHeight = 30,
  #     iconAnchorX = 7, iconAnchorY = 50
  #   )
  #   
  #   leafletProxy("polluters_map") %>% 
  #     removeMarker(layerId = "selected") %>%
  #     addMarkers(
  #       data = cbind(c(click$lng), c(click$lat)), 
  #       layerId = "selected",
  #       icon = circleIcon
  #     )
  # })
  # 
  

  counterServer("counter1")
  
  # selectShipServer("ship_type")
  
  

  # output$selection_map <- renderLeaflet({
  #   leaflet::leaflet() %>% leaflet::addTiles()# %>%
  #     # addMapboxGL(style = "mapbox://styles/mapbox/streets-v9") %>%
  #     # leaflet::setView(lng = warsaw$lon, lat = warsaw$lat, zoom = 12)
  # })
  
}
