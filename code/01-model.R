library(tidyverse)
library(lubridate)
library(caret)
library(ModelMetrics)

# Suponiendo que df es tu dataframe

# Procesamiento de la hora de la transacción
df$trans_hour <- hour(hms(substring(df$trans_date_trans_time, 12, 19)))

# One Hot Encoding para 'category'
df <- dummyVars("~ .", data = df, fullRank = TRUE) %>% 
  predict(df)

# Preparación de los datos para el modelo
df_model <- cbind(df, trans_hour = df$trans_hour, is_fraud = df$is_fraud)

# Definición de las variables independientes X y la variable dependiente y
X <- df_model %>% select(-is_fraud)
y <- df_model$is_fraud

# División del conjunto de datos en entrenamiento y prueba
set.seed(123)
trainIndex <- createDataPartition(y, p = .8, 
                                  list = FALSE, 
                                  times = 1)
X_train <- X[trainIndex, ]
Y_train <- y[trainIndex]
X_test  <- X[-trainIndex, ]
Y_test  <- y[-trainIndex]

# Ajuste del modelo de regresión logística
model <- glm(is_fraud ~ ., data = df_model[trainIndex, ], family = "binomial")

# Asumiendo que continuarás con la evaluación del modelo y su implementación en Shiny posteriormente
