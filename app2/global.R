library(tidymodels)
library(tidyverse)

df_credit <- readr::read_csv("../data/credit_card_fraud.csv")

predictors <- c(
  "category", 
  "amt", 
  "state", 
  "city_pop", 
  "dob", 
  "trans_date_trans_time"
)

# Procesamiento de la hora de la transacción
df_model <- df_credit |> 
  select(is_fraud, all_of(predictors)) |> 
  mutate(
    trans_hour = lubridate::hour(trans_date_trans_time), 
    trans_date = as.Date(trans_date_trans_time), 
    trans_date_trans_time = NULL
  ) 

rec <- recipe(~ ., data = df_model) |> 
  step_dummy(
    category, 
    state
  ) |> 
  step_date(
    dob, trans_date, 
    features = c("dow", "week", "month"), 
    keep_original_cols = FALSE
  ) |> 
  step_bin2factor(is_fraud) |> 
  prep(training = df_model) 


  # bake(new_data = NULL)
