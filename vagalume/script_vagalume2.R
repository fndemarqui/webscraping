

# Carregando os pacotes:
library(rvest)
library(tidyverse)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(gridExtra)


#-------------------------------------------------------------------------------

lista_palavras <- function(nome){
  
  url <- "https://www.vagalume.com.br/"
  url <- str_c(url, nome, "/", sep = "")
  
  xpath <- '//*[@id="alfabetMusicList"]'
  pagina <- read_html(url) 
  
  # selecionando os títulos das músicas:
  titulos <- pagina %>%
    html_nodes(xpath = xpath) %>%
    html_children() %>%
    html_text()
  
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
  
  for(i in 1:n){
    titulos[i] <- str_replace_all(titulos[i], " ", "-")
  }
  
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
  palavras <- data.frame(word = names(v), freq=v)
  
  #-------------------------------------------------------------------------------
  
  out <- list(titulos = titulos, musicas = musicas, palavras=palavras)
  return(out)
}


plot_nuvem <- function(palavras){
  set.seed(1234567890)
  with(
  palavras$palavras,
  wordcloud(words = word, freq = freq, min.freq = 1,
            max.words=200, random.order=FALSE, rot.per=0.35, 
            colors=brewer.pal(8, "Dark2"))
  )
  
}


# raul <- lista_palavras("raul")
# cazuza <- lista_palavras("cazuza")
# beatles <- lista_palavras("the-beatles")
# stones <- lista_palavras("the-rolling-stones")
# 
# saveRDS(raul, "data/raul.rda")
# saveRDS(cazuza, "data/cazuza.rda")
# saveRDS(beatles, "data/beatles.rda")
# saveRDS(stones, "data/stones.rda")


raul <- readRDS("data/raul.rda")
cazuza <- readRDS("data/cazuza.rda")
beatles <- readRDS("data/beatles.rda")
stones <- readRDS("data/stones.rda")


plot_nuvem(raul)
plot_nuvem(cazuza)
plot_nuvem(beatles)
plot_nuvem(stones)


# library(gridExtra)
# grid.arrange(ncol = 2,
#    plot_nuvem(raul),
#    plot_nuvem(cazuza),
#    plot_nuvem(beatles),
#    plot_nuvem(stones)
# )


library(gridExtra)
grid.arrange(ncol = 2,
   plot_nuvem(raul),
   plot_nuvem(cazuza)
)
