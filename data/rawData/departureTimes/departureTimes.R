departureTimes <- tribble(~"TIMEID", ~"desc", ~"timeStamp",
                          "1", "Monday at 8am", "2025-03-31 08:00:00",
                          "2", "Wednesday at 12pm", "2025-04-26 12:00:00",
                          "3", "Friday at 5pm", "2025-04-04 17:00:00",
                          "4", "Saturday at 1am", "2025-04-05 01:00:00",  
                          "5", "Sunday at 11am", "2025-04-06 11:00:00")

write_csv(departureTimes, "data/rawData/departureTimes/departureTimes.csv")
