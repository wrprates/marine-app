server <- function(input, output, session) {
  
  dfs <- list()
  
  dfs$clean <- readr::read_rds("https://gitlab.com/wrprates/marine-app/-/raw/main/data/clean/df_ship_clean.RDS") 
   
  df_filtered <- dfs$clean %>% head(10)
    
  warsaw <- list(lon = 21.0122, lat = 52.2297)
  
  
  selected_point <- reactiveValues(id = NULL)

  # output$gaugePM25 <- renderHighchart({ gauge(pm25_perc) })
  # 
  # output$gaugePM10 <- renderHighchart({ gauge(pm10_perc) })
  
  # output$welcomeModal <- renderUI({
  #   create_modal(modal(
  #     id = "simple-modal",
  #     title = "Important message",
  #     header = h2(class = "ui header", icon("industry"), div(class = "content", "Polluter Alert")),
  #     content = grid(
  #       grid_template = grid_template(
  #         default = list(
  #           areas = rbind(c("photo", "text")),
  #           cols_width = c("50%", "50%")
  #         ),
  #         mobile = list(
  #           areas = rbind(c("photo"), c("text")),
  #           cols_width = c("100%"),
  #           rows_height = c("50%", "50%")
  #         )
  #       ),
  #       container_style = "grid-gap: 20px",
  #       area_styles = list(text = "padding-right: 20px"),
  #       photo = tags$img(src = "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Warszawski_smog_%2822798350941%29.jpg/800px-Warszawski_smog_%2822798350941%29.jpg", style = "width: 100%", alt = "Source: Radek Kołakowski from Warsaw, Poland, Creative Commons / https://commons.wikimedia.org/wiki/File:Warszawski_smog_(22798350941).jpg"),
  #       text = HTML(
  #         sprintf(
  #           intro,
  #           tags$a(href = "https://polskialarmsmogowy.pl/polski-alarm-smogowy/smog/szczegoly,skad-sie-bierze-smog,18.html", "heating stoves and boilers"),
  #           tags$a(href = "https://play.google.com/store/apps/details?id=pl.tajchert.canary&hl=en", "KanarekApp"),
  #           tags$a(href = "https://github.com/Appsilon/shiny.semantic", "shiny.semantic"),
  #           tags$a(href = "https://developer.airly.eu/", "Airly API")
  #         )
  #       )
  #     )
  #   ))
  # })
  
  # output$time <- renderText({
  #   paste("Measurements time:", anytime(airly_data$current$fromDateTime))
  #   #paste("Measurements time:", anytime("2020-09-12T09:56:50.962Z"))
  # })
  
  output$polluters_map <- renderLeaflet({
    points_n <- 100
    
    smokeIcon <- makeIcon(
      iconUrl = "images/smoke.gif",
      iconWidth = 60, iconHeight = 60,
      iconAnchorX = 22, iconAnchorY = 94
    )
    
    # random_points <- list(
    #   longitudes = warsaw$lon + rnorm(points_n, sd = 0.1),
    #   latitudes = warsaw$lat + rnorm(points_n, sd = 0.1)
    # )
    
    leaflet() %>% addTiles() %>%
      # addMapboxGL(style = "mapbox://styles/mapbox/streets-v9") %>%
      # setView(lng = warsaw$lon, lat = warsaw$lat, zoom = 12) %>%
      # addEasyButton(easyButton(
      #   icon="fa-globe", title="Zoom to Level 1",
      #   onClick=JS("function(btn, map){ map.setZoom(1); }"))) %>%
      # addEasyButton(easyButton(
      #   icon="fa-crosshairs", title="Locate Me",
      #   onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
      addCircleMarkers(
        # label = ~ "Start",
        lng =  df_filtered$LON_lag,
        lat = df_filtered$LAT_lag,
        fillColor = "green",
        fillOpacity = .5,
        stroke = F
      ) %>% 
      
      addCircleMarkers(
        # label = ~ "End",
        lng =  df_filtered$LON,
        lat = df_filtered$LAT,
        fillColor = "red",
        fillOpacity = .5,
        stroke = F
      ) %>% 
      
      addRectangles(
        lng1 = df_filtered$LON_lag,
        lat1 = df_filtered$LAT_lag,
        lng2 = df_filtered$LON,
        lat2 = df_filtered$LAT
      )
      
      # addMarkers(
      #   data = cbind(df_filtered$LON_lag, df_filtered$LAT_lag),
      #   # data = cbind(random_points$longitudes, random_points$latitudes),
      #   # layerId = 1:nrow(df_filtered), # marker unique ID numbers
      #   icon = smokeIcon
      # ) %>% 
      # addMarkers(
      #   data = cbind(df_filtered$LON, df_filtered$LAT)#,
      #   # data = cbind(random_points$longitudes, random_points$latitudes),
      #   # layerId = 1:nrow(df_filtered), # marker unique ID numbers
      #   # icon = smokeIcon
      # )
  })
  
  observe({
    click <- input$polluters_map_marker_click
    if (is.null(click)) return() # Unwanted event during map initialization
    selected_point$id <- click$id
    print(paste("Selected point", selected_point$id))
    
    circleIcon <- makeIcon(
      iconUrl = "images/red-loading-circle.gif",
      iconWidth = 30, iconHeight = 30,
      iconAnchorX = 7, iconAnchorY = 50
    )
    
    leafletProxy("polluters_map") %>% 
      removeMarker(layerId = "selected") %>%
      addMarkers(
        data = cbind(c(click$lng), c(click$lat)), 
        layerId = "selected",
        icon = circleIcon
      )
  })
  
  output$marine_stats <- renderUI({
    grid(
      grid_template = grid_template(default = list(
        areas = rbind(
          c("status", "status"),
          c("card1", "card2"),
          c("plot", "plot")
        ),
        cols_width = c("50%", "50%"),
        rows_height = c("80px", "160px", "auto")
      )),
      area_styles = list(card1 = "padding-right: 5px", card2 = "padding-left: 5px"),
      
      status = div(class = "content",
                   "Interesting message"
                   
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
  
  
  
  output$sidebar <- renderUI({
    uiOutput("marine_stats")
    })
  
  gauge <- function(value) {
    col_stops <- data.frame(
      q = c(0.15, 0.4, .8),
      c = c('#55BF3B', '#DDDF0D', '#DF5353'),
      stringsAsFactors = FALSE
    )
    
    highchart() %>%
      hc_chart(type = "solidgauge") %>%
      hc_pane(
        startAngle = -90,
        endAngle = 90,
        background = list(
          outerRadius = '100%',
          innerRadius = '60%',
          shape = "arc"
        )
      ) %>%
      hc_tooltip(enabled = FALSE) %>% 
      hc_yAxis(
        stops = list_parse2(col_stops),
        lineWidth = 0,
        minorTickWidth = 0,
        tickAmount = 2,
        min = 0,
        max = 100,
        labels = list(y = 26, style = list(fontSize = "12px")),
        showFirstLabel = FALSE,
        showLastLabel = FALSE
      ) %>%
      hc_add_series(
        data = value,
        dataLabels = list(
          y = -20,
          borderWidth = 0,
          useHTML = TRUE,
          style = list(fontSize = "15px"),
          formatter = JS(paste0("function () { return '", value, "%'; }"))
        )
      ) %>% 
      hc_size(height = 150)
  }
  
  
  # output$pollution <- renderHighchart({
  #   pollution_history %>% 
  #     hchart('areaspline', hcaes(x = 'time', y = 'measurement', group = "pollutant"))
  # })
  
  
  # camera_snapshot <- callModule(
  #   shinyviewr,
  #   'my_camera',
  #   output_width = 250,
  #   output_height = 250
  # )
  
  # output$snapshot <- renderPlot({
  #   req(camera_snapshot())
  #   plot(camera_snapshot(), main = 'Your photo')
  # }, height = 250)
  # 
  # output$shinyviewr <- renderUI({
  #   tagList(
  #     HTML("Bingo")
  #   )  
  # })
  
  output$selection_map <- renderLeaflet({
    leaflet::leaflet() %>% leaflet::addTiles() %>%
      # addMapboxGL(style = "mapbox://styles/mapbox/streets-v9") %>%
      leaflet::setView(lng = warsaw$lon, lat = warsaw$lat, zoom = 12)
  })
  
}
