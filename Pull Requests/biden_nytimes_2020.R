library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(httr)
library(dplyr)
library(purrr)

keys <- c("&api-key=Lz5guEwUYKWXOq5nj16QHHoCM0oXNTbG",
          "&api-key=erXzxaQTLtbEXMNxA5IqsuWHpxYCUyb7",
          "&api-key=gDxQ32ZZfP8KarCN5MrGdmrkeKfkko7u")


key <- keys[1]
link <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"
dates <- ymd('20200101') + 0:365
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
          p <- 11 # Don't use "break" here, since it will break the while loop without executing Sys.sleep(12)
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



# Run these every time before you first start pulling article text
article <- NULL
body_text_tot <- NULL
failures <- 0

# updated version of text pulling code
for (i in 7288:length(totalarticles$web_url)) {
  tryCatch({
    response <- GET(totalarticles$web_url[i])
    if (response$status_code == 500) {
      failures <- failures + 1
      if (failures < 3) {
        cat("# of failures :", failures, "\n", "API request failed with status code", response$status_code, "\n")
        Sys.sleep(60)
      }
      else {
        cat("# of failures :", failures, "\n", "API request failed with status code", response$status_code, "\n")
        Sys.sleep(180)
        failures <- 0
      }
    }
    else if (response$status_code == 200) {
      article <- read_html(totalarticles$web_url[i])
      body_text <- 
        article %>% 
        html_elements(".css-at9mc1.evys1bk0") %>% 
        html_text()
      body_text_coll<- tibble(url = totalarticles$web_url[i], text = paste(body_text, collapse = " "))
      body_text_tot <- bind_rows(body_text_tot, body_text_coll)
      cat("# of article text pulled: ", nrow(body_text_tot), "\n")
    }
    else if (response$status_code == 404) {
      cat("The url:", web_url[i], "returned a 404 status code. Skipping to the next url. \n")
      next
    }
    else {
      cat("API request failed with status code", response$status_code, "\n")
      break
    }
  }, error = function(e) {
    cat("Error in API request:", conditionMessage(e), "\n")
    break
  })
}




