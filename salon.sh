#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon de Belleza Xanadu ~~~~~\n"
echo -e "Welcome to Xanadu, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  AVAILABLE_SERVICES="$($PSQL "SELECT service_id, name FROM services ORDER by service_id")"
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  # get service name
  SERVICE_NAME="$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")"
  
  # if incorrect service_id
  if [[ -z $SERVICE_NAME ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    SERVICE_ID=$SERVICE_ID_SELECTED
    MAKE_APPOINTMENT
  fi
}

MAKE_APPOINTMENT() {
  # get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # if customer doesn't exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    # get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_NAME_FORMATED=$(echo $SERVICE_NAME | sed -r 's/^ *| *$//g')
  CUSTOMER_NAME_FORMATED=$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')
  
  # get time of appointment
  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATED, $CUSTOMER_NAME_FORMATED?"
  read SERVICE_TIME

  # insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATED."
}

MAIN_MENU
