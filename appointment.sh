#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Mo's Clinic ~~~\n"
echo -e "Thank you for choosing Mo's, which service would you like to book?\n"

MAIN_MENU() {
  # Display prompt for return to main menu
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi

# Get list of services
SERVICE_MENU=$($PSQL "SELECT service_id, name FROM services ORDER BY SERVICE_ID")
# Display list of services
echo "$SERVICE_MENU" | while read SERVICE_ID BAR SERVICE_NAME
do
echo "$SERVICE_ID) $SERVICE_NAME"
done
# Static option for exiting script
echo "0) Exit"

# Get selected service
read SERVICE_ID_SELECTED
# If input is not only a 0 or positive integer
if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
# Prompt to enter only a number
MAIN_MENU "Please type in only the number of the desired service."
fi

# Match selected service to service table
SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")

# If service not found, prompt to choose correct service
if [[ -z $SERVICE_ID ]] && [[ $SERVICE_ID_SELECTED != 0 ]]
then
MAIN_MENU "That is not a service we offer, please choose from the service list below"

# Or if input is 0, exit script
  elif [[ $SERVICE_ID_SELECTED == 0 ]]
  then
  EXIT
# If service is found, send service_id to booking menu as argument  
  else
  BOOKING_MENU "$SERVICE_ID_SELECTED"
fi
}

BOOKING_MENU() {
# Get corresponding service name to the choosen service
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
# Display to user the chosen service's name
if [[ $1 ]]
then
echo -e "\nYou selected to make a booking for$SERVICE_NAME"
fi

# Prompt for user's phone
echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE

# Search for user's phone in customer table
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

# If new user (phone does not have a corresponding name) 
if [[ -z $CUSTOMER_NAME ]]
then

# Prompt user to enter name
echo -e "\nI don't have a record for that phone number, what is your name?"
read CUSTOMER_NAME

# Insert user's name and phone into customer table
INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

fi

# Prompt user to enter appointment time
echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

# Get user's customer_id from their phone
SELECT_CUSTOMER=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Enter user's appointment 
INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, service_id, customer_id) VALUES('$SERVICE_TIME', $SERVICE_ID_SELECTED, $SELECT_CUSTOMER)")

# Appointment confirmation
echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

EXIT() {
  echo -e "\nThank you for stopping in."
}

MAIN_MENU
