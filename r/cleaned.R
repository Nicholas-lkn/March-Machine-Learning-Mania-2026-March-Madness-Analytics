library(tidyverse)

teams <- read_csv("data/raw/MTeams.csv")
games <- read_csv("data/raw/MRegularSeasonDetailedResults.csv")
tourney <- read_csv("data/raw/MNCAATourneyDetailedResults.csv")
seeds <- read_csv("data/raw/MNCAATourneySeeds.csv")

# Extract numeric seed (strip region letter and play-in suffix)
seeds_clean <- seeds %>%
  mutate(SeedNum = as.integer(str_extract(Seed, "\\d+")))

# Join team names onto tourney results
tourney_named <- tourney %>%
  left_join(teams %>% select(TeamID, TeamName), by = c("WTeamID" = "TeamID")) %>%
  rename(WTeamName = TeamName) %>%
  left_join(teams %>% select(TeamID, TeamName), by = c("LTeamID" = "TeamID")) %>%
  rename(LTeamName = TeamName)

head(seeds_clean)
head(tourney_named)

# Reshape games so each row is one team's performance in one game
winner_stats <- games %>%
  transmute(
    Season, DayNum, TeamID = WTeamID, OpponentID = LTeamID, Win = 1,
    Score = WScore, OppScore = LScore, Loc = WLoc,
    FGM = WFGM, FGA = WFGA, FGM3 = WFGM3, FGA3 = WFGA3,
    FTM = WFTM, FTA = WFTA, OR = WOR, DR = WDR,
    Ast = WAst, TO = WTO, Stl = WStl, Blk = WBlk, PF = WPF
  )

loser_stats <- games %>%
  transmute(
    Season, DayNum, TeamID = LTeamID, OpponentID = WTeamID, Win = 0,
    Score = LScore, OppScore = WScore, Loc = case_when(WLoc == "H" ~ "A", WLoc == "A" ~ "H", TRUE ~ "N"),
    FGM = LFGM, FGA = LFGA, FGM3 = LFGM3, FGA3 = LFGA3,
    FTM = LFTM, FTA = LFTA, OR = LOR, DR = LDR,
    Ast = LAst, TO = LTO, Stl = LStl, Blk = LBlk, PF = LPF
  )

team_games <- bind_rows(winner_stats, loser_stats) %>%
  mutate(
    PointDiff = Score - OppScore,
    FGPct = FGM / FGA,
    FG3Pct = FGM3 / FGA3,
    FTPct = FTM / FTA,
    TotalReb = OR + DR
  )

head(team_games)

#group by season
season_stats <- team_games %>%
  group_by(Season, TeamID) %>%
  summarise(
    Games = n(),
    Wins = sum(Win),
    Losses = sum(1 - Win),
    WinPct = Wins / Games,
    AvgScore = mean(Score),
    AvgOppScore = mean(OppScore),
    AvgPointDiff = mean(PointDiff),
    AvgFGA3 = mean(FGA3),
    AvgFGPct = mean(FGPct),
    AvgFG3Pct = mean(FG3Pct, na.rm = TRUE),
    AvgFTPct = mean(FTPct, na.rm = TRUE),
    AvgReb = mean(TotalReb),
    AvgAst = mean(Ast),
    AvgTO = mean(TO),
    AvgStl = mean(Stl),
    AvgBlk = mean(Blk),
    .groups = "drop"
  ) %>%
  left_join(teams %>% select(TeamID, TeamName), by = "TeamID")


head(season_stats)
#Create Data Dictionary
data_dict <- data.frame(
  Field = c("TeamID", "Season", "WinPct", "AvgPointDiff", "AvgFGPct", 
            "AvgFG3Pct", "AvgFTPct", "AvgReb", "AvgAst", "AvgTO", 
            "AvgStl", "AvgBlk", "SeedNum", "Last10WinPct", "MomentumDelta"),
  Type = c("int", "int", "float", "float", "float", "float", "float",
           "float", "float", "float", "float", "float", "int", "float", "float"),
  Description = c(
    "Unique team identifier",
    "Academic year of the season",
    "Wins divided by total games played",
    "Average scoring margin per game",
    "Average field goal percentage per game",
    "Average three-point percentage per game",
    "Average free throw percentage per game",
    "Average total rebounds per game",
    "Average assists per game",
    "Average turnovers per game",
    "Average steals per game",
    "Average blocks per game",
    "Tournament seed number (1-16)",
    "Win percentage in last 10 regular season games",
    "Last10WinPct minus season WinPct (momentum relative to season average)"
  ),
  Source = c(
    "MTeams.csv", "Raw data", "Derived: Wins/Games", 
    "Derived: Score - OppScore", "Derived: FGM/FGA",
    "Derived: FGM3/FGA3", "Derived: FTM/FTA",
    "Derived: OR + DR", "Raw", "Raw", "Raw", "Raw",
    "Derived from MNCAATourneySeeds.csv",
    "Derived: mean(Win) last 10 games",
    "Derived: Last10WinPct - WinPct"
  )
)

write_csv(data_dict, "data/cleaned/data_dictionary.csv")
write_csv(season_stats, "data/cleaned/season_stats.csv")
write_csv(seeds_clean, "data/cleaned/seeds_clean.csv")
write_csv(team_games, "data/cleaned/team_games.csv")