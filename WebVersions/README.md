# PAW'llar : Web Interface


## Technologies
------------
Project's website is created with:
* Flask
* IBM Cloudant database Service
* MiBand4 library to retrieve heartrate information (Works only with linux)
* JavaScript
* Highcharts for plotting graph
	
## Setup
------------
To run this project, install the requirements.txt module using -

For linux or MacOs:
```
pip3 install -r requirements.txt
```

For Windows:
```
pip install -r requirements.txt
```


Ensure .env files are present while running the codes. The keys provided only have read access. Values cannot be appended into database without write access. 

To run the prototype simulation to get data from cloudant, setup the webpage using :

For linux or MacOs:
```
python3 cloudant-flask-app.py
```

For Windows:
```
python cloudant-flask-app.py
```
