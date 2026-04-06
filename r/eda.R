library(tidyverse)

#Datasets
season_stats <- read_csv("data/cleaned/season_stats.csv")
team_games <- read_csv("data/cleaned/team_games.csv")
seeds_clean <- read_csv("data/cleaned/seeds_clean.csv")
tourney <- read_csv("data/raw/MNCAATourneyDetailedResults.csv")

# Average key stats per season across all teams
windows()
trends <- season_stats %>%
  group_by(Season) %>%
  summarise(
    AvgFGPct = mean(AvgFGPct),
    AvgFG3Pct = mean(AvgFG3Pct, na.rm = TRUE),
    AvgFTPct = mean(AvgFTPct, na.rm = TRUE),
    AvgScore = mean(AvgScore),
    AvgReb = mean(AvgReb),
    AvgAst = mean(AvgAst),
    AvgTO = mean(AvgTO),
    AvgFGA3 = mean(AvgFGA3)
  )
# Plot each stat over time
trends_long <- trends %>%
  pivot_longer(cols = -Season, names_to = "Stat", values_to = "Value")

ggplot(trends_long, aes(x = Season, y = Value)) +
  geom_line(color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", color = "red") +
  facet_wrap(~ Stat, scales = "free_y") +
  labs(title = "NCAA Stat Trends Over Time (2003-2026)", x = "Season", y = "Value")


#question 2 how teams perform better if going into the tournament with a streak
#Team streakiness/momentum going into the tournament stat

#How many of the previous 10 has a team won
momentum <- team_games %>%
  arrange(Season, TeamID, DayNum) %>%
  group_by(Season, TeamID) %>%
  slice_tail(n = 10) %>%
  summarise(Last10WinPct = mean(Win), .groups = "drop")
#How far a team made it in the tournament
tourney_runs <- bind_rows(
  tourney %>% transmute(Season, TeamID = WTeamID, TourneyWin = 1),
  tourney %>% transmute(Season, TeamID = LTeamID, TourneyWin = 0)
) %>%
  group_by(Season, TeamID) %>%
  summarise(TourneyWins = sum(TourneyWin), .groups = "drop")

#Combine placing and momentum, also how a team that gets hot relative to their season record performs better
streak_data <- momentum %>%
  inner_join(season_stats %>% select(Season, TeamID, WinPct), by = c("Season", "TeamID")) %>%
  inner_join(tourney_runs, by = c("Season", "TeamID")) %>%
  inner_join(seeds_clean %>% select(Season, TeamID, SeedNum), by = c("Season", "TeamID")) %>%
  mutate(
    MomentumDelta = Last10WinPct - WinPct,
    ExpectedWins = (17 - SeedNum) / 16 * 6,  # rough expected wins based on seed
    TourneyOverperformance = TourneyWins - ExpectedWins
  )
head(streak_data)
windows()
ggplot(streak_data, aes(x = Last10WinPct, y = TourneyWins)) +
  geom_jitter(alpha = 0.3, height = 0.2) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Late Season Momentum vs Tournament Wins",
       x = "Last 10 Games Win %",
       y = "Tournament Wins")

windows()
ggplot(streak_data, aes(x = MomentumDelta, y = TourneyOverperformance)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "lm", color = "red") +
  labs(title = "Momentum vs Tournament Overperformance",
       x = "Momentum Delta (Last 10 - Season Win%)",
       y = "Tournament Wins Above Expected")
windows()
ggplot(streak_data, aes(x = MomentumDelta, y = TourneyOverperformance)) +
  geom_point(alpha = 0.3) +
  geom_smooth(method = "loess", color = "red") +
  labs(title = "Momentum vs Tournament Overperformance",
       x = "Momentum Delta (Last 10 - Season Win%)",
       y = "Tournament Wins Above Expected")


#Question 3
#How does seed correlate with wins in the tournament, simple fit model
upset_data <- tourney %>%
  inner_join(seeds_clean %>% select(Season, TeamID, SeedNum), by = c("WTeamID" = "TeamID", "Season")) %>%
  rename(WSeed = SeedNum) %>%
  inner_join(seeds_clean %>% select(Season, TeamID, SeedNum), by = c("LTeamID" = "TeamID", "Season")) %>%
  rename(LSeed = SeedNum) %>%
  mutate(Upset = WSeed > LSeed)

windows()
upset_data %>%
  group_by(LSeed) %>%
  summarise(UpsetRate = mean(Upset), Games = n()) %>%
  ggplot(aes(x = LSeed, y = UpsetRate)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "red") +
  labs(title = "Upset Rate by Favored Seed", 
       x = "Favored Team Seed", 
       y = "% of Games Lost (Upset Rate)")

windows()
seeds_clean %>%
  inner_join(tourney_runs, by = c("Season", "TeamID")) %>%
  group_by(SeedNum) %>%
  summarise(AvgTourneyWins = mean(TourneyWins)) %>%
  ggplot(aes(x = SeedNum, y = AvgTourneyWins)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Average Tournament Wins by Seed",
       x = "Seed",
       y = "Average Tournament Wins")

#Winnignest teams since 2003
windows()
team_tourney_avg <- tourney_runs %>%
  inner_join(teams %>% select(TeamID, TeamName), by = "TeamID") %>%
  group_by(TeamName) %>%
  summarise(
    Appearances = n(),
    AvgTourneyWins = mean(TourneyWins)
  ) %>%
  filter(Appearances >= 10) %>%  # only teams with enough appearances to be meaningful
  arrange(desc(AvgTourneyWins)) %>%
  slice_head(n = 20)

ggplot(team_tourney_avg, aes(x = reorder(TeamName, AvgTourneyWins), y = AvgTourneyWins)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Top 20 Teams by Average Tournament Wins (Min 10 Appearances)",
       x = "Team", y = "Average Tournament Wins")
