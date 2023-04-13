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
          "&api-key=dfrzINL05mURMbUrnLDGgsNWBlAqVR9n",
          "&api-key=HG44jd3IZorXQ4m6DDf0Nh26ba1Mlaoa",
          "&api-key=eLkmTD0mVZ2SU5YDmNvCX0JcKl6uzPtT",
          "&api-key=0U00zefnVKrstQqStMiiZEfPLr5LaKx3",
          "&api-key=sGGmvm74Q4HWI1FTfvpb5MGcT03y50QI",
          "&api-key=Sz4tT680fk2AFU40UsgUfCDrTI0SOmaS",
          "&api-key=KdLaU6mRLm0tdNANmLvsO0NMJhVJ7ErF",
          "&api-key=qBAD3miUM4PpxqdCpL4pHllJBSZMsPQX",
          "&api-key=A7LKhg8Lw9hJljE2yoySnkSvpJYfurOz")

dates <- ymd('20200101') + 0:365
d <- format(dates,'%Y%m%d')



totalarticles <- NULL
pr = 0
for(i in d){
    p = 0
    req = NULL
    while(p < 10){
      cat(i,p,'\n')
      while(is.null(req) | class(req) == 'try-error'){ # if there is an error in pulling the key, 
        # go to the next key
     key <- keys[pr %% length(keys)+1] #modular arithmetic
      #key <- sample(keys, size = 1)
      key <- keys[pr %% length(keys)+1] #modular arithmetic
      url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
      req <- try(fromJSON(paste0(url, key)))
      pr = pr + 1}
      articles <- req$response$docs
      totalarticles <- bind_rows(totalarticles,articles)
      req = NULL
      Sys.sleep(3)
      if(is.null(nrow(articles)) | (isTRUE(nrow(articles)) && nrow(articles) != 10)){ break }
      else{p = p+1}
      
    }
}

save(totalarticles, file = "trump_nyt_text.RData")



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


