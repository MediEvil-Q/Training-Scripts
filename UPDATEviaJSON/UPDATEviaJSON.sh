#!/usr/bin/bash

db() {
	sudo -i -u postgres psql -d products -c "$1"
}

COUNT=$(db "SELECT * FROM default_schema.csv_import;" | tail -fn 3 | cut -d "|" -f 1 | sed '2d;$d')

for (( c=1; c<=$COUNT+1; c++ ))
do
	ean=$(db "SELECT * FROM default_schema.csv_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 3)
	ean=$(echo $ean | awk '{gsub(" ", ""); print $0}')
	price=$(db "SELECT * FROM default_schema.csv_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 4)
	price=$(echo $price | awk '{gsub(" ", ""); print $0}')
	in_stock=$(db "SELECT * FROM default_schema.csv_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 5)
	in_stock=$(echo $in_stock | awk '{gsub(" ", ""); print $0}')

	if [[ "$ean" = "(0rows)" ]]
	then
		continue
	else
		> /dev/null
	fi

	echo "Processing $ean..."

	wget -q -O temp_json https://stores-api.zakaz.ua/stores/48215614/products/search_old/?q=$ean

	new_price=$(cat temp_json | jq -r  '.results[0].price')
	new_price=$(echo -e "scale=2;var=$new_price;var/100" | bc -l)
	new_in_stock=$(cat temp_json | jq -r  '.results[0].in_stock')

	if [[ $new_price == 0 ]]
	then
		echo "Could not obtain item. Deleting..."
		db "DELETE FROM default_schema.csv_import WHERE id=$c;" > /dev/null
	else
		if [[ "$price" != "$new_price" ]]
		then
			echo -e "Price mismatch ($price != $new_price). Updating..."
			db "UPDATE default_schema.csv_import SET price = $new_price WHERE id=$c;" > /dev/null
		else
			> /dev/null
		fi

		if [[ "$in_stock" != "$new_in_stock" ]]
		then
			echo "Item out of stock. Updating..."
			db "UPDATE default_schema.csv_import SET in_stock = $new_in_stock WHERE id=$c;" > /dev/null
		else
			> /dev/null
		fi
	fi

	echo "-----"
	
done

db "SELECT * FROM default_schema.csv_import;"