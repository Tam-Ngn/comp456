library(jsonlite)
library(tidyverse)
library(lubridate)

key <- "&api-key=9ta4cAbFQANV7eEtSnxC66sXFtDNHF3W"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump&being_date=20210101&end_date=20220101&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump"

# url <- param_set(link, "api-key", url_encode(key))


dates <- ymd('20210101') + 0:500
d <- format(dates,'%Y%m%d')

trumparticlesafter <- NULL


for(i in d){
  p = 0
  while(p < 10){
    url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
    req <- fromJSON(paste0(url, key))
    articles <- req$response$docs
    trumparticlesafter <- bind_rows(trumparticlesafter,articles)
    if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
    else{p = p+1}
    Sys.sleep(6)
  }
}


save(trumparticlesafter, file = "trumparticlesafter.RData")