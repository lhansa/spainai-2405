library(shiny)

# Define UI for dataset upload and predictions
ui <- fluidPage(
  titlePanel("Predicción de Fraude en Tarjetas de Crédito"),
  sidebarLayout(
    sidebarPanel(
      fileInput('file1', 'Sube tu archivo CSV con datos de transacciones',
                accept = c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
      tags$hr(),
      sliderInput("n_jobs", 
                  label = "Tamaño de la tabla", 
                  min = 1, 
                  max = 20, 
                  value = 10),
      tags$hr(),
      selectInput("select_state",
                  label = "Estados seleccionados", 
                  choices = estados,
                  selected = estados[1], 
                  multiple = TRUE 
                  ), 
      tags$hr(),
      downloadButton('downloadData', 'Descargar Predicciones')
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Predicciones por cuantía", plotOutput("plot_fraud_amt")),
        tabPanel("Predicciones por trabajo", tableOutput("table_jobs")),
        tabPanel("Mapa de fraudes", leafletOutput("leaflet_prob"))
        # TODO Panel con texto con frase de cuántos casos de fraude
        # se detectan sobre total de casos en el fichero
      )
    )
  )
)
