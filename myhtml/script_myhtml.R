
library(rvest)
library(tidyverse)

#-------------------------------------------------------------------------------
# lendo o conteúdo da página:
pagina <- read_html("myhtml/myhtml.html")
pagina

# verificando a classe e a estrutua do objeto pagina:
class(pagina)
str(pagina)


# visualizando todo o texto da página:
pagina %>% html_text()

#-------------------------------------------------------------------------------

# extraindo todos os parágrafos disponíveis na página:
pagina %>%
  html_nodes("p")

# extraindo todos os hiperlinks disponíveis na página:
pagina %>%
  html_nodes("a")

# extraindo a lista ordenada contida na página:
pagina %>%
  html_node("ol") 

# extraindo a lista desordenada contida na página:
pagina %>%
  html_node("ul") 

#-------------------------------------------------------------------------------
# extraindo o texto contido nad listas:

pagina %>%
  html_node("ol") %>%
  html_text()

pagina %>%
  html_node("ul") %>%
  html_text()


#-------------------------------------------------------------------------------
# extraindo todas as tabelas:
tabs <- pagina %>%
  html_table() 
tabs

# extraindo uma tabela especifica através da especificação do xpath:
xpath <- '//*[@id="tabela1"]'
tab1 <- pagina %>%
  html_node(xpath = xpath) %>%
  html_table() 
tab1

# extraindo a segunda tabela:
xpath <- '//*[@id="tabela2"]'
tab2 <- pagina %>%
  html_node(xpath = xpath) %>%
  html_table() 
tab2

#-------------------------------------------------------------------------------
# extraindo a informação contida na lista ordenada:

lista1 <-pagina %>%
  html_node("ol")

lista2 <- pagina %>%
  html_node("ol") %>%
  html_text()

lista3 <- pagina %>%
  html_node("ol") %>%
  html_children() %>%
  html_text()


# comparando:
lista1
lista2
lista3

class(lista1)
class(lista2)
class(lista3)

length(lista2)
length(lista3)
