library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)

key <- "&api-key=ps2dcEy37v0hvMltVu2CGWPqEIhdnbg4"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump&begin_date=20200101&end_date=20200101&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump"


dates <- ymd('20200101') + 0:1096
d <- format(dates,'%Y%m%d')

totalarticles <- NULL


for(i in d){
  p = 0
  while(p < 10){
    url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
    req <- fromJSON(paste0(url, key))
    articles <- req$response$docs
    totalarticles <- bind_rows(totalarticles,articles)
    if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
    else{p = p+1}
    Sys.sleep(6)
  }
}


# save(totalarticles, "/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/totalarticles.RData", file = "totalarticles.RData")

article <- NULL
body_text_tot <- NULL
for (i in 1:length(totalarticles$web_url)) {
  article <- read_html(totalarticles$web_url[i])
  body_text <- 
    article %>% 
    html_elements(".css-at9mc1.evys1bk0") %>% 
    html_text()
  body_text_coll<- tibble(url = totalarticles$web_url[i], text = paste(body_text, collapse = " "))
  body_text_tot <- bind_rows(body_text_tot, body_text_coll)
}

# save(body_text_tot, file = "guardian2020_text.RData")



