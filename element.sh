#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table --no-align --tuples-only -c"

if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi

ELT=''
if [[ $(echo $1 | grep -E '[^0-9]') ]]; then
  ELT=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius\
             FROM elements LEFT JOIN properties USING (atomic_number)\
             LEFT JOIN types USING (type_id)\
             WHERE symbol='$1' or name='$1'")
else
  ELT=$($PSQL "SELECT atomic_number, symbol, name, type, atomic_mass, melting_point_celsius, boiling_point_celsius\
             FROM elements LEFT JOIN properties USING (atomic_number)\
             LEFT JOIN types USING (type_id)\
             WHERE atomic_number=$1")
fi

if [[ -z $ELT ]]; then
  echo "I could not find that element in the database."
  exit
fi
echo $ELT | while IFS='|' read NUMBER SYMBOL NAME TYPE MASS MP BP; do
  echo -n "The element with atomic number $NUMBER is $NAME ($SYMBOL). "
  echo -n "It's a $TYPE, with a mass of $MASS amu. "
  echo "$NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
done