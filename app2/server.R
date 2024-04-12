library(shiny)


# Define server logic
server <- function(input, output) {
  
  # Carga del modelo
  fit_rf <- readRDS("../output/fit_rf.rds")
  
  dataInput <- reactive({
    req(input$file1)
    inFile <- input$file1
    df_input <- readr::read_csv(inFile$datapath) |> 
      select(is_fraud, all_of(predictors)) |> 
      mutate(
        trans_hour = lubridate::hour(trans_date_trans_time), 
        trans_date = as.Date(trans_date_trans_time), 
        trans_date_trans_time = NULL
      ) 
    df_input <- rec |> 
      bake(new_data = df_input)
    return(df_input)
  })
  
  predictions <- reactive({
    df_predict <- dataInput()
    pred_is_fraud <- predict(fit_rf, df_predict, type = "prob")
    return(
      tibble(
        Transacción = 1:nrow(pred_is_fraud), 
        Predicción = pred_is_fraud$.pred_yes
      )
    )
  })
  
  # Outputs
  output$plotPredDist <- renderPlot({
    # Placeholder para el gráfico de distribución de predicciones
  })
  
  output$plotPredCat <- renderPlot({
    # Placeholder para el gráfico de predicciones por categoría
  })
  
  output$plotHeatmap <- renderPlot({
    # Placeholder para el mapa de calor de fraudes
  })
  
  output$plotAmountPred <- renderPlot({
    # Placeholder para el gráfico de monto vs. predicción
  })
  
  output$plotFraudTime <- renderPlot({
    # Placeholder para el gráfico de tasa de fraude por tiempo
  })
  
  output$summaryPred <- renderTable({
    # Placeholder para el resumen de predicciones
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("predictions-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      predictions <- predictions()
      write_csv(predictions, file)
    }
  )
}

