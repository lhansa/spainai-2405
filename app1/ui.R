ui <- fluidPage(
  titlePanel("Exploración de Fraude en Tarjetas de Crédito"),
  sidebarLayout(
    sidebarPanel(
      helpText("Explora el conjunto de datos sobre fraude en tarjetas de crédito."), 
      textOutput("text_chatgpt")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Categoría", plotOutput("plot_category")),
        tabPanel("Estado y Categoría", tableOutput("plot_state_count")),
        tabPanel("Fraudes por Estado", plotly::plotlyOutput("plot_state")),
        tabPanel("Evolución Mensual", plotOutput("plot_fraud_evolution"))
      )
    )
  )
)

