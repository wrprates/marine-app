server <- function(input, output, session) {
  
####
# Reactive Data -----------------------------------------------------------------
####
df_filtered <- reactive(
  df_clean %>% 
    dplyr::filter(ship_type == input$ship_type) %>% 
    dplyr::filter(SHIPNAME %in% input$vessel)
)

# Data for chart. 
df_chart_dist <- eventReactive(input$vessel, {
  df_filtered() %>%
    dplyr::arrange(dplyr::desc(vessel_distance))
})



####
# SIDEBAR -----------------------------------------------------------------
####
  output$sidebar <- renderUI({
    
    grid(
      grid_template = grid_template(default = list(
        areas = rbind(
          c("status", "status"),
          c("plot", "plot")
        ),
        cols_width = c("50%", "50%"),
        rows_height = c("auto", "auto")
      )),
   
      status =
        div(
          class = "content",
          
          div(
            shiny.semantic::selectInput(
              inputId = "ship_type",
              label = "Ship Type:",
              base::unique(df_clean$ship_type),
              multiple = FALSE
            )
          ),

          ## CALL UI Modules
          div(mod_select_vessel_ui("select_vessels"))
          
        ),
      
      plot = card(
      
        style = "border-radius: 0; width: 100%; background: #efefef",
        div(class = "content",
            div(class = "header", style = "margin-bottom: 10px", "Longest Distance for Ship Type"),
            div(class = "meta", "Between two consecutive observations, in meters."),
            div(class = "description", style = "margin-top: 10px",
                highcharter::highchartOutput("chart_column_distance", height = 270)
            )
        )
      )

    )
  })
  

####
# DASHBOARD BODY ----------------------------------------------------------
####
  output$dash_body <- shiny::renderUI({

    # Creating Leaflet Map
    output$main_map <- leaflet::renderLeaflet({
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

      # Map
      ships_map <-
        leaflet::leaflet() %>% 
        leaflet::addTiles() %>%
        # Green: Start
        leaflet::addCircleMarkers(
          data = df_filtered(),
          # label = ~ "Start",
          lng =  ~LON_lag,
          lat = ~LAT_lag,
          fillColor = "green",
          fillOpacity = .5,
          stroke = T,
          popup = paste0(
            "<b><i>START</i> - ", df_filtered()$SHIPNAME, "</b>", "<br/>",
            "<b>Port: ", df_filtered()$port, "</b>", "<br/>",
            "<b>Distance:</b> ", prettyNum(df_filtered()$vessel_distance, big.mark = ","), " meters" 
          )
        ) %>% 
        
        # Red: End
        leaflet::addCircleMarkers(
          data = df_filtered(),
          lng =  ~LON,
          lat = ~LAT,
          fillColor = "red",
          fillOpacity = .85,
          stroke = T,
          popup = paste0(
            "<b><i>END</i> - ", df_filtered()$SHIPNAME, "</b>", "<br/>",
            "<b>Destination: ", df_filtered()$DESTINATION, "</b>", "<br/>",
            "<b>Distance:</b> ", prettyNum(df_filtered()$vessel_distance, big.mark = ","), " meters" 
          )
        )
      
      # Add lines between points
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
            dplyr::select("Ship Name" = "SHIPNAME",
                          "Country" = "FLAG",
                          "Ship Type" = "ship_type",
                          "Port" = "port",
                          "Dest." = "DESTINATION",
                          "Dt. Time" = "DATETIME",
                          "Vessel Distance (meters)" = "vessel_distance"
                          ) %>%
            dplyr::mutate(Country = paste(Country, base::sprintf("<img src = 'http://flagpedia.net/data/flags/mini/%s.png'>", 
                                               base::tolower(.$Country)))),
          defaultPageSize = 5,
          resizable = TRUE,
          columns = list(
            Country = colDef(html = TRUE)
          )
        ) 
      })
    
    # Building UI
      div(
        leaflet::leafletOutput("main_map"),
        card(
          style = "border-radius: 15; width: 100%; padding: 15px; background: #fff;",
          div(
            reactable::reactableOutput("tab_ships")
          )
        )
      )
  })
  
####
# Other Outputs -----------------------------------------------------------------
####
  output$chart_column_distance <- highcharter::renderHighchart({
    
    df_chart_dist() %>% 
      highcharter::hchart(name = "Distance",
                          hcaes(x = "SHIPNAME", y = "vessel_distance"),
                          type = "column") %>%
      highcharter::hc_colors("#1f2937") %>% 
      highcharter::hc_yAxis(title = list(text = ""))
    
  })
  
####
# Server Modules and Updates -----------------------------------------------------------------
####
  # Load Module
  mod_select_vessel_server("select_vessels")
  
  # Update Input to chose Vessel
  observe({
    req(input$ship_type)
    
    ship <- reactive(
      df_clean %>%
        dplyr::filter(ship_type == input$ship_type) %>%
        dplyr::arrange(dplyr::desc(vessel_distance)) %>%
        dplyr::select(SHIPNAME) %>%
        dplyr::pull()
    )
    
    # Can use character(0) to remove all choices
    if (is.null(ship()))
      ship <- function(){character(0)}
    
    # Can also set the label and select items
    updateSelectizeInput(
      session, "vessel",
      label = "Vessel:",
      choices = ship(),
      selected = head(ship(), 1)
    )
  })
  
  
}
