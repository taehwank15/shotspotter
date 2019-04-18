library(tidyverse)

data <- read_csv("eastpaloalto_sst.csv",
                 col_types = cols(
                   `Incident Number` = col_character(),
                   `Case Number` = col_character(),
                   `Entry Date/Time` = col_character(),
                   `Entry Date/Time_1` = col_character(),
                   Priority = col_character(),
                   Type = col_character(),
                   `Primary Unit` = col_character(),
                   Dispo = col_character(),
                   Location = col_character(),
                   City = col_character(),
                   State = col_character()
                 ))