library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)

key <- "&api-key=9f51672b-1066-4b6f-a6ca-4066419d6f96"
url <- "https://content.guardianapis.com/search?q=trump&from-date=2020-01-01&to-date=2020-01-01&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$results
link = "https://content.guardianapis.com/search?q=trump"


dates <- ymd('20200101') + 0:365
d <- format(dates,'%Y-%m-%d')

totalarticles <- NULL


for(i in d){
  p = 1
  while(p < 10){
    url = paste0(link, '&from-date=',i ,'&to-date=',i ,'&page=',p)
    req <- try(fromJSON(paste0(url, key)),silent=TRUE)
    if(class(req) == 'try-error'){ break }
    else{
      articles <- req$response$results
      totalarticles <- bind_rows(totalarticles,articles)
      if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
      else{p = p+1}
    }
    Sys.sleep(6)
  }
}

# save(totalarticles, file = "guardian2020.RData")


# article <- read_html("https://www.theguardian.com/media/2023/mar/08/fox-news-dominion-lawsuit-what-we-know")
# 
# 
# body_text <- 
#   article %>% 
#   html_elements(".dcr-n6w1lc") %>% 
#   html_text()
# 
# paste(body_text, collapse = " ")

article <- NULL
body_text_tot <- NULL
for (i in 1:length(totalarticles$webUrl)) {
  article <- read_html(totalarticles$webUrl[i])
  body_text <- 
    article %>% 
    html_elements(".dcr-n6w1lc") %>% 
    html_text()
  body_text_coll<- tibble(url = totalarticles$webUrl[i], text = paste(body_text, collapse = " "))
  body_text_tot <- bind_rows(body_text_tot, body_text_coll)
}

# save(body_text_tot, file = "guardian2020_text.RData")
