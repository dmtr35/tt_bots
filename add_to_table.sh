#!/usr/bin/bash  
source config

SQL_DELETE="DELETE FROM $DB_TABLE"
SQL_ALL_DATA="SELECT * FROM "$DB_TABLE""

#функция обращения к базе
execute_sql() {
  local SQL_QUERY="$1"
  PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -c "$SQL_QUERY"
}

#удаление данных из базы перед записью
execute_sql "$SQL_DELETE"


#цикл для добавления строк из файла с юзерами в базу
while read -r LINE
do
	phone=$(echo "$LINE" | cut -d' ' -f1)

	user_exists=$(PGPASSWORD="$DB_PASSWORD" psql -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -U "$DB_USER" -t -c "SELECT COUNT(*) FROM "$DB_TABLE" WHERE phone='$phone'")
	if [ "$user_exists" -gt 0 ]; then
	echo "Користувач з номером $phone вже існує в таблиці."
	continue
	fi

	pass=$(echo "$LINE" | cut -d' ' -f2)
	api_id=$(echo "$LINE" | cut -d' ' -f3)
	api_hash=$(echo "$LINE" | cut -d' ' -f4)
	activity=$(echo "$LINE" | cut -d' ' -f5)
	telegram_link=$(echo "$LINE" | cut -d' ' -f6)

	SQL_QUERY_CREATE_USER="INSERT INTO "$DB_TABLE" (phone, pass, api_id, api_hash, activity, telegram_link) VALUES ('$phone', '$pass', '$api_id', '$api_hash', '$activity', '$telegram_link')"

	execute_sql "$SQL_QUERY_CREATE_USER"

done < "/home/a3/project/tt_bots/users_data.txt"



execute_sql "$SQL_ALL_DATA"









