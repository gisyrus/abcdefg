# Documentation

### Project hierarchy

```
helloworld
├── Q1
│   ├── access.log
│   ├── geoip-mapping.log
│   ├── geoip.log
│   ├── geoip.sh
│   ├── task1.sh
│   ├── task2.sh
│   └── task3.sh
├── Q2
│   ├── awssh
│   ├── boto3
│   └── ip.txt
└── Q3
    ├── docker
    │   ├── docker-compose.yml
    │   ├── flask
    │   │   ├── Dockerfile
    │   │   ├── app.py
    │   │   └── requirements.txt
    │   ├── nginx
    │   │   ├── Dockerfile
    │   │   ├── log
    │   │   ├── mime.types
    │   │   └── nginx.conf
    │   └── redis
    │       ├── data
    │       └── redis.conf
    └── locust
        ├── locustfile.py
        ├── locust.sh
        └── requirements.txt
```

# Q1 - Log Analytics

## Perquisites

- install geoip-bin

```bash
sudo apt-get update
sudo apt-get install geoip-bin
```

## Part 1 - Count the total number of HTTP requests recorded by this access logfile

- ./Q1/task1.sh

```bash
#!/bin/bash
echo "Request with HTTP/1.1 / HTTP/1.0 / HTTP/1.2:"

cat access.log | awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/' | wc -l

echo "Request which is not HTTP request:"

cat access.log | awk '! /HTTP/' | wc -l
```

navigate to `/path/to/helloworld/Q1` and run `./task1.sh`

```
ec2-user@hostname:/path/to/helloworld/Q1$ ./task1.sh
Request with HTTP/1.1 / HTTP/1.0 / HTTP/1.2:
85951
Request which is not HTTP request:
133
```

The command `awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/'` is used to filter out the requests which contained the HTTP method.

`wc -l` is used to count the number of lines in the file which represents the number of requests

## Part 2 - Find the top-10 (host) hosts makes most requests from 2019-06-10 00:00:00 to
2019-06-19 23:59:59, inclusively

- /path/to/helloworld/Q1/task2.sh

```bash
#!/bin/bash
echo "Getting request with HTTP/1.1 / HTTP/1.0 / HTTP/2.0 from 2019-06-10 to 2019-06-19:"

cat access.log | awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/' | grep '1[[:digit:]]/Jun/2019'  | cat - > http.log

echo "Extracting IP address for every request.."

cat http.log | awk '{print $1}' | cat - > ip.log

echo "Top 10 hosts that makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59"

cat ip.log | sort | uniq -c | sort -r | head -10

rm -f http.log ip.log
```

navigate to `/path/to/helloworld/Q1` and run `./task2.sh`

```
ec2-user@hostname:/path/to/helloworld/Q1$ ./task2.sh
Getting request with HTTP/1.1 / HTTP/1.0 / HTTP/2.0 from 2019-06-10 to 2019-06-19..
Extracting IP address for every request..
Top 10 hosts that makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59
		730 118.24.71.239
    730 1.222.44.52
    723 119.29.129.76
    486 148.251.244.137
    440 95.216.38.186
    440 136.243.70.151
    437 213.239.216.194
    436 5.9.71.213
    436 5.189.159.208
    406 5.9.108.254
```

At the first line of program , `grep '1[[:digit:]]/Jun/2019'  | cat - > http.log` is used to filter out the creation date of the requests and then store into a file called `http.log`

Then we use `awk '{print $1} | cat - > ip.log` to get the source ip for every request and then store into a file called `ip.log`

And then we can use `sort | uniq -c | sort -r | head -10` to get what we want.

`sort`: sort all the lines by number / lower to upper alphabetical order

`uniq -c`:  count how many times a line repeated in the file

`sort -r` : sort all the lines with reverse order

`head -10`: only show the first 10 outputs

## Part 3 - Find out the country with most requests originating from according to the source
IP

- /path/to/helloworld/Q1/task3.sh

```bash
#!/bin/bash
echo "Getting request with HTTP/1.1 / HTTP/1.0 / HTTP/2.0 from 2019-06-10 to 2019-06-19:"

cat access.log | awk '/HTTP\/1.1/ || /HTTP\/1.0/ || /HTTP\/2.0/' | grep '1[[:digit:]]/Jun/2019'  | cat - > http.log

echo "Extracting IP address for every request.."

cat http.log | awk -F ' ' '{print $1}' | cat - > ip.log

echo "Top 10 hosts that makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59"

cat ip.log | sort | uniq | cat - > uniq_ip.log 

echo "Searching geographical IP location"
echo "Please wait.. It takes time depends on log file size.."

while read -r ip;
do
        if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
                geoip=$(geoiplookup $ip | awk -F ', ' '{print $2}') ;
        else
                geoip=$(geoiplookup6 $ip | awk -F ', ' '{print $2}') ;
fi
printf "$geoip \n" >> geoip.log
done < uniq_ip.log
sed -i 's/\ //g' geoip.log
cat geoip.log | grep '^[[:blank:]]*$' | echo "The number of non-resolved IP address:" $(wc -l)
sed -i '/^$/d' geoip.log

echo " Top 10 country with most requests originating from:"
cat geoip.log | sort -r | uniq -c | sort -r | head -10

rm -f http.log ip.log uniq_ip.log
```

