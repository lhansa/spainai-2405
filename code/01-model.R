library(tidyverse)
# library(caret)
# library(ModelMetrics)
library(tidymodels)

df_credit <- read_csv("data/credit_card_fraud.csv")

# Procesamiento de la hora de la transacción
df_model <- df_credit |> 
  select(-merchant, -city, 
         -contains("lat"), -contains("long"), 
         -trans_num) |> 
  mutate(
    trans_hour = hour(trans_date_trans_time), 
    trans_date = as.Date(trans_date_trans_time), 
    trans_date_trans_time = NULL
  ) 

rec <- recipe(~ ., data = df_model) |> 
  step_dummy(category, state, job) |> 
  step_date(
    dob, trans_date, 
    features = c("dow", "week", "month"), 
    keep_original_cols = FALSE
  ) |> 
  step_bin2factor(is_fraud)

baked_data <- rec |> 
  prep(training = df_model) |> 
  bake(new_data = NULL)


rf_with_seed <- rand_forest(
  trees = 100, 
  mtry = tune(), 
  mode = "classification"
) |> 
  set_engine("ranger", seed = 63233)

fit_rf <- rf_with_seed |> 
  set_args(mtry = 4) |> 
  fit(is_fraud ~ ., data = baked_data)


parsnip:::tidy.model_fit(fit_rf)
? parsnip:::predict.model_fit()


df_pred <- rec |> 
  prep(training = df_model) |> 
  bake(new_data = df_model)

df_pred <- predict(fit_rf, df_pred)
