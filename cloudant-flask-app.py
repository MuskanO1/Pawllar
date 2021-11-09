from flask import Flask, render_template, make_response
import json
from flask import Flask, render_template, make_response
from flask_cors import CORS
import datetime
from ibmcloudant.cloudant_v1 import CloudantV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
import os
from dotenv import load_dotenv

load_dotenv()

SERVICE_URL = os.getenv("SERVICE_URL")
API_KEY = os.getenv("API_KEY")
authenticator = IAMAuthenticator(API_KEY)
button_accesscode = os.getenv("button_accesscode")
service = CloudantV1(authenticator=authenticator)

service.set_service_url(SERVICE_URL)

# Loading all privates keys from .env file

app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes

i = 0
response = service.post_all_docs(
    db="coband",
    include_docs=True,
).get_result()
i = len(response["rows"]) - 20  # start index to only plot last 20 docs in db


def get_data():
    response = service.post_all_docs(
        db="coband",
        include_docs=True,
    ).get_result()
    return response


@app.route("/", methods=["GET", "POST"])
def main():
    return render_template(
        "index.html", button_accesscode=button_accesscode
    )  # Passing button access code for alexa controls


@app.route("/data", methods=["GET", "POST"])
def data():
    global i
    responses = get_data()  # Getting all docs from db
    if i >= len(
        responses["rows"]
    ):  # To make sure we arent exceeding the length of the db
        return make_response(
            json.dumps([])
        )  # If we are exceeding the length of the db, return empty list
    else:
        response = responses["rows"][i]["doc"]  # Getting the doc from the db
        timedate_raw = response["_id"]  # Getting the time and date from the doc
        date_obj = datetime.datetime.strptime(
            timedate_raw, "%d/%m/%y %H:%M:%S"
        )  # Converting the time and date to a datetime object
        hr_value = response["value"]  # Getting the heart rate value from the doc
        data1 = [
            date_obj.timestamp() * 1000,
            int(hr_value),
        ]  # Converting the datetime object to unix timestamp
        print(data1)
        response = make_response(json.dumps(data1))  # Converting the data to json
        response.content_type = "application/json"
        print(response)
        i = i + 1  # Incrementing the index
        return response


if __name__ == "__main__":
    app.run(debug=True)
