#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# svuota le tabelle prima del ciclo
TRUNCATE=$($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # evita di prendere la prima riga
  if [[ $YEAR != "year" ]]
  # carica la tabella teams con i nomi delle squadre senza ripetizioni
  then
    # controlla tramite id se la squadra già è nella tabella
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    # se non c'è la inserisce
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi
    # controlla tramite id se la squadra già è nella tabella
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # se non c'è la inserisce
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # carica la tabella games con gli altri dati
    INSERT_VALUES=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES('$YEAR', '$ROUND', '$WINNER_GOALS', '$OPPONENT_GOALS', '$W_ID', '$O_ID')")
  fi
done
