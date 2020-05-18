#!/bin/bash
### The default web host monitor will be run at http://localhost:8089
### Please change the host to your API server url.
### E.G. http://localhost:8080
locust --web-host "localhost" --host "http://127.0.0.1" 
