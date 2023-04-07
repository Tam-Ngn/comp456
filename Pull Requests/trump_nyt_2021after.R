library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)

key <- "&api-key=Foeien0NfEGqCqAMv7ldo5VqbeeJuroW"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump&begin_date=20210101&end_date=20210101&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump"


dates <- ymd('20210101') + 0:500
d <- format(dates,'%Y%m%d')

trumpntyarticlesafter <- NULL


for(i in d){
  p = 0
  while(p < 10){
    url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
    req <- fromJSON(paste0(url, key))
    articles <- req$response$docs
    trumpntyarticlesbeforeafter <- bind_rows(trumpntyarticlesafter,articles)
    if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
    else{p = p+1}
    Sys.sleep(12)
  }
}


save(trumpntyarticlesafter, file = "trumparticlesafter.RData")




article <- NULL
trumpa_body_text_tot <- NULL
for (i in 1:length(trumparticlesafter$web_url)) {
  article <- read_html(trumpntyarticlesafter$web_url[i])
  body_text <- 
    article %>% 
    html_elements(".css-at9mc1.evys1bk0") %>% 
    html_text()
  body_text_coll<- tibble(url = trumpntyarticlesafter$web_url[i], text = paste(body_text, collapse = " "))
  trumpa_body_text_tot <- bind_rows(trumpa_body_text_tot, body_text_coll)
}
