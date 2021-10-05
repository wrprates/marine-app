server <- function(input, output, session) {
  
# Reading data
df_clean <- 
  readr::read_rds("https://gitlab.com/wrprates/marine-app/-/raw/main/data/clean/df_ship_clean.RDS") %>% 
  dplyr::mutate(vessel_distance = base::round(vessel_distance, 0))
 
# Reactive Data 
df_filtered <- reactive(
  df_clean %>% 
    dplyr::filter(ship_type == input$ship_type) %>% 
    dplyr::filter(SHIPNAME %in% input$vessel)
)

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
          
          div(
            shiny.semantic::selectInput(
              inputId = "ship_type",
              label = "Ship Type:",
              base::unique(df_clean$ship_type),
              multiple = FALSE
            )
          ),
          

          #### WORKING
          div(
            
            # TODO
            # mod_select_vessel_ui("select_vessels"),
          
            uiOutput("vessel_selected")
            
            #   selectizeInput(
            #   inputId = "vessel",
            #   label = "Vessel:",
            #   choices = df_clean$SHIPNAME,
            #   multiple = TRUE,
            #   options = list(maxItems = 20 ),
            #   width = "100%"
            # )
            
          )
          
        ),
      
      
      card1 = card(
        # style = "border-radius: 0; width: 100%; height: 150px; background: #efefef",
        # div(class = "content",
        #     div(class = "header", style = "margin-bottom: 10px", "Card 1")
        # )
      ),
      
      card2 = card(
        # style = "border-radius: 0; width: 100%; height: 150px; background: #efefef",
        # div(class = "content",
        #     div(class = "header", style = "margin-bottom: 10px", "Card 2")
        # )
      ),
      
      plot = card(
        # style = "border-radius: 0; width: 100%; background: #efefef",
        # div(class = "content",
        #     div(class = "header", style = "margin-bottom: 10px", "Chart Title"),
        #     div(class = "meta", "Chart Subtitle"),
        #     div(class = "description", style = "margin-top: 10px", 
        #         # highchartOutput("pollution", height = "200px")
        #     )
        # )
      )

    )
  })
  
# TODO
# mod_select_vessel_server("select_vessels")

#### WORKING

output$vessel_selected <- 
  renderUI({
    
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
      updateSelectizeInput(
        session, "vessel",
        label = "Vessel:",
        choices = ship,
        selected = head(ship, 1)
      )
    })
    ####
    
    
    # UI Objects
    selectizeInput(
      inputId = "vessel",
      label = "Vessel:",
      choices = df_clean$SHIPNAME,
      multiple = TRUE,
      options = list(maxItems = 20 ),
      width = "100%"
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
  
  
# Server Modules -----------
  # counterServer("counter1")
  
  # selectShipServer("ship_type")
  

  
}
