library(tidyverse)

# Load datasets
teams <- read_csv("data/raw/MTeams.csv")
games <- read_csv("data/raw/MRegularSeasonDetailedResults.csv")
tourney <- read_csv("data/raw/MNCAATourneyDetailedResults.csv")
seeds <- read_csv("data/raw/MNCAATourneySeeds.csv")

# Quick look at structure
head(teams)
head(games)
head(tourney)
head(seeds)

# Summary stats
summary(games)
summary(seeds)

# Check date ranges
range(games$Season)
range(tourney$Season)

# Check for missing values
colSums(is.na(games))
colSums(is.na(tourney))