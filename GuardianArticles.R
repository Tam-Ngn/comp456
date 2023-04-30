library(SnowballC)

load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/Biden_Guardian_Before_FullText.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/Biden_Guardian_After_FullText.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/trump_guardian_text.RData")
load("/Users/yiyangshi/Desktop/SPRING 2023/STAT 456/comp465/Articles Data/trump_guardian.RData")
data("stop_words")
mystopwords <- tibble(word = c("trump", "trumps", "trump's","trump’s", "biden", "biden's", "biden’s", "donald", "u.s"))

guardian_biden_2021 <- g_b_a %>% 
  select(webUrl, text, webPublicationDate, sectionName) %>% 
  rename(url = webUrl,
         pub_date = webPublicationDate) %>% 
  mutate(text = str_remove_all(text, "[:punct:]")) %>% 
  filter(text != "") %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  anti_join(mystopwords) %>% 
  mutate(stem = wordStem(word))

 guardian_biden_2020 <- g_b_b_fullText %>% 
   select(url, text, webPublicationDate, sectionName) %>% 
   rename(pub_date = webPublicationDate) %>% 
   mutate(text = str_remove_all(text, "[:punct:]")) %>% 
   filter(text != "") %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>% 
   anti_join(mystopwords) %>% 
   mutate(stem = wordStem(word))
 
 full_biden_guardian <- rbind(guardian_biden_2020, guardian_biden_2021)
 
 
 full_trump_guardian <- totalarticles %>% 
   rename(url = webUrl,
          pub_date = webPublicationDate) %>% 
   left_join(body_text_tot, by = "url") %>% 
   select(url, text, pub_date, sectionName) %>% 
   mutate(text = str_remove_all(text, "[:punct:]")) %>% 
   filter(text != "") %>% 
   unnest_tokens(word, text) %>% 
   anti_join(stop_words) %>% 
   anti_join(mystopwords) %>% 
   mutate(stem = wordStem(word))

 save(full_biden_guardian, full_trump_guardian, file = "GuardianArticles.RData")   
 