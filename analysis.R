require("arrow")
require("ggplot2")
require("tidyverse")

df_raw <- read_parquet("em.parquet")

get_lm_stats <- function(df, col){
  
  exog <- df %>% 
    select(all_of(col)) %>% 
    pull()
  
  lm_model <- lm(df$price ~ exog)
  coefs <- lm_model$coefficients
  alpha <- as.numeric(coefs[1])
  beta <- as.numeric(coefs[2])
  rsquared <- as.numeric(summary(lm_model)$r.squared)
  
  return(c(alpha, beta, rsquared))
}

get_lm_plot_data <- function(df){
  
  df_wider <- df %>% 
    pivot_wider(names_from = fld, values_from = value)
  
  lm_stats_div <- get_lm_stats(df_wider, "div_yield")
  lm_stats_pb <- get_lm_stats(df_wider, "pb_ratio")
  lm_stats_pe <- get_lm_stats(df_wider, "pe_ratio")
  
  scatter_col <- tibble(
    "stat" = c("Alpha", "Beta", "RSquared"),
    div_yield = lm_stats_div,
    pb_ratio = lm_stats_pb,
    pe_ratio = lm_stats_pe) %>% 
    pivot_longer(!stat) %>% 
    pivot_wider(names_from = stat, values_from = value) %>% 
    rename("fld" = "name") %>% 
    inner_join(col_plot_renamer, by = "fld") %>% 
    mutate(col = paste(
      field, "\n",
      "Alpha:", round(Alpha,2), 
      "Beta:", round(Beta,2),
      "RSquared:",round(RSquared, 2))) %>% 
    select(fld, col)
  
  df_plot <- df_wider %>% 
    pivot_longer(!c(date,price), names_to = "exog", values_to = "value") %>% 
    rename("fld" = exog) %>% 
    inner_join(scatter_col, by = "fld") 
  
  return(df_plot)
}

get_ratios <- function(df){
  
  df_out <- df %>%
    pivot_wider(names_from = "ticker", values_from = value) %>%
    mutate(
      RTY = RTY / MXEF,
      DM = DM / MXEF,
      MXWO = MXWO / MXEF) %>%
    select(-MXEF) %>%
    pivot_longer(!date, names_to = "ticker", values_to = "value") %>%
    drop_na()
  
  return(df_out)
}

df_meta <- df_raw %>% 
  drop_na() %>% 
  select(-value) %>% 
  group_by(ticker, field) %>% 
  summarise(
    start = min(date),
    end = max(date),
    count = n()) %>% 
  ungroup()

col_renamer <- tibble(
  "field" = c("PX_LAST", "BEST_DIV_YLD", "BEST_PE_RATIO", "BEST_PX_BPS_RATIO"),
  "fld" = c("price", "div_yield", "pe_ratio", "pb_ratio"))

col_plot_renamer <- tibble(
  "fld" = c("price", "div_yield", "pe_ratio", "pb_ratio"),
  "field" = c("Price", "Dividend Yield", "PE Ratio", "PB Ratio"))

df_prep <- df_raw %>%
  drop_na() %>% 
  inner_join(col_renamer, by = "field") %>% 
  select(-field)

start_date <- min(df_prep$date)
end_date <- max(df_prep$date)

df_prep %>% 
  inner_join(col_plot_renamer, by = "fld") %>% 
  select(-fld) %>% 
  ggplot(aes(x = date, y = value, color = ticker)) +
  facet_wrap(~field, scale = "free") +
  geom_line() +
  labs(title = paste("Data from", start_date, "to", end_date))

# start by making ratios
df_ratio <- df_prep %>% 
  group_by(fld) %>% 
  group_modify(~get_ratios(.)) %>% 
  ungroup()

df_ratio %>% 
  inner_join(col_plot_renamer, by = "fld") %>% 
  select(-fld) %>% 
  ggplot(aes(x = date, y = value, color = ticker)) +
  facet_wrap(~field, scale = "free") +
  geom_line() +
  labs(
    title = paste(
      "Ratio between Selected Developed Index vs. Emerging from", 
      start_date, 
      "to",
      end_date))

df_regress <- df_ratio %>% 
  group_by(ticker) %>% 
  group_modify(~get_lm_plot_data(.))

df_plot <- df_regress %>% 
  group_by(ticker) %>% 
  mutate(col = paste(ticker, min(date), "-", max(date), col)) %>% 
  ungroup() %>% 
  select(price, value, col)

df_plot %>% 
  ggplot(aes(x = value, y = price)) +
  facet_wrap(~col, scale = "free") +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(title = "Ratio (Developed Market / Emerging Market) regressions")