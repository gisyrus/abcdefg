import time
import re
import string
import redis
from flask import Flask
from flask_restful import Resource, Api, reqparse
import random
from werkzeug.routing import BaseConverter

app = Flask(__name__)
api = Api(app)

try:
    cache = redis.Redis(host='redis', port=6379)
except redis.exceptions.ConnectionError:
    # test with another db
    cache = redis.Redis(host='redis2', port=6380)


parser = reqparse.RequestParser()
parser.add_argument('url', type=str, help='URL')


def randomString(stringLength=9):
    letters = string.ascii_letters + string.digits
    return ''.join(random.choice(letters) for i in range(stringLength))




class NewUrl(Resource):
    def post(self):
        args = dict(parser.parse_args())
        try:
            shortlink = cache.get(name=args["url"]).decode()
            print(shortlink)
            response = {"url": shortlink}
            return response, 304
        except AttributeError:
            for k, v in args.items():
                x = randomString()
                cache.mset({v: "https://sy.ru/{}".format(x)})
                cache.mset({"https://sy.ru/{}".format(x): v})
                print(cache.get(name=v).decode())
            response = {
                    "url": args["url"],
                    "shortenUrl": cache.get(name=args["url"]).decode()
            }
            return response, 200




class RegexConverter(BaseConverter):
    def __init__(self, url_map, *items):
        super(RegexConverter, self).__init__(url_map)
        self.regex = items[0]

app.url_map.converters['regex'] = RegexConverter

@app.route('/<regex("[a-zA-z0-9]{0,9999}"):rex>/')
def get_url(rex):
    if len(rex) != 9:
        return "The length of shorten url provided is not correct (length: 9)", 404
    else:
        try:
            x = cache.get(name="https://sy.ru/{}".format(rex)).decode()
            response = {"shortUrl": "https://sy.ru/{}".format(rex), "url": x}
            return response, 200
        except AttributeError:
            response = {"shortUrl": "https://sy.ru/{}".format(rex), "url": "Not exist"}
            return response, 200



@app.route('/')
def get_shorten_url():
    try:
        args = parser.parse_args()
        data = cache.get(args['url']).decode()
        res = {"shortenedUrl": data}
        return res, 200
    except AttributeError:
        res = {"shortenedUrl": "Not Exist"}
        return res, 200
    except redis.exceptions.DataError:
        res = {"shortenedUrl": "Argument not provided."}
        return res, 200

api.add_resource(NewUrl,'/newUrl')

