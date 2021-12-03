from flask import Flask, render_template, make_response, request
import json
import time
from flask_cors import CORS
from datetime import datetime
from ibmcloudant.cloudant_v1 import CloudantV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
import os
from dotenv import load_dotenv

load_dotenv()

SERVICE_URL = os.getenv("SERVICE_URL")
API_KEY = os.getenv("API_KEY")
authenticator = IAMAuthenticator(API_KEY)
button_accesscode = os.getenv("button_accesscode")

# SERVICE_URL = os.environ["SERVICE_URL"]
# API_KEY = os.environ["API_KEY"]
# authenticator = IAMAuthenticator(API_KEY)
# button_accesscode = os.environ["button_accesscode"]

service = CloudantV1(authenticator=authenticator)

service.set_service_url(SERVICE_URL)

# Loading all privates keys from .env file


class databases:
    def __init__(self, db):
        self.db = db
        response = service.post_all_docs(
            db=db,
            include_docs=False,
        ).get_result()
        self.length = response["total_rows"]
        # self.current_val = 0
        self.current_val = self.length - 20
        print(self.length)
        print(self.current_val)

    def print_all(self):
        print(self.db)
        print(self.length)
        print(self.current_val)


database_list = ["pawllar_v3"]  # Enter databases to be tracked

db_obj_list = []

for database in database_list:
    db_obj_list.append(databases(database))

print(db_obj_list)

for database in db_obj_list:
    database.print_all()


app = Flask(__name__)
CORS(app)  # This will enable CORS for all routes
dispense_rn = False

# i = 0
# response = service.post_all_docs(
#     db="jxtin",
#     include_docs=False,
# ).get_result()
# i = (response["total_rows"]) - 25  # start index to only plot last 20 docs in db

# print("Number of entries to be shown ", i)


def get_data(db):
    responses = service.post_all_docs(
        db=db,
        include_docs=True,
    ).get_result()
    return responses


@app.route("/", methods=["GET", "POST"])
def main():
    return render_template(
        "index.html", button_accesscode=button_accesscode
    )  # Passing button access code for alexa controls


@app.route("/data", methods=["GET", "POST"])
def data():
    data_list = {}
    count = 0

    for database in db_obj_list:
        try:
            responses = get_data(database.db)
            cur_data = responses["rows"][database.current_val]["doc"]
            print(cur_data["_id"])
            cur_data["_id"] = (
                datetime.strptime(cur_data["_id"], "%d/%m/%y %H:%M:%S")
            ).timestamp() * 1000
            # print(cur_data)
            data_list[count] = cur_data
            database.current_val += 1
            count += 1
        except IndexError:
            time.sleep(2)
        time.sleep(0.2)
    # print(data_list)
    return data_list


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0")
