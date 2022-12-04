#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi
# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n~~Wait please, it might take some time~~\n"
echo "Checking current tables"
DROP_TABLES=$($PSQL "DROP TABLE IF EXISTS teams, games;")
CREATE_TABLES=$($PSQL "
  CREATE TABLE IF NOT EXISTS teams(team_id SERIAL, name VARCHAR(50) NOT NULL UNIQUE, PRIMARY KEY(team_id));
  CREATE TABLE IF NOT EXISTS games(game_id SERIAL, year INT NOT NULL, round VARCHAR(50) NOT NULL, winner_id INT NOT NULL CONSTRAINT winner_id REFERENCES teams(team_id), winner_goals INT NOT NULL, opponent_id INT NOT NULL CONSTRAINT opponent_id REFERENCES teams(team_id), opponent_goals INT NOT NULL, PRIMARY KEY(game_id));
")
echo "Parsing provided data"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT DO NOTHING")
  INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT DO NOTHING")
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  INSERT_GAME_INFORMATION=$($PSQL "INSERT INTO games(year, round, winner_id, winner_goals, opponent_id, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $WINNER_GOALS, $OPPONENT_ID, $OPPONENT_GOALS)")
done < <(tail -n +2 games.csv) # ignore title
echo -e "\n~~All data set~~\n"
