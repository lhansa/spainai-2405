#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
ggplot2::theme_set(ggplot2::theme_light())

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Exploración de Fraude en Tarjetas de Crédito"),
  sidebarLayout(
    sidebarPanel(
      helpText("Explora el conjunto de datos sobre fraude en tarjetas de crédito.")
    ),
    mainPanel(
      plotOutput("plotCategory")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  # Suponiendo que 'df' es tu conjunto de datos ya cargado
  df <- readr::read_csv("../data/credit_card_fraud.csv", show_col_types = FALSE)
  
  # Exploración 1: Distribución de transacciones por categoría
  output$plotCategory <- renderPlot({
    df |>
      dplyr:::count(category, sort = TRUE) |>
      ggplot(aes(x = reorder(category, n), y = n)) +
      geom_bar(stat = "identity") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Categoría", y = "Número de Transacciones", title = "Distribución por Categoría")
  })
}
# Run the application 
shinyApp(ui = ui, server = server)
