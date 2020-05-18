#!/bin/bash
echo "Getting request with HTTP/1.1 / HTTP/1.0 / HTTP/2.0 from 2019-06-10 to 2019-06-19.."

cat access.log | awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/' | grep '1[[:digit:]]/Jun/2019'  | cat - > http.log

echo "Extracting IP address for every request.."

cat http.log | awk '{print $1}' | cat - > ip.log

echo "Top 10 hosts that makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59"

cat ip.log | sort | uniq -c | sort -r | head -10


rm -f http.log ip.log
