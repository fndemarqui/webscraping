
#-------------------------------------------------------------------------------
# Leitura interessante:
# https://zapier.com/learn/apis/
#-------------------------------------------------------------------------------

library(tidyverse)
library(httr)
library(jsonlite)

# passo a passo para a leitura dos dados:
# 1) inspect -> network -> refresh browser
# 2) buscar portalGeral (type = xhr) -> Clicar com o botão direito do mouse


# passando a url correta:
url <-  "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalGeral"
covid <- GET(url)

# verificando o status code:
covid %>%
  status_code()


# verificando o conteúdo baixado:
covid %>%
  content()

# É necessário fornecer a chave de acesso. Isso é feito através da lista header...
# A chave de acesso está disponível no passo 2...

# Adicionando a chave de acesso:
covid <- GET(url, 
             add_headers("x-parse-application-id" = "unAFkcaNDeXajurGB7LChj8SgQYS2ptm"))

# verificando o conteúdo novamente:
results <- covid %>% 
  content()

results

# url para baixar os dados:
url_data <- results$results[[1]]$arquivo$url
url_data

# baixando os dados
covid19 <- openxlsx::read.xlsx(url_data, detectDates = TRUE) %>%
  as_tibble()

glimpse(covid19)


url_teste <- "https://xx9p7hp1p7.execute-api.us-east-1.amazonaws.com/prod/PortalSintese"
teste <- GET(url_teste, 
             add_headers("x-parse-application-id" = "unAFkcaNDeXajurGB7LChj8SgQYS2ptm"))

teste %>%
  content()



# lendo mapa do Brasil (por municípios):
library(sf)
mapabr <- readRDS("data/ibgeCities.rds")

#-------------------------------------------------------------------------------
# fornece informação sobre os municípios:

municipios <- fromJSON("https://covid.saude.gov.br/assets/data/municipios.json")
municipios

capitais <- municipios %>%
  filter(capital==TRUE) %>%
  select(-capital) %>%
  relocate(nome, latitude, longitude, codigo_uf, codigo_ibge) %>%
  as_tibble()
capitais

#-------------------------------------------------------------------------------

estados <- fromJSON("https://covid.saude.gov.br/assets/data/br-states.json")
class(estados)
length(estados)
names(estados)
sapply(estados, class)
dim(estados$features)

estados$type 


estados <- estados$features %>%
  as_tibble()
estados

glimpse(estados)

estados$properties

library(sf)

teste <- st_as_sf(estados$geometry)


