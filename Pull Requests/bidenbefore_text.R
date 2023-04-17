load("C:/Users/cecei/Desktop/comp465/bidenarticles.RData")
library(rvest)
library(readxl)
library(tidyverse)

article <- NULL
body_text_bidenbefore <- NULL
for (i in 1:length(bidenarticles$web_url)) {
  article <- read_html(bidenarticles$web_url[i])
  body_text <- 
    article %>% 
    html_elements(".css-at9mc1.evys1bk0") %>% 
    html_text()
  body_text_coll<- tibble(url = bidenarticles$web_url[i], text = paste(body_text, collapse = " "))
  body_text_bidenbefore <- bind_rows(body_text_bidenbefore, body_text_coll)
}
save(body_text_bidenbefore, file = "bidenarticle_text.RData")


load("C:/Users/cecei/Desktop/comp465/bidenarticlesafter.RData")
library(rvest)
library(readxl)
library(tidyverse)

aftbidentext <- NULL
#for(i in 1:2)
for (i in 1:length(bidenarticlesafter$web_url)) 
{
  article <- read_html(bidenarticlesafter$web_url[i]) 
  body_text <-
    article %>%
    html_elements(".css-at9mc1.evys1bk0") %>% 
    html_text()
  df <- data.frame(text = paste(body_text,collapse=' ')) %>%
    mutate (url = aftbidentext$web_url[i])  
  full_text <- bind_rows(full_text, df)
  Sys.sleep(6)
}
save(full_text, file = "bidenarticlesafter_text.RData")