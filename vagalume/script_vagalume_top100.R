

library(rvest)
library(tidyverse)

# baixando a página:
url <- "https://www.vagalume.com.br/top100/"
pagina <- read_html(url)


# top100:
xpath <- "/html/body/div[2]/div[1]/div/div[3]/div[1]/div[1]/div[2]/ol"

teste <- pagina %>%
  html_nodes("ol") %>%
  html_children()
teste


teste <- pagina %>%
  html_children()
teste
