#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

set -e
# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")
#echo $($PSQL "CREATE TABLE teams (team_id SERIAL PRIMARY KEY, name VARCHAR(20) NOT NULL UNIQUE)")
#echo $($PSQL "CREATE TABLE games (game_id SERIAL PRIMARY KEY,\
#  year INT NOT NULL, round VARCHAR(20) NOT NULL,\
#  winner_id INT NOT NULL, opponent_id INT NOT NULL,\
#  winner_goals INT NOT NULL, opponent_goals INT NOT NULL)")
echo $($PSQL "ALTER TABLE games ADD FOREIGN KEY(winner_id) REFERENCES teams(team_id)")
echo $($PSQL "ALTER TABLE games ADD FOREIGN KEY(opponent_id) REFERENCES teams(team_id)")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WG OG; do
  if [[ $YEAR != year ]]; then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [ -z $WINNER_ID ]; then
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')"
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    if [ -z $OPP_ID ]; then
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')"
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi
    $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)\
      VALUES($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $WG, $OG)"
  fi
done

