#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( ( RANDOM % 1000 )  + 1 ))
echo -n "Enter your username: "
read USERNAME

USERDATA=$($PSQL "SELECT played, best_game FROM users WHERE username='$USERNAME'")
BEST=0
if [[ -z $USERDATA ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users (username, played, best_game) VALUES ('$USERNAME', 0, 0)" >/dev/null
  BEST=1000
else
  IFS='|' read PLAYED BEST <<< $USERDATA
  echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
fi
echo -n "Guess the secret number between 1 and 1000: "
NUM_GUESSES=0
while true; do
  read GUESS
  ((NUM_GUESSES=NUM_GUESSES+1))
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo -n "That is not an integer, guess again: "
  elif (( $GUESS > $NUMBER )); then
    echo -n "It's lower than that, guess again: "
  elif (( $GUESS < $NUMBER )); then
    echo -n "It's higher than that, guess again: "
  else
    # guessed, update stats and exit
    $PSQL "UPDATE users SET played=played+1, best_game=LEAST($BEST, $NUM_GUESSES) WHERE username = '$USERNAME'" >/dev/null
    echo "You guessed it in $NUM_GUESSES tries. The secret number was $NUMBER. Nice job!"
    break
  fi
done