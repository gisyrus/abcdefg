#!/bin/bash
true > geoip.log && true > geoip-mapping.log
while read -r ip;
do
	if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
		geoip=$(geoiplookup $ip | awk -F ', ' '{print $2}') ;
	else
		geoip=$(geoiplookup6 $ip | awk -F ', ' '{print $2}') ;
fi
#printf "%-20s: %s\n" "$ip" "$geoip" >> geoip-mapping.log
printf "$geoip \n" >> geoip.log
#printf "%-20s: %s\n" "$ip" "$geoip"
done < "$1"
sed -i 's/\ //g' geoip.log
cat geoip.log | grep '^[[:blank:]]*$' | echo "The number of non-resolved IP address:" $(wc -l)
sed -i '/^$/d' geoip.log
