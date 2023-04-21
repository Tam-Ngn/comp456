library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)

key <- "&api-key=395b850e-d5c2-4414-aed5-02beddcbbd23"
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
    # Sys.sleep(6)
  }
}


# save(totalarticles, file = "trump_guardian.RData")

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

# save(body_text_tot, file = "trump_guardian_text.RData")

article <- NULL
body_text_tot_6 <- NULL
for (i in 1:length(totalarticles$webUrl)) {
  article <- read_html(totalarticles$webUrl[i])
  body_text <- 
    article %>% 
    html_elements(c(".dcr-1gesh1i")) %>% 
    html_text()
  body_text_coll<- tibble(url = totalarticles$webUrl[i], text = paste(body_text, collapse = " "))
  body_text_tot_6 <- bind_rows(body_text_tot_6, body_text_coll)
}

html_element(".dcr-az7egx", ".dcr-1up63on", ".dcr-8zipgp", ".dcr-94xsh", "dcr-1gesh1i")

