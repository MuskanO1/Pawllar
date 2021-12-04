# PAW'llar


INTRODUCTION
------------

PAW'llar, a product idea developed by Team Pontiac Bandits primarily for the [Resideo IOT hackathon](https://www.hackerearth.com/challenges/hackathon/hack-iot/) targets adding another layer to Smart Home Automization through sesnor technologies via a one-fits all collar. This collar : PAW'llar essentially is your dog's caretaker as it tracks the main vitals of your dog and predicts its health and status to generate alerts on the owner side through an integrated mobile application and website. Once these alerts are generated on the owner's part, they can trigger various responses to interact with the dog using both, the mobile application and website which range from change in color of lights, temperature and music inside the area in which the dog is located. This is alongside a connected feeder which will allow for food-release on-command ensuring that everything your dog needs can be taken care of through your very phone. 

## Prototype
------------

The prototype thus includes both a multi-sensor based hardware alongside a software part developed in a multitude of versions to get to the final product. Our existing prototype has five functional versions. The idea behind making multiple versions was to ensure that the developing hardware adds to the functionalities of the software end in a manner that would improvise on the existing product and allow for further scaling / improvements without rendering the mobile application / website for our product entirely futile.

The software includes an ownder side mobile application as well as a website cum dashboard. The application is made using flutter whilea python web flask is used to make the website end. Because of lack of direct hardware data fetching and the nature of the competition being online, the data for the software is being fetched from Cloudant after uploading it from the remote hardware. The softwares are dynamic in nature and are updated as new data is realised through the hardware. Dynamically updating health analytics make it easier for the owner to understand the pet's overall health alongside the overall status through the aggregate health index.

The prototype has the following functionalities :

 * Visualise and raise alerts based on a health-index tracked via the heartrate, temperarure and SPO2 of your pet
 * Use that health index to trigger output appliances in your Smart Home enhancing the experience of your pet without any human intervention.
 * Trigger Alexa routines for the same both manually and automatically using the dynamically updating health index (an aggregate of the real-time vitals indicating the wellness and mood of your pet).
 * Controlling the color of lights, nature of music, thermostat temperature and as many devices as needed through the application/website via the connected Alexa.
 * Triggering a feeder that would release food on command to feed the dog while not at home.

