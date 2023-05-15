#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Truncate all table
TRUNCATE_RESULT=$($PSQL"TRUNCATE teams RESTART IDENTITY CASCADE;")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    # Look for winner team name
    WINNER_QUERY_RESULT=$($PSQL"SELECT team_id FROM teams WHERE name = '$WINNER'")

    # If winner name not exist
    if [[ -z $WINNER_QUERY_RESULT ]]
    then

      # Add winner in teams
      INSERT_WINNER_RESULT=$($PSQL"INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT = "INSERT 0 1" ]]
      then
        echo "Team $WINNER inserted into teams"
      fi
      WINNER_QUERY_RESULT=$($PSQL"SELECT team_id FROM teams WHERE name = '$WINNER'")
    fi

    # Look for opponent team name
    OPPONENT_QUERY_RESULT=$($PSQL"SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    # If opponent name not exist
    if [[ -z $OPPONENT_QUERY_RESULT ]]
    then

      # Add opponent in teams
      INSERT_OPPONENT_RESULT=$($PSQL"INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT = "INSERT 0 1" ]]
      then
        echo "Team $OPPONENT inserted into teams"
      fi
      OPPONENT_QUERY_RESULT=$($PSQL"SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    fi

    # Add game in games
    INSERT_GAME_RESULT=$($PSQL"INSERT INTO games(year,round,\
    winner_id,\
    opponent_id,\
    winner_goals,\
    opponent_goals) \
    VALUES($YEAR, \
    '$ROUND', \
    $WINNER_QUERY_RESULT, \
    $OPPONENT_QUERY_RESULT, \
    $WINNER_GOALS, \
    $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
    then
      echo "$ROUND game in $YEAR inserted into games"
    fi
  fi
done