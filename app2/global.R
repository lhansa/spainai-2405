library(tidymodels)
library(tidyverse)
library(leaflet)

df_credit <- readr::read_csv(
  "../data/credit_card_fraud.csv", 
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

estados <- unique(df_credit$state)

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

umbral <- mean(df_credit$is_fraud == 1)
