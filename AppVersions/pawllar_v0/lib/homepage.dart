import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'requests.dart';

// Initial 0 DateTime HeartRateData
List<HeartRateData> getChartData() {
  List<HeartRateData> values = [
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 0)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 1)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 2)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 3)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 4)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 5)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 6)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 7)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 8)),
    HeartRateData(0, DateTime(2000, 01, 01, 0, 0, 9)),
  ];
  return values;
}

// Home page of the app
class HomePage extends StatefulWidget {
  final String db;
  final int temperature, age;

  HomePage({Key? key, this.db = "miband3", this.temperature = 37, this.age = 5})
      : super(key: key);

  @override
  _HomePageState createState() =>
      _HomePageState(this.db, this.temperature, this.age);
}

class _HomePageState extends State<HomePage> {
  _HomePageState(this.db, this.temperature, this.age);

  // Variables to be accepted
  final String db;
  final int temperature, age;

  // Variables to be used later
  late List<HeartRateData> values, all_values;
  // late ChartSeriesController _chartSeriesController;
  // late CircularSeriesController _circularChartSeriesController;
  late List<HealthCheck> parameter;
  late String displayHeartRate;
  late int i;
  late String status_image;

  @override
  void initState() {
    // Load the data every 1 second
    Timer.periodic(const Duration(seconds: 1), loadChartData);
    i = 0;

    // Get initial data
    values = getChartData();
    parameter = [HealthCheck(values)];
    displayHeartRate = "";
    status_image = "optimal.png";

    // Start the main application
    super.initState();
  }

  // Load data function to update the source of the SFCartesian graph
  void loadChartData(Timer timer) async {
    // Get the database values
    all_values = await updateBandData(this.db);

    // Update values to the data source of the SFCartesian
    for (int j = 0; j < 10; j++) {
      values.add((all_values[j]));
      values.removeAt(0);
    }

    // Update values to the data source of the SfCircular
    HealthCheck newData = HealthCheck(values);
    parameter.removeAt(0);
    parameter.add(newData);

    // // Update the source via the CircularSeriesController
    // _circularChartSeriesController.updateDataSource(updatedDataIndexes: [0]);

    // // Update the source via the ChartSeriesController
    // _chartSeriesController.updateDataSource(
    //     removedDataIndex: 0, addedDataIndex: 9);

    // Set state
    setState(() {
      values = all_values;

      parameter.removeAt(0);
      parameter.add(newData);

      displayHeartRate = parameter[0].average.toString();
      if (parameter[0].average < 75 || parameter[0].average > 120) {
        status_image = "not_optimal.png";
      } else {
        status_image = "optimal.png";
      }
    });
  }

