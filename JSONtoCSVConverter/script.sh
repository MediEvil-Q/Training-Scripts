#!/usr/bin/bash

startTime=$(date +%s)

touch "$(date +"%d-%m-%Y_%T").log"
logFile="$(ls *.log --sort=time | cut -d " " -f 1,2 | sed -n 1p)"

# Log Start
echo -e "~~~ BEGIN ~~~\n
Date/Time: $(date +"%d-%m-%Y_%T")\n"  | tee $logFile

echo -e "Fetching JSON data...\n" | tee -a $logFile
wget -q -O temp_json https://stores-api.zakaz.ua/stores/48215614/products/search_old/?q=Колбаса

START=0
END=$(grep -o -i title temp_json | wc -l)
COUNT=0

#Log Injection
echo -e "Creating CSV files...\n" | tee -a $logFile

echo -e "name,ean,price,in_stock" > output.csv
echo -e "name,ean,price,in_stock" > outputMetro.csv

for (( c=$START; c<=$END; c++ ))
do
	title=$(cat temp_json | jq -r --argjson i $c '.results[$i].title')
	ean=$(cat temp_json | jq -r --argjson i $c '.results[$i].ean')
	price=$(cat temp_json | jq -r --argjson i $c '.results[$i].price')
	price=$(echo -e "scale=2;var=$price;var/100" | bc -l)
	in_stock=$(cat temp_json | jq -r --argjson i $c '.results[$i].in_stock')
	if [[ $title != null ]]
	then
		#Log Injection
		echo -e "Fetched:
Name:\t\t$title
EAN:\t\t$ean
Price:\t\t$price
InStock:\t$in_stock\n
Saving to output.csv... "  | tee -a $logFile

		echo -e "$title,$ean,$price,$in_stock" >> output.csv
		COUNT=$(($COUNT+1))

		# Log Injection
		echo -e "Done!\n\n~~~~~\n" | tee -a $logFile
	else
		continue
	fi
done

rm temp_json

echo -e "Count: $COUNT" >> output.csv

# Log Injection
echo -e "Separating Metro-branded products to outputMetro.csv...\n" | tee -a $logFile

grep Metro output.csv >> outputMetro.csv
COUNT_METRO=`grep Metro output.csv | wc -l`
echo -e "Count: $COUNT_METRO" >> outputMetro.csv

endTime=$(date +%s)

# Log Injection
echo -e "Task finished!
Script was running for $(($endTime-$startTime)) seconds!\n\n~~~ END ~~~"  | tee -a $logFile
