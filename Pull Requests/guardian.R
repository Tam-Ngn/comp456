key <- "&api-key=395b850e-d5c2-4414-aed5-02beddcbbd23"
url <- "https://content.guardianapis.com/search?q=trump&from-date=2020-01-01&to-date=2020-01-01&page=1"
req <- fromJSON(paste0(url, key))
articles <- req$response$results
link = "https://content.guardianapis.com/search?q=trump" # you can adjust the keyword after q


dates <- ymd('20200101') + 0:365 # you can adjust the time range for the pull request
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
for (i in 1:10) {
  article <- read_html(totalarticles$webUrl[i])
 cssSelector <- 
    article %>% 
    html_elements(".article-body-viewer-selector") %>% 
    html_attr('class') %>% str_split(' ') %>% sapply(tail, n=1) %>% paste0('.',.)
    if(cssSelector =='.'){body_text  = NULL}
    else{
      body_text <- article %>% 
      html_elements(cssSelector) %>%   html_text()
      }
  body_text_coll<- tibble(url = totalarticles$webUrl[i], text = paste(body_text, collapse = " "))
  body_text_tot <- bind_rows(body_text_tot, body_text_coll)
}


# here are the CSS selectors if you decide to webscrape by them
# .dcr-n6w1lc, .dcr-az7egx, .dcr-1up63on, .dcr-8zipgp, .dcr-94xsh, .dcr-1gesh1i


