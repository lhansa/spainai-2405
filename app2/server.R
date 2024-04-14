library(shiny)


# Define server logic
server <- function(input, output) {
  
  # Carga del modelo
  fit_rf <- readRDS("../output/fit_rf.rds")
  
  react_pred <- reactive({
    req(input$file1)
    inFile <- input$file1
    df_input <- readr::read_csv(
      inFile$datapath, 
      col_types = cols(
        trans_date_trans_time = col_datetime(format = ""),
        merchant = col_character(),
        category = col_character(),
        amt = col_double(),
        city = col_character(),
        state = col_character(),
        lat = col_double(),
        long = col_double(),
        city_pop = col_double(),
        job = col_character(),
        dob = col_date(format = ""),
        trans_num = col_character(),
        merch_lat = col_double(),
        merch_long = col_double(),
        is_fraud = col_double()
      )
    ) 

    df_pred <- df_input |> 
      select(is_fraud, all_of(predictors)) |> 
      mutate(
        trans_hour = lubridate::hour(trans_date_trans_time), 
        trans_date = as.Date(trans_date_trans_time), 
        trans_date_trans_time = NULL
      ) 
    
    df_pred <- rec |> 
      bake(new_data = df_pred)
    
    pred_is_fraud <- predict(fit_rf, df_pred, type = "prob")
    return(
      df_input |> 
        mutate(
          prob = pred_is_fraud$.pred_yes, 
          etiqueta = as.numeric(pred_is_fraud$.pred_yes > umbral)
        )
    )
  })
  
  react_filtered <- reactive({
    
    if (is.null(input$select_state)) {
      react_pred()
    } else {
      react_pred() |> 
        filter(state %in% input$select_state)  
    }
    
  })
  
  # Outputs
  output$plot_fraud_amt <- renderPlot({
    if (!is.null(react_pred())) {
      # browser()
      react_filtered() |>
        group_by(etiqueta) |> 
        summarise(
          median = median(amt), 
          q1 = quantile(amt, 0.25), 
          q3 = quantile(amt, 0.75)
        ) |> 
        ggplot() + 
        geom_col(aes(x = as.character(etiqueta), y = median)) + 
        geom_errorbar(aes(x = as.character(etiqueta), 
                          ymin = q1, ymax = q3))
      
    }
    # Placeholder para el gráfico de distribución de predicciones
  })
  
  output$table_jobs <- renderTable({
    react_filtered() |> 
      group_by(job) |> 
      summarise(media = mean(prob), .groups = "drop") |> 
      slice_max(order_by = media, n = input$n_jobs) |> 
      arrange(desc(media)) |> 
      mutate(propension = media / umbral, 
             media = NULL)
    
  })
  
  output$leaflet_prob <- renderLeaflet({
    
    # if (!is.null(react_filtered())) {
    #   browser()
    # }
    df_leaflet <- react_filtered() |> 
      select(lat, long, prob, etiqueta) |> 
      filter(etiqueta == 1) |> 
      mutate(prob = prob / max(prob))
    
    pal <- colorNumeric(palette = "viridis",
                        domain = df_leaflet$prob)
    
    leaflet(df_leaflet) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~long, lat = ~lat, 
        color = ~pal(prob),
        radius = 5, 
        stroke = FALSE, 
        fillOpacity = 0.9,
        clusterOptions = markerClusterOptions())
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("predictions-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write_csv(react_pred(), file)
    }
  )
}

