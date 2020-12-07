#!/usr/bin/bash

db() {
	sudo -i -u postgres psql -d products -c "$1"
}

COUNT=$(db "SELECT * FROM default_schema.csv_import;" | tail -fn 3 | cut -d "|" -f 1 | sed '2d;$d')

for (( c=1; c<=$COUNT+1; c++ ))
do
	ean=$(db "SELECT * FROM default_schema.csv_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 3)
	ean=$(echo $ean | awk '{gsub(" ", ""); print $0}')

	wget -q -O temp_json https://stores-api.zakaz.ua/stores/48215614/products/search_old/?q=$ean

	new_price=$(cat temp_json | jq -r  '.results[0].price')
	new_price=$(echo -e "scale=2;var=$new_price;var/100" | bc -l)

	db "UPDATE default_schema.csv_import SET price = $new_price WHERE id=$c;" > /dev/null
done

db "SELECT * FROM default_schema.csv_import ORDER BY id;"