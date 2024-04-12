ui <- fluidPage(
  titlePanel("Exploración de Fraude en Tarjetas de Crédito"),
  sidebarLayout(
    sidebarPanel(
      helpText("Explora el conjunto de datos sobre fraude en tarjetas de crédito."), 
      uiOutput("select_state")
      
      
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Categoría", plotOutput("plotCategory")),
        tabPanel("Monto por Estado", plotOutput("plotStateAmount")),
        tabPanel("Monto vs. Población", plotOutput("plotAmountVsPopulation")),
        tabPanel("Fraude vs. Legítimo", plotOutput("plotFraudDistribution"))
      )
    )
  )
)

