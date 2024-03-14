#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM users INNER JOIN games USING(user_id) WHERE username = '$USERNAME'")

MAIN() {
  if [[ -z $USER ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  else
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." | sed 's/ \+/ /g'
  fi
  SECRET_NUMBER=$(( RANDOM % 1000 + 1)) 
  ATTEMPTS=0
  GUESS_GAME "Guess the secret number between 1 and 1000:"
}

GUESS_GAME(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  read GUESS
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    GUESS_GAME "That is not an integer, guess again:"
  else
    (( ATTEMPTS++ ))
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      GUESS_GAME "It's lower than that, guess again:"
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      GUESS_GAME "It's higher than that, guess again:"
    else
      echo "You guessed it in $ATTEMPTS tries. The secret number was $SECRET_NUMBER. Nice job!"
    fi
  fi
}

MAIN

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(guesses, user_id) VALUES($ATTEMPTS, $USER_ID)")