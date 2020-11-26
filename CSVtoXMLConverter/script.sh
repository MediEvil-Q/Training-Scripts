#!/usr/bin/bash

startTime=$(date +%s)

touch "$(date +"%d-%m-%Y_%T").log"
logFile="$(ls *.log --sort=time | cut -d " " -f 1,2 | sed -n 1p)"

# Log Start
echo -e "~~~ BEGIN ~~~\n
Date/Time: $(date +"%d-%m-%Y_%T")\n"  | tee $logFile

COUNT=$(cat output.csv | sed '1d;$d' | wc -l)

#Log Injection
echo -e "Creating XML file...\n" | tee -a $logFile

echo -e "<?xml version=\"1.0\"?>\n<products> " > output.xml

for (( c=2; c<=$COUNT+1; c++ ))
do
	name=$(cut -d "," -f 1 output.csv | sed -n $c\p)
	ean=$(cut -d "," -f 2 output.csv | sed -n $c\p)
	price=$(cut -d "," -f 3 output.csv | sed -n $c\p)
	in_stock=$(cut -d "," -f 4 output.csv | sed -n $c\p)

	#Log Injection
	echo -e "Fetched:
Name:\t\t$name
EAN:\t\t$ean
Price:\t\t$price
InStock:\t$in_stock\n
Saving to output.xml... "  | tee -a $logFile

	echo -e "<product id=\"$(($c - 1))\"><name>$name</name><ean>$ean</ean><price>$price</price><in_stock>$in_stock</in_stock></product>" >> output.xml

	# Log Injection
	echo -e "Done!\n\n~~~~~\n" | tee -a $logFile
done

echo -e "</products>" >> output.xml

#Log Injection
echo -e "Formatting XML file...\n"

xmllint --format output.xml > output.xml_output && mv output.xml_output output.xml

endTime=$(date +%s)

# Log Injection
echo -e "Task finished!
Script was running for $(($endTime-$startTime)) seconds!\n\n~~~ END ~~~"  | tee -a $logFile