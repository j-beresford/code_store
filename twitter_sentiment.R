rm(list=ls())

library(dplyr)
library(tidyverse)
library(ggplot2)
library(rtweet)
library(stringr)
library(tidytext)

print("My API Key: AIzaSyCcok9qz5FgMzDZ_fBtzq-AMcsrZkNmvVU")

## search for 10000 tweets using the rstats hashtag
rt <- search_tweets(
  "#furlough", n = 18000, include_rts = FALSE
)


t<-rt%>%
  select(user_id, created_at, text)

pattern <- "([^A-Za-z\\d#@']|'(?![A-Za-z\\d#@]))"

tweet_words <- t %>% 
  mutate(text = str_replace_all(text, "https://t.co/[A-Za-z\\d]+|&amp;", ""))  %>%
  unnest_tokens(word, text, token = "regex", pattern = pattern)%>%
  filter(!word %in% stop_words$word & !str_detect(word, "^\\d+$")) %>%
  mutate(word = str_replace(word, "^'", ""))

tweet_words %>% 
  count(word) %>%
  arrange(desc(n))

afinn<-get_sentiments("afinn")

tweet_words<-tweet_words %>% 
  inner_join(afinn, by = "word")%>%
  mutate(created_at=as.Date(created_at))

tweet_words<-tweet_words%>%
  group_by(created_at)%>%
  mutate(avg_sentiment=mean(value))



tweet_words%>%ggplot(aes(created_at, avg_sentiment))+geom_line()+theme_minimal()
