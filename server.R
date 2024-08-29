# Cargar las librerías necesarias
library(dplyr)
library(tidyr)
library(readr)
library(shiny)
library(ggplot2)

# Definir la lógica del servidor para la aplicación Shiny
server <- function(input, output, session) {
  
  # Establecer el directorio de trabajo y cargar el archivo CSV con los datos de vehículos
  setwd("C:/Users/chris/OneDrive/Documentos/Proyectos de RStudio/Shiny Projects/Entrega/Entrega")
  datos <- read_csv("Vehicule_Manufacturing_Dataset.csv")
  
  # Limpieza y conversión de los datos
  datos_limpios <- datos %>%
    mutate(Mileage = as.numeric(Mileage),
           Price = as.numeric(Price))
  
  # Actualizar las opciones de los selectInput en la interfaz de usuario
  updateSelectInput(session, "location", choices = unique(datos_limpios$Location))
  updateSelectInput(session, "brand", choices = unique(datos_limpios$Brand))
  
  # Renderizar el gráfico de barras basado en la selección del usuario
  output$grafico_vehiculos <- renderPlot({
    datos_filtrados <- datos_limpios %>%
      filter(Location == input$location, Brand == input$brand)
    
    ggplot(datos_filtrados, aes(x = Model, y = Price, fill = Model)) +
      geom_bar(stat = "identity") +
      theme_minimal() +
      labs(title = paste("Precio de los modelos de", input$brand, "en", input$location),
           x = "Modelo",
           y = "Precio") +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Renderizar el texto con el precio promedio de los vehículos
  output$precio_promedio <- renderText({
    datos_filtrados <- datos_limpios %>%
      filter(Location == input$location, Brand == input$brand)
    
    precio_promedio <- mean(datos_filtrados$Price, na.rm = TRUE)
    
    paste("El precio promedio de los vehículos de", input$brand, "en", input$location, "es $", round(precio_promedio, 2))
  })
  
  # Calcular y mostrar el modelo más caro
  output$model_mas_caro <- renderText({
    datos_filtrados <- datos_limpios %>%
      filter(Location == input$location)
    
    if (nrow(datos_filtrados) > 0) {
      modelo_caro <- datos_filtrados %>%
        filter(Price == max(Price, na.rm = TRUE)) %>%
        select(Model, Price)
      
      paste("El modelo de vehículo más caro en", input$location, "es", modelo_caro$Model, "con un precio de $", round(modelo_caro$Price, 2))
    } else {
      "No hay datos suficientes para determinar el modelo más caro en esta ubicación."
    }
  })
  
  # Hipótesis 1: Comparar precios promedio entre dos marcas
  output$comparar_marcas <- renderText({
    datos_filtrados <- datos_limpios %>%
      filter(Location == input$location)
    
    marcas <- unique(datos_filtrados$Brand)
    if (length(marcas) >= 2) {
      marca1 <- marcas[1]
      marca2 <- marcas[2]
      
      precios_promedio <- datos_filtrados %>%
        group_by(Brand) %>%
        summarize(Promedio_Precio = mean(Price, na.rm = TRUE))
      
      precio_marca1 <- precios_promedio$Promedio_Precio[precios_promedio$Brand == marca1]
      precio_marca2 <- precios_promedio$Promedio_Precio[precios_promedio$Brand == marca2]
      
      paste("Comparación de precios promedio entre marcas en", input$location, ":",
            marca1, "es $", round(precio_marca1, 2), "y",
            marca2, "es $", round(precio_marca2, 2))
    } else {
      "No hay suficientes marcas para comparar en esta ubicación."
    }
  })
  
  # Hipótesis 2: Comparar millaje en ciudades con precios altos y bajos
  output$comparar_millaje_precios <- renderText({
    estadisticas_ciudad <- datos_limpios %>%
      group_by(Location) %>%
      summarize(Millaje_Promedio = mean(Mileage, na.rm = TRUE),
                Precio_Promedio = mean(Price, na.rm = TRUE))
    
    if (nrow(estadisticas_ciudad) > 1) {
      ciudades_high_low <- estadisticas_ciudad %>%
        arrange(desc(Precio_Promedio)) %>%
        slice(c(1, n()))
      
      ciudad_alta <- ciudades_high_low[1, ]
      ciudad_baja <- ciudades_high_low[2, ]
      
      paste("Comparación del millaje promedio en ciudades con precios altos y bajos:",
            ciudad_alta$Location, "con precio promedio de $", round(ciudad_alta$Precio_Promedio, 2),
            "tiene un millaje promedio de", round(ciudad_alta$Millaje_Promedio, 2), "y",
            ciudad_baja$Location, "con precio promedio de $", round(ciudad_baja$Precio_Promedio, 2),
            "tiene un millaje promedio de", round(ciudad_baja$Millaje_Promedio, 2))
    } else {
      "No hay suficientes ciudades para comparar millaje con precios altos y bajos."
    }
  })
  
  # Hipótesis 3: Comparar precios promedio por año del modelo
  output$precios_por_ano <- renderPlot({
    datos_filtrados <- datos_limpios %>%
      filter(Brand == input$brand)
    
    precios_por_ano <- datos_filtrados %>%
      group_by(Year) %>%
      summarize(Promedio_Precio = mean(Price, na.rm = TRUE))
    
    ggplot(precios_por_ano, aes(x = Year, y = Promedio_Precio)) +
      geom_line() +
      labs(title = paste("Precio Promedio por Año del Modelo para la marca", input$brand),
           x = "Año del Modelo",
           y = "Precio Promedio")
  })
  
}
