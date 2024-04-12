library(shiny)
library(dplyr)
library(ggplot2)

# Define server logic
server <- function(input, output) {
  
  df_credit <- readr::read_csv("../data/credit_card_fraud.csv")
  
  output$select_state <- renderUI({
    shiny::selectInput(
      inputId = "sel_state", 
      label = "State", 
      choices = c("todos", unique(df_credit$state)), 
      selected = "todos"
    )
  })
  
  df_work <- reactive({
    df_out <- df_credit
    
    if (input$sel_state != "todos") {
      df_out <- df_credit |> 
        filter(state %in% input$sel_state)  
    }
    
    df_out
    
  })
  
  
  # Exploración 1: Distribución de transacciones por categoría
  output$plotCategory <- renderPlot({
    df_work() |>
      count(category, sort = TRUE) |>
      ggplot(aes(x = reorder(category, n), y = n)) +
      geom_bar(stat = "identity") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Categoría", y = "Número de Transacciones", title = "Distribución por Categoría")
  })
  
  # Exploración 2: Monto de las transacciones por estado
  output$plotStateAmount <- renderPlot({
    df_work() |>
      group_by(state) |>
      summarise(TotalAmount = sum(amt)) |>
      ggplot(aes(x = reorder(state, TotalAmount), y = TotalAmount)) +
      geom_bar(stat = "identity") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Estado", y = "Monto Total", title = "Monto de Transacciones por Estado")
  })
  
  # Exploración 3: Relación entre el monto de la transacción y la población de la ciudad
  output$plotAmountVsPopulation <- renderPlot({
    df_work() |>
      ggplot(aes(x = city_pop, y = amt)) +
      geom_point(alpha = 0.5) +
      scale_x_log10() +
      labs(x = "Población de la Ciudad (log)", y = "Monto de la Transacción", title = "Monto vs. Población de la Ciudad")
  })
  
  # Exploración 4: Distribución del fraude vs. transacciones legítimas
  output$plotFraudDistribution <- renderPlot({
    df_work() |>
      ggplot(aes(x = as.factor(is_fraud), fill = as.factor(is_fraud))) +
      geom_bar() +
      scale_fill_manual(values = c("0" = "blue", "1" = "red")) +
      labs(x = "Es Fraude", y = "Número de Transacciones", title = "Distribución de Fraude vs. Legítimas", fill = "Tipo")
  })
}

