#!/usr/bin/bash

db() {
        sudo -i -u postgres psql -d products -c "$1"
}

DocRoot="/var/www/html"

rm $DocRoot/index.html
touch $DocRoot/index.html

echo -e "<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
table {
        font-family: arial, sans-serif;
        border-collapse: collapse;
        width: 100%;
}

td, th {
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
}

tr:nth-child(even) {
        background-color: #dddddd;
}
</style>
</head>" > $DocRoot/index.html

echo "<body>
<h2>5 Most Expensive Products</h2>" >> $DocRoot/index.html

echo -e "<table>
        <tr>
                <th>Title</th>
                <th>EAN</th>
                <th>Price</th>
                <th>In Stock</th>
        </tr>" >> $DocRoot/index.html

for (( c=3; c<=7; c++ ))
do
        title=$(db "SELECT * FROM default_schema.csv_import ORDER BY price DESC LIMIT 5;" | sed -n $c\p | cut -d "|" -f 2)
        ean=$(db "SELECT * FROM default_schema.csv_import ORDER BY price DESC LIMIT 5;" | sed -n $c\p | cut -d "|" -f 3)
        price=$(db "SELECT * FROM default_schema.csv_import ORDER BY price DESC LIMIT 5;" | sed -n $c\p | cut -d "|" -f 4)
        in_stock=$(db "SELECT * FROM default_schema.csv_import ORDER BY price DESC LIMIT 5;" | sed -n $c\p | cut -d "|" -f 5)

        echo -e "\t<tr>
                <th>$title</th>
                <th>$ean</th>
                <th>$price</th>
                <th>$in_stock</th>
        </tr>" >> $DocRoot/index.html
done

echo "</table>" >> $DocRoot/index.html

#-------------------------------------------------------------

echo "<h2>5 Cheapest Products</h2>" >> $DocRoot/index.html

echo -e "<table>
        <tr>
                <th>Title</th>
                <th>EAN</th>
                <th>Price</th>
                <th>In Stock</th>
        </tr>" >> $DocRoot/index.html

for (( c=3; c<=7; c++ ))
do
        title=$(db "SELECT * FROM default_schema.csv_import ORDER BY price LIMIT 5;" | sed -n $c\p | cut -d "|" -f 2)
        ean=$(db "SELECT * FROM default_schema.csv_import ORDER BY price LIMIT 5;" | sed -n $c\p | cut -d "|" -f 3)
        price=$(db "SELECT * FROM default_schema.csv_import ORDER BY price LIMIT 5;" | sed -n $c\p | cut -d "|" -f 4)
        in_stock=$(db "SELECT * FROM default_schema.csv_import ORDER BY price LIMIT 5;" | sed -n $c\p | cut -d "|" -f 5)

        echo -e "\t<tr>
                <th>$title</th>
                <th>$ean</th>
                <th>$price</th>
                <th>$in_stock</th>
        </tr>" >> $DocRoot/index.html
done

echo "</table>" >> $DocRoot/index.html

#-------------------------------------------------------------

echo "<h2>All Products With \"metro\" In Their EAN</h2>" >> $DocRoot/index.html

echo -e "<table>
        <tr>
                <th>Title</th>
                <th>EAN</th>
                <th>Price</th>
                <th>In Stock</th>
        </tr>" >> $DocRoot/index.html

COUNT=$(db "SELECT * FROM default_schema.csv_import WHERE ean LIKE 'metro%' ORDER BY id;" | wc -l)

for (( c=3; c<=$COUNT-2; c++ ))
do
        title=$(db "SELECT * FROM default_schema.csv_import WHERE ean LIKE 'metro%' ORDER BY id;" | sed -n $c\p | cut -d "|" -f 2)
        ean=$(db "SELECT * FROM default_schema.csv_import WHERE ean LIKE 'metro%' ORDER BY id;" | sed -n $c\p | cut -d "|" -f 3)
        price=$(db "SELECT * FROM default_schema.csv_import WHERE ean LIKE 'metro%' ORDER BY id;" | sed -n $c\p | cut -d "|" -f 4)
        in_stock=$(db "SELECT * FROM default_schema.csv_import WHERE ean LIKE 'metro%' ORDER BY id;" | sed -n $c\p | cut -d "|" -f 5)

        echo -e "\t<tr>
                <th>$title</th>
                <th>$ean</th>
                <th>$price</th>
                <th>$in_stock</th>
        </tr>" >> $DocRoot/index.html
done

echo "</table>" >> $DocRoot/index.html

echo -e "<br>(c) 2020 Andrey Sokolov. Last updated: $(date +%c)
</body>
</html>" >> $DocRoot/index.html