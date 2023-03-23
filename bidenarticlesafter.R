library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(xml2)

key <- "&api-key=8EHpb3SNztyQsCIX22MXuwgGTRa7RZZS"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden&being_date=20210101&end_date=20220101&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"

# url <- param_set(link, "api-key", url_encode(key))


dates <- ymd('20210101') + 0:500
d <- format(dates,'%Y%m%d')

bidenarticlesafter <- NULL


for(i in d){
  p = 0
  while(p < 10){
    url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
    req <- fromJSON(paste0(url, key))
    articles <- req$response$docs
    bidenarticlesafter <- bind_rows(bidenarticlesafter,articles)
    if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
    else{p = p+1}
    Sys.sleep(6)
  }
}


save(bidenarticlesafter, file = "bidenarticlesafter.RData")

