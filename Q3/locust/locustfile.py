from locust import HttpUser,HttpLocust, between, task
import random, string
def randomString(stringLength=12):
    letters = string.ascii_letters + string.digits
    return ''.join(random.choice(letters) for i in range(stringLength))

class WebsiteUser(HttpUser):
    wait_time = between(5,9)
    @task(1)
    def postUrl(self):
        self.client.post("/newUrl", data={"url": "https://locust.io/{}".format(randomString())})
    @task(10)
    def index(self):
        self.client.get("/{}".format(randomString()))
    def getUrl(self):
        self.client.get(randomString())
