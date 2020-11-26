#!/usr/bin/bash

startTime=$(date +%s)

touch "$(date +"%d-%m-%Y_%T").log"
logFile="$(ls *.log --sort=time | cut -d " " -f 1,2 | sed -n 1p)"

# Log Start
echo -e "~~~ BEGIN ~~~\n
Date/Time: $(date +"%d-%m-%Y_%T")\n"  | tee $logFile

COUNT=$(cat output.csv | sed '1d;$d' | wc -l)

#Log Injection
echo -e "Creating updated CSV file...\n" | tee -a $logFile

echo -e "name,ean,price,in_stock" > updated.csv

for (( c=2; c<=$COUNT+1; c++ ))
do
	echo -e "Getting EAN $ean...\n"  | tee -a $logFile
	ean=$(cut -d "," -f 2 output.csv | sed -n $c\p)

	wget -q -O temp_json https://stores-api.zakaz.ua/stores/48215614/products/search_old/?q=$ean

	new_title=$(cat temp_json | jq -r '.results[0].title')
	new_price=$(cat temp_json | jq -r '.results[0].price')
	new_price=$(echo -e "scale=2;var=$new_price;var/100" | bc -l)
	new_in_stock=$(cat temp_json | jq -r '.results[0].in_stock')

	#Log Injection
	echo -e "Fetched:
Name:\t\t$new_title
EAN:\t\t$ean
Price:\t\t$new_price
InStock:\t$new_in_stock\n
Saving to updated.csv... "  | tee -a $logFile

	echo -e "$new_title,$ean,$new_price,$new_in_stock" >> updated.csv

	# Log Injection
	echo -e "Done!\n\n~~~~~\n" | tee -a $logFile

	rm temp_json
done

echo -e "Count: $(($(cat updated.csv | sed '1d' | wc -l)))
Updated on $(date +%c)" >> updated.csv

endTime=$(date +%s)

# Log Injection
echo -e "Task finished!
Script was running for $(($endTime-$startTime)) seconds!\n\n~~~ END ~~~"  | tee -a $logFile