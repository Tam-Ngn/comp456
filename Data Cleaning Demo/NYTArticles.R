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


load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/biden_nytimes_text.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/biden_nytimes.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/trump_nytimes_text.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/unclean/trump_nytimes.RData")
data("stop_words")
mystopwords <- tibble(word = c("trump", "trumps", "trump's","trump’s", "biden", "biden's", "biden’s", "donald", "u.s"))

biden_nytimes_untoken <- biden_nytimes %>% 
  rename(url = web_url) %>% 
  left_join(biden_nytimes_text, by = "url") %>% 
  select(url, text, pub_date, section_name) %>% 
  mutate(text = str_remove_all(text, "[:punct:]")) %>% 
  filter(text != "")

biden_nytimes_token <- biden_nytimes_untoken %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  anti_join(mystopwords) %>% 
  mutate(stem = wordStem(word))

trump_nytimes_untoken <- trump_nytimes %>% 
  left_join(trump_nytimes_text, by = "url") %>% 
  select(url, text, pub_date, section_name) %>% 
  mutate(text = str_remove_all(text, "[:punct:]")) %>% 
  filter(text != "")

trump_nytimes_token <- trump_nytimes_untoken %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  anti_join(mystopwords) %>% 
  mutate(stem = wordStem(word))

save(biden_nytimes_untoken, trump_nytimes_untoken, file = "NYTArticles_untoken.RData")
save(biden_nytimes_token, trump_nytimes_token, file = "NYTArticles_token.RData")
