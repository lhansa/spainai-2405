library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(openai)
library(plotly)

# Define server logic
server <- function(input, output) {
  
  # Suponiendo que 'df' es tu conjunto de datos ya cargado
  # df <- readr::read_csv("data/credit_card_fraud.csv")
  df <- read_csv(
    file = "../data/credit_card_fraud.csv", 
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
  
  # Exploración 1: Distribución de transacciones por categoría
  output$plot_category <- renderPlot({
    df |>
      count(category, sort = TRUE) |>
      ggplot(aes(x = reorder(category, n), y = n)) +
      geom_bar(stat = "identity") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Categoría", y = "Número de Transacciones", title = "Distribución por Categoría")
  })
  
  # Exploración 3: Relación entre el monto de la transacción y la población de la ciudad
  output$plot_state_count <- renderTable({
    df |>
      count(state, category) |> 
      tidyr::pivot_wider(names_from = state, values_from = n)
  })
  
  # Exploración 2: Monto de las transacciones por estado
  output$plot_state <- plotly::renderPlotly({
    P <- df |>
      group_by(state) |>
      summarise(TotalAmount = sum(amt)) |>
      ggplot(aes(x = reorder(state, TotalAmount), y = TotalAmount)) +
      geom_bar(stat = "identity") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      labs(x = "Estado", y = "Monto Total", title = "Monto de Transacciones por Estado")
    
    ggplotly(P)
  })
  
  
  # Exploración 4: Distribución del fraude vs. transacciones legítimas
  output$plot_fraud_evolution <- renderPlot({
    df |>
      mutate(date = as.Date(trans_date_trans_time), 
             date = lubridate::floor_date(date, "month")) |> 
      group_by(date) |>
      summarise(frauds = n(), .groups = "drop") |> 
      ggTimeSeries::ggplot_waterfall("date", "frauds")
    
  })
  
  output$text_chatgpt <- renderText({
    "Los datos están bien."
    # create_completion(
    #   model = "gpt-3.5-turbo-instruct",
    #   prompt = "Generate a question and an answer"
    # )
  })
}

