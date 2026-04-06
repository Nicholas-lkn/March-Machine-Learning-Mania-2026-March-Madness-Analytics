library(DBI)
library(RSQLite)
library(tidyverse)

# Load cleaned data
season_stats <- read_csv("data/cleaned/season_stats.csv")
team_games <- read_csv("data/cleaned/team_games.csv")
seeds_clean <- read_csv("data/cleaned/seeds_clean.csv")

# Create database connection
con <- dbConnect(RSQLite::SQLite(), "data/march_madness.db")

# Write tables
dbWriteTable(con, "season_stats", season_stats, overwrite = TRUE)
dbWriteTable(con, "team_games", team_games, overwrite = TRUE)
dbWriteTable(con, "seeds_clean", seeds_clean, overwrite = TRUE)

# Verify
dbListTables(con)
dbGetQuery(con, "SELECT * FROM season_stats LIMIT 5")

dbDisconnect(con)