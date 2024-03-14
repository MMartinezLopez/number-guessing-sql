#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
R_NUM=$((1 + $RANDOM % 1000))
GUESSES=1
echo "The random is $R_NUM"
echo "Enter your username:"
read USERNAME
GET_USER=$($PSQL "SELECT username FROM usernames WHERE username='$USERNAME';")
#if username is not in db
if [[ -z $GET_USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
#if it is
  GAMES_PLAYED=$($PSQL "SELECT games FROM usernames WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT bestgame FROM usernames WHERE username='$USERNAME';")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done
while [ $GUESS != $R_NUM ]
do
  if [[ $GUESS < $R_NUM ]]
  then
    echo "It's higher than that, guess again:"
    ((GUESSES++))
    read GUESS
  else
    echo "It's lower than that, guess again:"
    ((GUESSES++))
    read GUESS
  fi
done
echo "You guessed it in $GUESSES tries. The secret number was $R_NUM. Nice job!"

if [[ -z $GET_USER ]]
then 
  INSERT_USER=$($PSQL "INSERT INTO usernames(username, games, bestgame) VALUES('$USERNAME', 1, $GUESSES);")
else
  GAMES=$((GAMES_PLAYED+1))
  if [[ $GUESSES -lt $BEST_GAME ]]
  then
    BEST=$GUESSES
  else
    BEST=$BEST_GAME
  fi
  UPDATE_USER=$($PSQL "UPDATE usernames SET games=$GAMES, bestgame=$BEST WHERE username='$USERNAME';")
fi