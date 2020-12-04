#!/usr/bin/bash

db() {
        sudo -i -u postgres psql -d products -c "$1"
}

db "DROP TABLE default_schema.json_import;" > /dev/null
db "CREATE TABLE default_schema.json_import (id serial primary key, title text, ean text, price decimal, in_stock text);" > /dev/null

wget -q -O temp_json https://stores-api.zakaz.ua/stores/48215614/products/search_old/?q=Колбаса

START=0
END=$(grep -o -i title temp_json | wc -l)

for (( c=$START; c<=$END; c++ ))
do
        title=$(cat temp_json | jq -r --argjson i $c '.results[$i].title')
        ean=$(cat temp_json | jq -r --argjson i $c '.results[$i].ean')
        price=$(cat temp_json | jq -r --argjson i $c '.results[$i].price')
        price=$(echo -e "scale=2;var=$price;var/100" | bc -l)
        in_stock=$(cat temp_json | jq -r --argjson i $c '.results[$i].in_stock')
        if [[ $title != null ]]
        then
                db "INSERT INTO default_schema.json_import (title, ean, price, in_stock) VALUES ('$title', '$ean', $price, $in_stock);" > /dev/null
        else
                continue
        fi
done

rm temp_json

db "SELECT * FROM default_schema.json_import"

COUNT=$(db "SELECT * FROM default_schema.json_import;" | tail -fn 3 | cut -d "|" -f 1 | sed '2d;$d')

echo "title,ean,price,in_stock" > output.csv

for (( c=1; c<=$COUNT; c++ ))
do
        title=$(db "SELECT * FROM default_schema.json_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 2)
        ean=$(db "SELECT * FROM default_schema.json_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 3)
        price=$(db "SELECT * FROM default_schema.json_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 4)
        in_stock=$(db "SELECT * FROM default_schema.json_import WHERE id=$c;" | sed '1d;2d;4d;$d'  | cut -d "|" -f 5)
        echo "$title,$ean,$price,$in_stock" >> output.csv
done

echo "Count: $COUNT" >> output.csv

cat output.csv