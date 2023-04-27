#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n~~ Inserting teams ~~\n"
echo "$($PSQL "TRUNCATE teams, games")"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # get winner_id and opponent_id
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  
  # skip first line
  if [[ $YEAR != 'year' ]]
  then
    # if winner not found
    if [[ -z $WINNER_ID ]]
    then
      # insert team
      INSERT_TEAM_1=$($PSQL"INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_1 == 'INSERT 0 1' ]]
      then
        # print this instead of INSERT 0 1
        echo Inserted team: $WINNER
      fi
    fi

    # if OPPONENT not found
    if [[ -z $OPPONENT_ID ]]
    then
      # insert team
      INSERT_TEAM_2=$($PSQL"INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_2 == 'INSERT 0 1' ]]
      then
        # print this instead of INSERT 0 1
        echo Inserted team: $OPPONENT
      fi
    fi
  
    # get winner and opponent ids
    GAME_WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    GAME_OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"

    # insert values
    INSERT_GAME_ROW=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $GAME_WINNER_ID, $GAME_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_ROW == "INSERT 0 1" ]]
    then
      # print this instead of INSERT 0 1
      echo Inserted row in games table: $YEAR, $ROUND, $GAME_WINNER_ID, $GAME_OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS
    fi
  fi
done
