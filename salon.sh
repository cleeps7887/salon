#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Chris' Barber Shop ~~~\n"

echo -e "\nPlease select a service by inputting the corresponding number below and hit enter:\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #while loop to print formatted service list
  echo "$SERVICE_LIST" | while read SERVICE_ID BAR NAME
  do
    SERVICE_NAME_FORMATTED=$(echo $NAME | sed 's/_/ /g')
    echo -e "$SERVICE_ID) $SERVICE_NAME_FORMATTED"
  done
  read SERVICE_ID_SELECTED
  #check if service ID is valid
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service selection"
  else
    VALID_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $VALID_SERVICE ]]
    then
      MAIN_MENU "That is not a valid service selection"
    else
      echo -e "\nPlease enter your phone number:\n"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      #if customer does not exist
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWhat's your name?\n"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
        
        echo -e "\nYou have been added to our customer database, $CUSTOMER_NAME"
      fi
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nWhat time would you like to book in at?"
      read SERVICE_TIME
      INSERT_APPT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/_/ /g')

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME_FORMATTED | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

    fi
  fi


}

BOOK_APPT() {
  echo "book appt placeholder"
}

MAIN_MENU