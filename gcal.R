source('scraping.R')

# more information about Google Calendar importing: https://support.google.com/calendar/answer/37118

gcal <- matches %>%
  mutate(gcal_title=ifelse(has_match == T,
                           paste0(team1, ' x ', team2, ' (★', rating, '/5)'),
                           match_type),
         gcal_start_date=format(datetime, "%D"),
         gcal_start_time=format(datetime, '%R'),
         gcal_end_date=format(datetime + 60 * 90, "%D"),
         gcal_end_time=format(datetime + 60 * 90, '%R'),
         gcal_desc=paste0('https://www.twitch.tv/gaules\nhttps://www.twitch.tv/esl_csgo\n\n', match_url),
         gcal_all_day_event='False', gcal_private='False',
         gcal_location=ifelse(is.na(match_type), event,
                              'TBD')) %>% select(starts_with('gcal_')) %>% 
  select(Subject=gcal_title,
         `Start Date`=gcal_start_date,
         `Start Time`=gcal_start_time,
         `End Date`=gcal_end_date,
         `End Time`=gcal_end_time,
         `All Day Event`=gcal_all_day_event,
         Description=gcal_desc,
         Location=gcal_location,
         Private=gcal_private) %>% write_csv('data/gcal.csv')