Note : there are some cases that the geoiplookup / geoiplookup6 did't find any geographical location of the IP address.

navigate to `/path/to/helloworld/Q1` and run `./task3.sh`

```
ec2-user@hostname:/path/to/helloworld/Q1$ ./task2.sh
Getting request with HTTP/1.1 / HTTP/1.0 / HTTP/2.0 from 2019-06-10 to 2019-06-19..
Extracting IP address for every request..
Top 10 hosts that makes most requests from 2019-06-10 00:00:00 to 2019-06-19 23:59:59
Searching geographical IP location
Please wait.. It takes time depends on log file size..
The number of non-resolved IP address: 14
 Top 10 country with most requests originating from:
    787 UnitedStates
    541 China
    232 France
     45 HongKong
     43 Germany
     34 Netherlands
     33 RussianFederation
     23 Turkey
     19 Italy
     12 UnitedKingdom
```

`cat ip.log | sort | uniq | cat - > uniq_ip.log`: reduce duplicated results of ip address

`while..done loop`: perform geographical location lookup by `geoiplookup` and `geoiplookup6` and then write the results into file called `geoip.log`.

`cat geoip.log | sort -r | uniq -c | sort -r | head -10`: It will show the first top 10 of with most requests originating from.

# Q2 - AWS API Programming

The script`boto3.py` is a Python script that runs AWS boto3 API.

```python
#!/usr/bin/python3
import boto3
import os

ec2 = boto3.client('ec2',region_name='us-east-2')
os.environ['AWS_PROFILE'] = "default"
os.environ['AWS_DEFAULT_REGION'] = "us-east-2"
filters = [
    {'Name': 'domain', 'Values': ['vpc']},
    {'Name': 'instance-id', 'Values': ['i-0b3ca7b439c60577b']}
]
response = ec2.describe_addresses(Filters=filters)
os.environ['AWS_PUBLICIP'] = response["Addresses"][0]["PublicIp"]
print(response["Addresses"][0]["PublicIp"])
```

`awssh` is a bash script that runs `[boto3.py](http://boto3.py)` and then save the ip into `ip.txt` and ssh to the IP address provided in the `ip.txt` at last.

Something we need to configure are the `~/.aws/credential` and `~/.aws/config`files so that we can use the AWS API:

```
# ~/.aws/credential

[default]
aws_access_key_id=LKJHASFLKAHF8ASKJD
aws_secret_access_key=dDPujrZIlsdkjfDSFUdlfsj9eldertk4ere

# ~/.aws/config

[default]
region = us-east-2
```

# Q3 - System Design

## URL shorten system architecture diagram:

