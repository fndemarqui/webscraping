

library(tidyverse)
library(rvest)

#-------------------------------------------------------------------------------


url <- "https://www.vagalume.com.br/raul-seixas/"
xpath <- '//*[@id="alfabetMusicList"]'
pagina <- read_html(url) 



# selecionando os títulos das músicas:
titulos <- pagina %>%
  html_nodes(xpath = xpath) %>%
  html_children() %>%
  html_text()
titulos

# passando para caixa baixa:
titulos <- titulos %>%
  str_to_lower()  %>%
  str_replace_all("tradução", "") 

# removendo as letras duplicadas:  
n <- length(titulos)
J <- length(letters)
for(j in 1:J){
  aux <- str_c("^", letters[j], letters[j])
  titulos <- str_replace(titulos, aux, letters[j] ) 
}
titulos

for(i in 1:n){
  titulos[i] <- str_replace_all(titulos[i], " ", "-")
}
titulos




get_lyric <- function(url, music){
  url <- str_c(url, music, ".html")
  xpath <- '//*[@id="lyrics"]'
  lyric <- try(read_html(url), TRUE)
  
  if(class(lyric) != "try-error"){
    lyric <- lyric %>%
      html_node(xpath = xpath) %>%
      html_text()
    return(lyric)
  }else
    return(c(""))
}

download_letras <- function(url, titulos){
  n <- length(titulos)
  musicas <- c() 
  # create progress bar
  pb <- txtProgressBar(min = 0, max = n, style = 3)
  for(i in 1:n){
    Sys.sleep(0.1)
    # update progress bar
    setTxtProgressBar(pb, i)
    musicas[i]   <- try(get_lyric(url, music=titulos[i]), TRUE)
  }
  close(pb)
  return(musicas)  
}


musicas <- download_letras(url, titulos)


#-------------------------------------------------------------------------------

# Carregando os pacotes:
library("tm")
library("SnowballC")
library("wordcloud")
library("RColorBrewer")



# Load the data as a corpus
docs <- Corpus(VectorSource(musicas))

toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
docs <- tm_map(docs, toSpace, "/")
docs <- tm_map(docs, toSpace, "@")
docs <- tm_map(docs, toSpace, "\\|")



#-------------------------------------------------------------------------------

# Convert the musicas to lower case
docs <- tm_map(docs, content_transformer(tolower))
# Remove numbers
docs <- tm_map(docs, removeNumbers)
# Remove portuguise common stopwords
docs <- tm_map(docs, removeWords, stopwords("portuguese"))
# Remove english common stopwords
docs <- tm_map(docs, removeWords, stopwords("english"))
# Remove your own stop word
# specify your stopwords as a character vector
docs <- tm_map(docs, removeWords, c("pra", "pro")) 
# Remove punctuations
docs <- tm_map(docs, removePunctuation)
# Eliminate extra white spaces
docs <- tm_map(docs, stripWhitespace)
# musicas stemming
# docs <- tm_map(docs, stemDocument)

#-------------------------------------------------------------------------------

dtm <- TermDocumentMatrix(docs)
m <- as.matrix(dtm)
v <- sort(rowSums(m), decreasing=TRUE)
d <- data.frame(word = names(v), freq=v)
head(d, 10)


#-------------------------------------------------------------------------------

set.seed(1234567890)
wordcloud(words = d$word, freq = d$freq, min.freq = 1,
          max.words=200, random.order=FALSE, rot.per=0.35, 
          colors=brewer.pal(8, "Dark2"))

