require("arrow")
require("Rblpapi")
require("lubridate")
require("tidyverse")
require("tidyquant")

tickers <- c(
  "MXEF Index", "MXWO Index", "DM Index", "RTY Index")

fields <- c(
  "PX_LAST", "BEST_PE_RATIO", "BEST_PX_BPS_RATIO", "BEST_DIV_YLD")

end_date <- Sys.Date()
start_date <- end_date - years(60)

con <- blpConnect()
raw_df <- bdh(
  securities = tickers,
  fields = fields,
  start.date = start_date,
  end.date = end_date)

out_df <- tibble()

counter = 1
for (i in raw_df){
  
  df_tmp <- i
  name <- str_split(names(raw_df)[counter], " ")[[1]][1]
  counter <- counter + 1
  
  df_add <- df_tmp %>% 
    pivot_longer(!date, names_to = "field", values_to = "value") %>% 
    mutate(ticker = name)
  
  out_df <- bind_rows(out_df, df_add)
}
 
write_parquet(out_df, "em.parquet")