# Cargar la librería Shiny
library(shiny)

# Definir la interfaz de usuario
ui <- fluidPage(
  titlePanel("Dashboard de Vehículos en Estados Unidos"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("location", "Selecciona una Ciudad:", choices = NULL),
      selectInput("brand", "Selecciona una Marca:", choices = NULL)
    ),
    
    mainPanel(
      plotOutput("grafico_vehiculos"),
      textOutput("precio_promedio"),
      textOutput("model_mas_caro"),
      textOutput("comparar_marcas"),
      textOutput("comparar_millaje_precios"),
      plotOutput("precios_por_ano")
    )
  )
)