library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(readxl)
library(urltools)

key <- "&api-key=mQUckedTDhO0gLmGD0IYqefpdQCuWWvA"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden&being_date=20201108&end_date=20201108&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"


dates <- ymd('20201108') + 0:500
d <- format(dates,'%Y%m%d')

bidenelection <- NULL


for(i in d){
  p = 0
  while(p < 10){
    url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
    req <- fromJSON(paste0(url, key))
    articles <- req$response$docs
    bidenelection <- bind_rows(bidenelection,articles)
    if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
    else{p = p+1}
    Sys.sleep(12)
  }
}


save(bidenelection, file = "bidenarticlesrightafter.RData")



biden_text_directly_after <- NULL
for (i in 1:length(bidenelection$web_url)) {
  article <- read_html(bidenelection$web_url[i])
  body_text <- 
    article %>% 
    html_elements(".css-at9mc1.evys1bk0") %>% 
    html_text()
  body_text_coll<- tibble(url = bidenelection$webb_url[i], text = paste(body_text, collapse = " "))
  biden_text_directly_after <- bind_rows(biden_text_directly_after, body_text_coll)
}

save(biden_text_directly_after, file = "biden_text_after_nyt.RData")