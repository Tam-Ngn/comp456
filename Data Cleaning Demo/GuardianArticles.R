library(tidyverse)
library(dplyr)
library(lubridate)
library(urltools)
library(scales)
library(textdata)
library(wordcloud)
library(igraph) 
library(ggplot2)
library(tidytext)
library(broom)
library(reshape2)
library(rvest)
library(tm)
library(ggraph)
library(SnowballC)


load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/biden_guardian_text.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/biden_guardian.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/trump_guardian_text.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/trump_guardian.RData")
data("stop_words")
mystopwords <- tibble(word = c("trump", "trumps", "trump's","trump’s", "biden", "biden's", "biden’s", "donald", "u.s"))

biden_guardian_text <- biden_guardian_text %>% rename(url = webUrl)
biden_guardian_untoken <- biden_guardian %>% 
  rename(url = webUrl,
         pub_date = webPublicationDate) %>% 
  left_join(biden_guardian_text, by = "url") %>% 
  select(url, text, pub_date, sectionName) %>% 
  mutate(text = str_remove_all(text, "[:punct:]")) %>% 
  filter(text != "")

biden_guardian_token <- biden_guardian_untoken %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  anti_join(mystopwords) %>% 
  mutate(stem = wordStem(word))
 
trump_guardian_untoken <- totalarticles %>% 
  rename(url = webUrl,
         pub_date = webPublicationDate) %>% 
  left_join(body_text_tot, by = "url") %>% 
  select(url, text, pub_date, sectionName) %>% 
  mutate(text = str_remove_all(text, "[:punct:]")) %>% 
  filter(text != "")

trump_guardian_token <- trump_guardian_untoken %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>% 
   anti_join(mystopwords) %>% 
   mutate(stem = wordStem(word))

save(biden_guardian_untoken, trump_guardian_untoken, file = "GuardianArticles_untoken.RData")
save(biden_guardian_token, trump_guardian_token, file = "GuardianArticles_token.RData")   
 