library(tidyverse)
library(lubridate)
library(rvest)

raw_matches <- read_html('https://www.hltv.org/matches?predefinedFilter=top_tier') %>%
  html_nodes(".upcomingMatch")


# create df's columns -----------------------------------------------------

# time
tbl_time <- raw_matches %>% html_nodes('a div .matchTime') %>% html_attr('data-unix') %>% 
  as.numeric() %>% `/`(1000) %>% as.POSIXct(origin='1970-01-01') %>% 
  as_datetime(tz='Europe/Amsterdam') %>% with_tz(tzone='America/Sao_Paulo')

# rating
tbl_rating <- raw_matches %>% html_nodes('a div .matchRating') %>% 
  map_int(~html_nodes(., '.fa-star:not(.faded)') %>% length())

# has_match
tbl_has_match <- is.na(raw_matches %>% 
                     html_node('.matchInfoEmpty') %>% html_text())

# team_1
tbl_team1 <- raw_matches %>% html_nodes('a div .team1') %>% html_text(trim=T)

# team_2
tbl_team2 <- raw_matches %>% html_nodes('a div .team2') %>% html_text(trim=T)

# event
tbl_event <- raw_matches %>% html_nodes('a div .matchEventName') %>% html_text(trim=T)

# if not team_1 team_2 event
tbl_match_type <- raw_matches %>% html_nodes('a div .line-clamp-3') %>% html_text()

# match_url
tbl_match_url <- raw_matches %>% html_nodes('a.match') %>% html_attr('href') %>% 
  paste0('https://www.hltv.org/', .)


# creates tibble ----------------------------------------------------------

matches <- tibble(datetime=tbl_time,
                  rating=tbl_rating,
                  has_match=tbl_has_match,
                  match_type=NA_character_,
                  team1=NA_character_,
                  team2=NA_character_,
                  event=NA_character_,
                  match_url=tbl_match_url)

# since there are partial information on some matches
# we need to treat them differently on joining data
matches[which(matches$has_match == TRUE),] <-
  matches[which(matches$has_match == TRUE),] %>% 
  mutate(team1=tbl_team1,
         team2=tbl_team2,
         event=tbl_event)

matches[which(matches$has_match == FALSE),] <-
  matches[which(matches$has_match == FALSE),] %>% 
  mutate(match_type=tbl_match_type)


# removes helper objects --------------------------------------------------

rm(raw_matches, tbl_event, tbl_has_match, tbl_match_type,
   tbl_match_url, tbl_rating, tbl_team1, tbl_team2, tbl_time)
