#!/usr/bin/bash
source config

SQL_ALL_DATA="SELECT * FROM "$DB_TABLE""

execute_sql() {
  local SQL_QUERY="$1"
	result=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -c "$SQL_QUERY")
}

execute_sql "$SQL_ALL_DATA"




#исключаем первых две и последнюю строки из result
echo "$result" | awk 'FNR>2' | sed '$d' |
while read LINE
do
	phone=$(echo "$LINE" | awk -F'|' '{print $2}')
	pass=$(echo "$LINE" | awk -F'|' '{print $3}')
  api_id=$(echo "$LINE" | awk -F'|' '{print $4}')
  api_hash=$(echo "$LINE" | awk -F'|' '{print $5}')



# Відправлення запиту на отримання коду підтвердження
CODE_REQUEST=$(curl -s -X POST "https://my.telegram.org/auth/send_password" -d "phone=$phone&api_id=$api_id&api_hash=$api_hash")

CODE=$(echo $CODE_REQUEST | jq -r '.random_id')





# Введення коду підтвердження
read -p "Введіть код підтвердження: " AUTH_CODE


AUTH_RESPONSE=$(curl -s -X POST "https://my.telegram.org/auth/login" \
  -d "phone=$phone" \
  -d "random_id=$CODE" \
  -d "password=$AUTH_CODE" \
  -d "api_id=$api_id" \
  -d "api_hash=$api_hash")

# Відправлення запиту на авторизацію
#AUTH_RESPONSE=$(curl -s -X POST "https://my.telegram.org/auth/login" -d "phone=$phone&random_id=$CODE&password=$AUTH_CODE")

# Вивід результату авторизації
echo $AUTH_RESPONSE




done










## Замініть на власні дані API
#API_ID="ваш_api_id"
#API_HASH="ваш_api_hash"
#
## Введення номеру телефону
#read -p "Введіть свій номер телефону (у форматі +380123456789): " PHONE_NUMBER
#
## Відправлення запиту на отримання коду підтвердження
#CODE_REQUEST=$(curl -s -X POST "https://my.telegram.org/auth/send_password" -d "phone=$PHONE_NUMBER&api_id=$API_ID&api_hash=$API_HASH")
#
## Отримання коду з відповіді
#CODE=$(echo $CODE_REQUEST | jq -r '.random_id')
#
## Введення коду підтвердження
#read -p "Введіть код підтвердження: " AUTH_CODE
#
## Відправлення запиту на авторизацію
#AUTH_RESPONSE=$(curl -s -X POST "https://my.telegram.org/auth/login" -d "phone=$PHONE_NUMBER&random_id=$CODE&password=$AUTH_CODE")
#
## Вивід результату авторизації
#echo $AUTH_RESPONSE




