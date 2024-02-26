library(shiny)

# Define UI for dataset upload and predictions
ui <- fluidPage(
  titlePanel("Predicción de Fraude en Tarjetas de Crédito"),
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Sube tu archivo CSV con datos de transacciones',
                accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
      tags$hr(),
      downloadButton('downloadData', 'Descargar Predicciones')
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Distribución de Predicciones", plotOutput("plotPredDist")),
        tabPanel("Predicciones por Categoría", plotOutput("plotPredCat")),
        tabPanel("Mapa de Calor de Fraudes", plotOutput("plotHeatmap")),
        tabPanel("Monto vs. Predicción", plotOutput("plotAmountPred")),
        tabPanel("Tasa de Fraude por Tiempo", plotOutput("plotFraudTime")),
        tabPanel("Resumen de Predicciones", tableOutput("summaryPred"))
      )
    )
  )
)
