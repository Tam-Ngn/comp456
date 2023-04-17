library(jsonlite)
library(tidyverse)
library(lubridate)
library(rvest)
library(httr)
library(dplyr)
library(purrr)

keys <- c("&api-key=FQ01iI5Z3TQoYDnshTl4GMz0IfTDrE1F",
          "&api-key=jYBG2nOiHHNlHXM8RGVHhlyUDIVUu1fB",
          "&api-key=01i9pT9nnesj00P9veawIMWcJsnO0vei",
          "&api-key=TceNuU0SFP5e0F4CoTr7Ne0zTM4Q0Kj5",
          "&api-key=VA72pccFcItnIkPc4XNesMNgkrcB64M6",
          "&api-key=QWMbRyyDxb9ru69schGNgONWzaFqqrfM",
          "&api-key=Qve0t2oBk0s0U6TRSTtQN8X0wC5GjLkU",
          "&api-key=0ERIip6y8vYL3guVLHPhloYnUDB1Mo4l",
          "&api-key=x64Y06oMVu7ci9tMwHKjuKz62S0BOFN6",
          "&api-key=dKzZ2TlID6zKLV10SyIkuT6k02eHqbxo",
          "&api-key=0G3VMynvlXxM7i0uesIBXbh37E9bXRv1",
          "&api-key=fMCM4RSTyPspzNHrTvIWZDP5rg50G03B",
          "&api-key=L00xTVjUxDZ9dvMwb5DjCLHiCsvQJsit",
          "&api-key=ZDi7nhNDovFVVsztmJrRa1kjkMqoS49R",
          "&api-key=jQPTweHVMOFUGBbc9BSadRM8O7Af6lxV")


key <- keys[1]
link <- "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=biden"
dates <- ymd('20210127') + 0:365
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
