library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(readxl)
library(urltools)

key <- "&api-key=CunYbsfgJWDXmpfcvKnoW1G3TBAY6grG"
url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump&begin_date=20200101&end_date=20200101&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$docs
link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump"

keys <- c("&api-key=CunYbsfgJWDXmpfcvKnoW1G3TBAY6grG",
          "&api-key=gDxQ32ZZfP8KarCN5MrGdmrkeKfkko7u",
          "&api-key=Cg6eP60vTxQAEtZoez9YccqiF9CHCyCA",
          "&api-key=9fiVSl9AtqEaHqtInQLx3V56dmUgYy27",
          "&api-key=kfpVf3ML5uymHzA83Ai5op7AZfQbkjcB",
          "&api-key=dfrzINL05mURMbUrnLDGgsNWBlAqVR9n")

dates <- ymd('20200101') + 0:5
d <- format(dates,'%Y%m%d')



totalarticles <- NULL
pr = 0
for(i in d){
    p = 0
    while(p < 10){
      cat(i,p,'\n')
      key <- keys[pr %% length(keys)+1] #modular arithmetic
      url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
      req <- fromJSON(paste0(url, key))
      pr = pr + 1
      articles <- req$response$docs
      totalarticles <- bind_rows(totalarticles,articles)
      if(is.null(nrow(articles)) | (isTRUE(nrow(articles)) && nrow(articles) != 10)){ break }
      else{p = p+1}
      Sys.sleep(6)
    }
}


trumpnyttotal <-  totalarticles %>% 
  mutate(date = str_trunc(pub_date, width = 10, ellipsis = "")) %>% 
  filter(date >= "2020-01-01")

# save(trumpnyttotal, file = "trump_guardian.RData")

body_text_tot <- NULL
for (i in 1:length(totalarticles$web_url)) {
  article <- read_html(totalarticles$web_url[i])
  body_text <- 
    article %>% 
    html_elements(".css-at9mc1.evys1bk0") %>% 
    html_text()
  body_text_coll<- tibble(url = totalarticles$webb_url[i], text = paste(body_text, collapse = " "))
  body_text_tot <- bind_rows(body_text_tot, body_text_coll)
}

# save(body_text_tot, file = "trump_nyt.RData")


totalarticles %>% count(web_url) %>% filter(n>1) %>% nrow()