![Imgur](https://i.imgur.com/p06h1PZ.png)

## Tech Stack

- Cloud Service
    - AWS
        - EC2 creation (from Q2)
        - Network Security Group Setting
        - Elastic IP (from Q2)
- Programming language: Python
    - Flask - API server framework (as Container)
    - Locust - load test framework
- Technology
    - Redis - Caching Database (as Container)
    - Nginx - Load Balancer (as Container)
    - Docker - Container runtime
    - Docker-compose - Infrastructure as Code (IaC) tool for Docker
    - Docker Swarm - Container orchestration

## Perquisites

- python ≥ 3.6
- docker ≥ 19.03 (with swarm enabled)
- locust

```bash
sudo apt-get install -y python3 python3-pip
sudo apt-get install -y docker.io
pip install locust
```

- docker images
    - (customized flask image) docker_web:v4
    - redis:apline
    - (customized nginx image without default.conf) nginx_cus:v1
    - python:3.7-alpine

You can `docker pull` the images before using `docker-compose` command.

## System Design Concern:

- High Availability: to avoid single point of failure, `docker swarm` service is enabled to allow replication of all microservices.
- Scalability: As `docker swarm` is enabled, we can scale up/down every component easily by configuring the `docker-compose.yml`.
- Scaling Target: This system targets to reach the rate of 1000+ req/s but unfortunately it cannot achieve that because of the hardware limitation.

## Installation:

- Download the customized image from my GitHub repo release or just run the commands:
    - `cd flask && sudo docker build -t docker_web:v4 .`
    - `cd ../nginx && sudo docker build -t nginx_cus:v1 .`
- Run `sudo docker swarm init`
- Go to `Q3/docker`
- Run command `sudo docker stack deploy --compose-file docker-compose.yml task3`

```
ec2-user@host:~/helloworld/Q3/docker/flask$ sudo docker build -t docker_web:v4 .
...
..
.
Successfully built ab2e054387fa
Successfully tagged docker_web:v4
ec2-user@host:~/helloworld/Q3/docker/nginx$ sudo docker build -t nginx_cus:v1 .
...
..
.
Successfully built acew9sd3ow32
Successfully tagged nginx_cus:v1
ec2-user@host:~/helloworld/Q3/docker$ sudo docker swarm init
Swarm initialized: current node (nha7uqdspryeo2oqewaa4ltyy) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3xqqza7ofeprnxbtihr57prj988ons0j5z497m4cdww44i1dp0-e9is8l944oh1ss3cnl99il0vm 172.31.28.231:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.

ec2-user@host:~/helloworld/Q3/docker$ sudo docker stack deploy --compose-file docker-compose.yml task3
Creating network task3_vnet
Creating service task3_redis
Creating service task3_lb
Creating service task3_web

ec2-user@host:~helloworld/Q3/docker$ sudo docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
qr2z9jz434tz        task3_lb            replicated          5/5                 nginxtest:v1        *:80->80/tcp, *:443->443/tcp
6iz4hidbxskz        task3_redis         replicated          2/2                 redis:alpine        *:6379->6379/tcp
jn7mjxuelern        task3_web           replicated          3/3                 docker_web:v4

```

### Verification

```
ec2-user@host:~helloworld/Q3/docker$ curl -X GET 127.0.0.1
{"shortenedUrl":"Argument not provided."}

```

The POST method has a bug that cannot use curl to finish the post request:
`{"message": "The browser (or proxy) sent a request that this server could not understand."}`

### Loading Test with locust

Go to `locust` folder and run `locust.sh`:

```
ec2-user@host:~helloworld/Q3/locust$ ./locust.sh
[2020-05-18 20:01:56,989] ip-172-31-28-216/INFO/locust.main: Starting web monitor at http://localhost:8089
[2020-05-18 20:01:56,997] ip-172-31-28-216/INFO/locust.main: Starting Locust 1.0.1
```

![Imgur](https://i.imgur.com/gqD9S4h.png)

You can also use `locust` with its flag to do the loading test without the UI.

 

Reference: 

[Quick start - Locust 1.0.1 documentation](https://docs.locust.io/en/stable/quickstart.html#locust-command-line-interface-configuration)

### Content of `docker-compose.yml`

```bash
### /path/to/helloworld/Q3/docker/docker-compose.yml
version: '3'
services:
  lb:
    image: "nginx_cus:v1"
    networks:
      - vnet
    deploy:
      replicas: 5 # configure this number to adjust the number of load balancer
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/log/:/var/log/nginx/
  web:
    image: "docker_web:v4"
    deploy:
      replicas: 3 # configure this number to adjust the number of back end server
    networks:
      - vnet
  redis:
    image: "redis:alpine"
    ports:
      - "6379:6379"
    deploy:
      replicas: 2 # configure this number to adjust the number of redis cache database
    networks:
      - vnet
    volumes:
      - ./redis/data:/data
networks:
  vnet:
```

### API ENDPOINTS:

`GET /` 

**Attributes**

---

*url* **string**

The url that you want to search for the existence of short url.

---

Response:

```json
GET http://127.0.0.1/?url=https://google.com

# HTTP 200
{
  "shortenedUrl": "https://sy.ru/ods3lkwe5"
}
```

`GET /[a-zA-Z0-9]{9}`

Response:

```json
GET http://127.0.0.1/ieioweh4

# HTTP 200 if url exists
{
	"shortUrl": "https://sy.ru/ieioweh4",
	"url": "https://yahoo.com.hk"
}

# HTTP 200 if url exists
{
	"shortUrl": "https://sy.ru/ieioweh4",
	"url": "Not exist"
}

```

`POST /newUrl`

Header:

Content type: Application/json

---

Payload body:

```json
{
	"url": "https://mail.google.com"
}
```

---

Response:

```json
# HTTP 200
{
	"url": "https://www.nginx.com",
	"shortUrl": "https://sy.ru/wew6tuwe3"
}

# HTTP 304
No response will be returned for HTTP 304
```

## Assumption and Limitation

- Assume users will not type anything wrongly (e.g. getting wrong url `htp://google.com`)
- No validation for the url format
- Log file for Flask API server did not implement, takes time to trace the error generated from the back end API
- Hardware specification highly limits the performance of this system.
    - This is the locust test with user keep sending requests to the API server and the user number will increase by 5 per second.

        ![Imgur](https://i.imgur.com/XMFw0lu.png)

        ![Imgur](https://i.imgur.com/dQNE6hx.png)

        ![Imgur](https://i.imgur.com/FZ9U0rZ.png)

        From the 3 graphs, we can see that :

        - when the number of users meets around 700 at around 12:38 am, the server response time increases suddenly.
        - However it goes down at around 12:40 am with the adjust of load balancers and back end servers by themselves , they can catch the request with a quicker response time and the total request/second can increase to around 130 requests/second
        - But with the gradually increase of users, the  total requests/second decreases and the response time increases significantly.

    - By using `top` command in the terminal of the ec2 instance, I discovered that the CPU keeps holding at 100% for a long time during the test. Therefore the solution of solving the high CPU usage would be adding more resources to the hardware.

    - Flask-limiter does not implement into the system, which may easily being attacked by DDoS
    - Issue: `curl` with the API may result in HTTP 400 Error: `{"message": "The browser (or proxy) sent a request that this server could not understand."}`
        - Work around: use Postman to try the test
    - Issue: `redis.conf` did not set properly, may have memory leak
