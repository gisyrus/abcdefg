#!/bin/bash
echo "Request with HTTP/1.1 / HTTP/1.0 / HTTP/1.2:"

cat access.log | awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/' | wc -l

echo "Request which is not HTTP request:"

cat access.log | awk '! /HTTP/' | wc -l

