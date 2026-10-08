#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

set -e

 $PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE"

while IFS=, read -r year round winner opponent winner_goals opponent_goals; do
  $PSQL "WITH winner AS (
    INSERT INTO teams (name) VALUES ('$winner')
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING team_id
  ), opponent AS (
    INSERT INTO teams (name) VALUES ('$opponent')
    ON CONFLICT (name) DO UPDATE SET name = EXCLUDED.name
    RETURNING team_id
  )
  INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals)
  SELECT $year, '$round', winner.team_id, opponent.team_id, $winner_goals, $opponent_goals
  FROM winner CROSS JOIN opponent"
done < <(tail -n +2 "$(dirname "$0")/games.csv")
