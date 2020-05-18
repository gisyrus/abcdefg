#!/usr/bin/python3
import boto3
import os

ec2 = boto3.client('ec2',region_name='us-east-2')
os.environ['AWS_PROFILE'] = "default"
os.environ['AWS_DEFAULT_REGION'] = "us-east-2"
filters = [
    {'Name': 'domain', 'Values': ['vpc']},
    {'Name': 'instance-id', 'Values': ['i-0b3ca7b439c60577b']} # get the aws instance id from aws console
]
response = ec2.describe_addresses(Filters=filters)
os.environ['AWS_PUBLICIP'] = response["Addresses"][0]["PublicIp"]
print(response["Addresses"][0]["PublicIp"])
