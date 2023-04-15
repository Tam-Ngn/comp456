library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(httr)
library(dplyr)
library(purrr)

# key <- "&api-key=9ta4cAbFQANV7eEtSnxC66sXFtDNHF3W"
# url <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump&being_date=20210101&end_date=20220101&page=1"
# # req <- fromJSON(paste0(url, key))
# # articles <- req$response$docs
# link = "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=trump"
keys <- c("&api-key=cumvHk001k7fzLrYUzzhedOnpBmE10KA",
          "&api-key=xvqH3HO2xD6NByq370dklgCcIk0r030H",
          "&api-key=31DbappgFA6WvFzDP6PpWM1d45v3iaR0",
          "&api-key=mV3GN0SnT9XeXptHUU4hPNTPd6008KBF",
          "&api-key=4ixxp0B1hVYQaWd08g30PUEsJfccHoeA",
          "&api-key=OARgAi9nJdFMQDVKX0ZUWGTkTiAi9Fou",
          "&api-key=UirO2ojFEs7VnfzfThRa3m3HFbzigCPe",
          "&api-key=uXl8y0xVM7DB1yyGGkegdWCTcSi0L0gk",
          "&api-key=tKb8xVsOG5P4FSUqGizUs7yXXtTC06X8",
          "&api-key=YKKB0ErfCnSsV0E0I1McWfgf5XnrLM0p",
          "&api-key=1YEgc4e5GGcw6WfkXfOd0U7HcaE0BjcT",
          "&api-key=ps2dcEy37v0hvMltVu2CGWPqEIhdnbg4")
# 
# dates <- ymd('20210101') + 0:365
# d <- format(dates,'%Y%m%d')
# 
# totalarticles <- data.frame()
# for(i in d){
#   p = 0
#   while(p < 10){
#     url = paste0(link, '&begin_date=',i ,'&end_date=',i ,'&page=',p)
#     req <- fromJSON(paste0(url, key))
#     articles <- req$response$docs
#     totalarticles <- bind_rows(totalarticles ,articles)
#     if(isTRUE(nrow(articles)) && nrow(articles) != 10){ break }
#     else{p = p+1}
#     Sys.sleep(12)
#   }
# }

key <- keys[1]
link <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"
dates <- ymd('20210111') + 1:365
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
        cat("totalarticles length", nrow(totalarticles), "Pull request status okay.\n")
        if(isTRUE(nrow(articles)) && nrow(articles) != 10) {
          break
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
