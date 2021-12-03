import time
from datetime import datetime
from bluepy.btle import BTLEDisconnectError
from miband import miband
from ibmcloudant.cloudant_v1 import CloudantV1
from ibm_cloud_sdk_core.authenticators import IAMAuthenticator
from ibmcloudant.cloudant_v1 import CloudantV1, Document
import os
from dotenv import load_dotenv

load_dotenv()

# All the necessary imports

SERVICE_URL = os.getenv("SERVICE_URL")
API_KEY = os.getenv("API_KEY")
AUTH_KEY = os.getenv("AUTH_KEY")
MAC_ADDR = os.getenv("MAC_ADDR")

AUTH_KEY = bytes.fromhex(AUTH_KEY)
alternate = True

authenticator = IAMAuthenticator(API_KEY)

client = CloudantV1(authenticator=authenticator)

client.set_service_url(SERVICE_URL)

# Loaded all private key from .env file


def general_info():  # function to get general info about the band
    global band
    print("MiBand-4")
    print("Soft revision:", band.get_revision())
    print("Hardware revision:", band.get_hrdw_revision())
    print("Serial:", band.get_serial())
    print("Battery:", band.get_battery_info()["level"])
    print("Time:", band.get_current_time()["date"].isoformat())


# function to create connection and band object ;-;
def create_connection():
    success = False
    while not success:
        try:
            band = miband(MAC_ADDR, AUTH_KEY, debug=True)
            success = band.initialize()
            return band
        except BTLEDisconnectError:
            print("Connection to the MIBand failed. Trying out again in 3 seconds")
            time.sleep(3)
            continue
        except KeyboardInterrupt:
            print("\nExit.")
            exit()


band = create_connection()
general_info()

hr_list = {}


def get_realtime():
    try:
        band.start_heart_rate_realtime(heart_measure_callback=heart_logger)
    except KeyboardInterrupt:
        print("\nExit.")


def heart_logger(data):  # data is the value of heart rate
    data = abs(data)  # to make sure that the value is positive
    print("Realtime heart BPM:", data)  # print the value
    hr_list[
        datetime.now().strftime("%d/%m/%y %H:%M:%S")  # add the value to the dictionary
    ] = data  # Add the heart rate to the list
    print(len(hr_list) // 2)
    global alternate
    if alternate:  # to append the heartrate every alternate entry
        time_ = str(
            datetime.now().strftime("%d/%m/%y %H:%M:%S")
        )  # converting time to string
        data_entry: Document = Document(id=time_)

        # Add "add heart rate reading as value" field to the document
        data_entry.value = data

        # Save the document in the database
        create_document_response = client.post_document(  # create a document
            db="pawllar_v0", document=data_entry  # in the database
        ).get_result()  # get the result of the response

        print(f"You have created the document:\n{data_entry}")  # Log the document
        print("Logged the data")
    else:
        print("Didnt log the data")
    alternate = not alternate


get_realtime()
