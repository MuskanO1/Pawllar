# Pawllar


INTRODUCTION
------------

Pawllar is a product idea developed by team PontiacBandits primarily for [Resideo IOT hackathon](https://www.hackerearth.com/challenges/hackathon/hack-iot/) and following is the prototype of the product dash board web version with following functionalities :

 * Visualise and raise alerts based on heartrate of your pet
 * Use that heart rate to perform actions on your smart home enhancing the experience of your pet.
 * Trigger alexa routines manually or by inferring the heartrate.
 * Control light color, relaxing music, control temperature of the thermost and even more according to available smart home devices.

## Technologies
------------
Project is created with:
* Flask
* IBM Cloudant database Service
* MiBand4 library to retrieve heartrate information
* JavaScript
* Highcharts for plotting graph
	
## Setup
------------
To run this project, install the requirements.txt module using 

For linux or MacOs:
```
pip3 install -r requirements.txt
```

For Windows:
```
pip install -r requirements.txt
```

To run the prototype simulation to get data from cloudant, setup the webpage using :

For linux or MacOs:
```
python3 cloudant-flask-app.py
```

For Windows:
```
python cloudant-flask-app.py
```
