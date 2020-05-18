#!/bin/bash
echo "Getting request with HTTP/1.1 / HTTP/1.0 / HTTP/2.0 from 2019-06-10 to 2019-06-19.."

cat access.log | awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/' | grep '1[[:digit:]]/Jun/2019'  | cat - > http.log

echo "Extracting IP address for every request.."

cat http.log | awk -F ' ' '{print $1}' | cat - > ip.log

echo "Top 10 hosts that makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59"

cat ip.log | sort | uniq | cat - > uniq_ip.log 


echo "Searching geographical IP location"
echo "Please wait.. It takes time depends on log file size.."
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
done < uniq_ip.log
sed -i 's/\ //g' geoip.log
cat geoip.log | grep '^[[:blank:]]*$' | echo "The number of non-resolved IP address:" $(wc -l)
sed -i '/^$/d' geoip.log

#/bin/bash ./geoip.sh uniq_ip.log

echo " Top 10 country with most requests originating from:"
cat geoip.log | sort -r | uniq -c | sort -r | head -10

rm -f http.log ip.log uniq_ip.log
