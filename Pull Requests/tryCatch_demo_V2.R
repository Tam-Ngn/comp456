library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(httr)
library(dplyr)
library(purrr)

keys <- c("&api-key=m3IKHavEa8WMAAlDxRTi5dlQG6GPBQAN",
          "&api-key=gDxQ32ZZfP8KarCN5MrGdmrkeKfkko7u",
          "&api-key=HG44jd3IZorXQ4m6DDf0Nh26ba1Mlaoa",
          "&api-key=Cg6eP60vTxQAEtZoez9YccqiF9CHCyCA",
          "&api-key=CunYbsfgJWDXmpfcvKnoW1G3TBAY6grG")


key <- keys[1]
link <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"
dates <- ymd('20210605') + 0:210
d <- format(dates,'%Y%m%d')

totalarticles <- NULL
for(i in d){
  p <- 0
  while(p < 10){
    url <- paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p, key)
    tryCatch({
      response <- httr::GET(url)
      if(response$status_code == 200) {
        articles <- httr::content(response)$response$docs %>%
          purrr::map_df(~list(headline = .x$headline$main, 
                              abstract = .x$abstract, 
                              pub_date = .x$pub_date, 
                              web_url = .x$web_url,
                              news_desk = .x$news_desk,
                              section_name = .x$section_name))
        totalarticles <- dplyr::bind_rows(totalarticles, articles)
        cat("Date:", i, "Page:", p, "# of articles:", nrow(articles), "\n")
        if(nrow(articles) != 10) {
          p <- 11 # Cannot use break here, since it will break the while loop without executing Sys.sleep(12)
        } else {
          p <- p + 1
        }
      } else if(response$status_code == 429) {
        cat("Daily limit reached for current key. Switching to next key.\n")
        keys <- keys[-1]
        if(length(keys) == 0) {
          cat("All keys have reached the daily limit. Exiting loop.\n")
          break
        } else {
          key <- keys[1]
          cat("Using key", key, "for next request.\n")
        }
        Sys.sleep(60)
      } else {
        cat("API request failed with status code", response$status_code, "\n")
        break
      }
    }, error = function(e) {
      cat("Error in API request:", conditionMessage(e), "\n")
      break
    })
    Sys.sleep(12)
  }
}




# save(totalarticles, file = "trumparticlesafter.RData")

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

# need a save function here