  // Setting up title text style
  static const titleStyle =
      TextStyle(fontFamily: "Cotton Butter", fontSize: 72);

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage("img/profile_picture.png"), context);
    precacheImage(AssetImage("img/optimal.png"), context);
    precacheImage(AssetImage("img/not_optimal.png"), context);
    // Get screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Making 3 tab application
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Paw'llar", style: titleStyle),
          centerTitle: true,
        ),
        // Navigation bar configuration
        bottomNavigationBar: Container(
          color: Colors.black,
          child: TabBar(
            labelStyle: TextStyle(fontFamily: "Dandelion", fontSize: 28),
            unselectedLabelStyle:
                TextStyle(fontFamily: "Dandelion", fontSize: 28),
            labelColor: Colors.blueGrey,
            unselectedLabelColor: Colors.grey[700],
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: Colors.pink.shade200,
            tabs:
                // Setting up tab visual attributes ( icon )
                <Widget>[
              Tab(
                height: screenHeight / 15,
                icon: Icon(Icons.analytics_outlined),
              ),
              Tab(
                height: screenHeight / 15,
                icon: Icon(Icons.circle_notifications_outlined),
              ),
            ],
          ),
        ),
        drawer: Drawer(
          child: SingleChildScrollView(
              child: Column(children: <Widget>[
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.purple.shade300),
                child: Center(
                    child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                      border: Border.all(width: 5, color: Colors.pink.shade100),
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    "img/profile_picture.png",
                    fit: BoxFit.contain,
                  ),
                ))),
            Container(
              height: 5,
            ),
            Card(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ListTile(
                  leading: Text(
                    "USERNAME",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  title: Text(
                    "$db",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ])),
            Container(
              height: 5,
            ),
            Card(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ListTile(
                  leading: Text(
                    "AGE",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  title: Text(
                    "$age",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ])),
            Container(
              height: 5,
            ),
            Card(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ListTile(
                  leading: Text(
                    "TEMPERATURE",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  title: Text(
                    "$temperature",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ])),
            Container(
              height: 5,
            ),
            Card(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: ListTile(
                  leading: Text(
                    "HEARTRATE",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.left,
                  ),
                  title: Text(
                    "$displayHeartRate",
                    style: TextStyle(fontFamily: "Montserrat", fontSize: 20),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ])),
            Container(
              height: 50,
            ),
            Container(
              child: Text(
                """Made with Love
Rushour0""",
                style: TextStyle(fontFamily: "Dandelion", fontSize: 36),
                textAlign: TextAlign.center,
              ),
            )
          ])),
        ),
        // Content of the tabs
        body: TabBarView(
          children: <Widget>[
            // First tab

            Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade200,
                    )
                  ],
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                height: MediaQuery.of(context).size.height,
                width: screenWidth,
                child: Column(children: <Widget>[
                  Expanded(
                      // The SFCartesian chart
                      child: SfCartesianChart(
                          // Set X axis to DateTime
                          primaryXAxis:
                              DateTimeAxis(dateFormat: DateFormat('hh:mm:ss')),
                          title: ChartTitle(
                              text: "Live Data",
                              textStyle: TextStyle(
                                  fontFamily: "Montserrat", fontSize: 28)),
                          // Providing the data source and mapping the data
                          series: <LineSeries<HeartRateData, DateTime>>[
                        LineSeries<HeartRateData, DateTime>(
                            onRendererCreated:
                                (ChartSeriesController controller) {
                              // _chartSeriesController = controller;
                            },
                            animationDuration: 0,
                            dataSource: values,
                            xValueMapper: (HeartRateData value, _) =>
                                value.datetime,
                            yValueMapper: (HeartRateData value, _) =>
                                value.HeartRate),
                      ])),
                ])),

            // Second tab

            // Third tab
            Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.pink.shade200,
                    )
                  ],
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                height: screenHeight * 2 / 3,
                width: screenWidth,
                child: Stack(children: <Widget>[
                  Center(
                      child: Text(displayHeartRate,
                          style: TextStyle(
                              fontFamily: "Montserrat", fontSize: 32))),
                  Center(child: Text("""


BPM""", style: TextStyle(fontFamily: "Montserrat", fontSize: 32))),
                  Column(children: <Widget>[
                    Expanded(
                        child: SfCircularChart(
                            title: ChartTitle(
                                text: "Health Check",
                                textStyle: TextStyle(
                                    fontFamily: "Montserrat", fontSize: 28)),
                            series: <CircularSeries<HealthCheck, int>>[
                          RadialBarSeries(
                            onRendererCreated:
                                (CircularSeriesController controller) {
                              // _circularChartSeriesController = controller;
                            },
                            maximumValue: 200,
                            dataSource: parameter,
                            radius: '70%',
                            innerRadius: '80%',
                            xValueMapper: (HealthCheck data, _) => data.average,
                            yValueMapper: (HealthCheck data, _) => data.average,
                            pointColorMapper: (HealthCheck data, _) =>
                                data.color,
                            cornerStyle: CornerStyle.bothCurve,
                          )
                        ])),
                  ]),
                ])),
          ],
        ),
      ),
    );
  }
}
