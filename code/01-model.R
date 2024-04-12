library(tidyverse)
library(tidymodels)

df_credit <- read_csv("data/credit_card_fraud.csv")


df_credit |> 
  group_by(job) |> 
  summarise(is_fraud = mean(is_fraud)) |> 
  filter(is_fraud < 1) |> 
  ggplot() + 
  geom_col(aes(x = reorder(job, is_fraud), y = is_fraud)) + 
  geom_hline(yintercept = mean(df_credit$is_fraud)) + 
  coord_flip()


predictors <- c(
  "category", 
  "amt", 
  "state", 
  "city_pop", 
  # "job", 
  "dob", 
  "trans_date_trans_time"
)

# Procesamiento de la hora de la transacción
df_model <- df_credit |> 
  select(is_fraud, all_of(predictors)) |> 
  mutate(
    trans_hour = hour(trans_date_trans_time), 
    trans_date = as.Date(trans_date_trans_time), 
    trans_date_trans_time = NULL
  ) 

rec <- recipe(~ ., data = df_model) |> 
  step_dummy(
    category, 
    state
    # job
  ) |> 
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

saveRDS(fit_rf, "output/fit_rf.rds")


# ? parsnip:::predict.model_fit()


df_pred <- rec |> 
  prep(training = df_model) |> 
  bake(new_data = df_model)

pred_is_fraud <- predict(fit_rf, df_pred, type = "prob")
