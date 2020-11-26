#!/usr/bin/bash

startTime=$(date +%s)

# Check for logs and products directories
if [ -e "$outputFolder/logs/" ] && [ -e "$outputFolder/products/" ]
then
	> /dev/null
else
	mkdir $outputFolder/logs
	mkdir $outputFolder/products
fi

touch "$outputFolder/logs/$(date +"%d-%m-%Y_%T").log"

latestFile="$inputFolder/$(ls $inputFolder --sort=time | cut -d " " -f 1 | sed -n 1p)"
logFile="$outputFolder/logs/$(ls $outputFolder/logs/ --sort=time | cut -d " " -f 1,2 | sed -n 1p)"
productCount=$(cat $latestFile | sed '1d;$d' | wc -l)

# Log Start
echo -e "~~~ BEGIN ~~~\n
Date/Time: $(date +"%d-%m-%Y_%T")\n"  | tee $logFile

# Check for empty input directory
if [[ $(ls -A "$inputFolder") ]]
then
	> /dev/null
else
	echo -e "The input directory is empty!\n\n~~~ END ~~~" | tee -a $logFile
	exit
fi

# Check for empty input file
if [[ -s "$latestFile" ]]
then
	> /dev/null
else
	echo -e "The latest input file is empty!\n\n~~~ END ~~~" | tee -a $logFile
	exit
fi

# Check for the correct CSV headers
if [[ $(grep "name,ean,price,in_stock" $latestFile) ]]
then
	> /dev/null
else
	echo -e "Latest CSV file does not have valid headers!\n\n~~~ END ~~~" | tee -a $logFile
	exit
fi

# Log Injection
echo -e "Checking latest file in $inputFolder
Done! Filename: $latestFile
Found $productCount items.
Fetching new prices...\n\n~~~~~\n"  | tee -a $logFile

for (( c=2; c<=$productCount+1; c++ ))
do
    ean=$(cut -d "," -f 2 $latestFile | sed -n $c\p)
    old_price=$(cut -d "," -f 3 $latestFile | sed -n $c\p)

    if [[ $ean  != *"metro"* ]]
	then
	if [[ `head -c 1 <<< $ean` != 0 ]]
	then
		ean="0$ean"
	fi
    fi

    echo -e "Getting EAN $ean...\n"  | tee -a $logFile
    wget -q -O temp_json https://stores-api.zakaz.ua/stores/48215614/products/search_old/?q=$ean

    title=$(echo -e `cat temp_json | jq -r  '.results[0].title'`)
    new_price=$(cat temp_json | jq -r  '.results[0].price')
    new_price=$(echo -e "scale=2;var=$new_price;var/100" | bc -l)
    new_in_stock=$(cat temp_json | jq -r  '.results[0].in_stock')

    # Log Injection
	echo -e "Fetched:
Name:\t\t$title
EAN:\t\t$ean
OldPrice:\t$old_price
NewPrice:\t$new_price
InStock:\t$new_in_stock\n
Saving to $outputFolder/products/$ean.txt... "  | tee -a $logFile

    echo -e "Name:\t\t$title
EAN:\t\t$ean
OldPrice:\t$old_price
NewPrice:\t$new_price
InStock:\t$new_in_stock" > $outputFolder/products/$ean.txt

    # Log Injection
    echo -e "Done!\n\n~~~~~\n" | tee -a $logFile

    rm temp_json
done

endTime=$(date +%s)

# Log Injection
echo -e "Task finished!
Script was running for $(($endTime-$startTime)) seconds!\n\n~~~ END ~~~"  | tee -a $logFile
