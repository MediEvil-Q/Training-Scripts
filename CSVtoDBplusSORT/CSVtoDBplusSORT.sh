#!/usr/bin/bash

db() {
	sudo -i -u postgres psql -d products -c "$1"
}

db "DROP TABLE default_schema.csv_import;" > /dev/null
db "CREATE TABLE default_schema.csv_import (id serial primary key, title text, ean text, price decimal, in_stock text);" > /dev/null

COUNT=$(cat inputCSV.csv | sed '1d;$d' | wc -l)

for (( c=2; c<=$COUNT+1; c++ ))
do
	title=$(cut -d "," -f 1 inputCSV.csv | sed -n $c\p)
	title=$(echo $title | awk '{gsub("'\''", ""); print $0}')
	ean=$(cut -d "," -f 2 inputCSV.csv | sed -n $c\p)
	price=$(cut -d "," -f 3 inputCSV.csv | sed -n $c\p)
	in_stock=$(cut -d "," -f 4 inputCSV.csv | sed -n $c\p)

	db "INSERT INTO default_schema.csv_import (title, ean, price, in_stock) VALUES ('$title', '$ean', $price, $in_stock);" > /dev/null
done

echo "5 Most Expensive Products"
db "SELECT * FROM default_schema.csv_import ORDER BY price DESC LIMIT 5;"

echo "5 Cheapest Products"
db "SELECT * FROM default_schema.csv_import ORDER BY price LIMIT 5;"

echo "All Products With \"metro\" In Their EAN"
db "SELECT * FROM default_schema.csv_import WHERE ean LIKE 'metro%' ORDER BY id;"