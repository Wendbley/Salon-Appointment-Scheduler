#! /bin/bash


PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only  -c"

# Application title/name
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

echo -e "\n\nWelcome to JFK Salon\n"

# Main function
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")

  # if no services available
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    # send to main menu
    MAIN_MENU "Sorry, we don't have any services available right now."
  else
    # echo -e "\nHere are the services we have available:"
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo -e "$SERVICE_ID) $NAME"
    done
  fi

  # present the menu and allow the user to enter their choice
  echo -e "\nSelect: "
  read SERVICE_ID_SELECTED

  # if menu selection isn't a number or any of this set (0-3)
  if [[ ! $(( SERVICE_ID_SELECTED - 1 )) =~ ^[0-9]$ ]]
  then
    MAIN_MENU "Please enter a valid option"
  else

    # get customer phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # get the customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if phone number doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # get customer name
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      # store new customer (phone number,name) into customer table
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    fi

    # check if new customer - get his customer_id
    if [[ -z $CUSTOMER_ID ]] 
    then
      # get the customer ID
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # check if customer in database - get his customer_name
    if [[ -z $CUSTOMER_NAME ]] 
    then
      # get the customer name
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # get service name - appointment
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

    # get service time - appointment
    echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ //'), $(echo $CUSTOMER_NAME | sed 's/^ //')?"
    read SERVICE_TIME

    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # store new appointment (service_id,customer_id,time) into appointments table
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(service_id, customer_id, time) VALUES($SERVICE_ID_SELECTED,$CUSTOMER_ID,'$SERVICE_TIME')")

    # Formatted Output
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ //')."
  fi
}


MAIN_MENU

 