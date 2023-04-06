library(jsonlite)
library(tidyverse)
library(lubridate)

key <- "&api-key=UkLuFruKUXYehFSXy0sgNGaFwPkB6HEa"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden&being_date=20200101&end_date=20200101&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"

# url <- param_set(link, "api-key", url_encode(key))


dates <- ymd('20200101') + 0:500
d <- format(dates,'%Y%m%d')

bidenarticles <- NULL


for(i in d){
  p = 0
  while(p < 10){
    url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
    req <- fromJSON(paste0(url, key))
    articles <- req$response$docs
    bidenarticles <- bind_rows(bidenarticles,articles)
    if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
    else{p = p+1}
    Sys.sleep(6)
  }
}


save(bidenarticles, file = "bidenarticles.RData")




