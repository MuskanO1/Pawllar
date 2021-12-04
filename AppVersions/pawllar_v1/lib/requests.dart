import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Global variables
final String apiKeyCloudant = "iTKNYiDWhOhM71Ay-q1faeu1Zp2U0u8jyrm-h2juXyyJ";
final String accesCodeAlexa =
    "amzn1.ask.account.AH3U77JZZT5RYZ5N5CEBB6WTC3FJMF75I2DBEQHVCBJSFSYYS3VOSYOZYB3TNCGNOVOAN7UHBLEPRRUPVFIUGKUIEYBQR3VVWOLYODYUEGAGGGIQLEYPWQ5TNAEUJZOERHZYG5TJZDYX5EMQPK7WLBLMAOYRLFPLFTVPNQHP7NQOFPWYO2CO2GZ75XKYPIMTM5XOHY7IHRKZ6RY"; // Classes for the data
final String dbURL =
    "https://dbb024f3-9e7d-44fd-b99c-cbcdb456cc83-bluemix.cloudantnosqldb.appdomain.cloud";

// Heart rate data class
class HeartRateData {
  HeartRateData(this.HeartRate, this.datetime);
  final num HeartRate;
  final DateTime datetime;
}

// SpO2 data class
class SpO2Data {
  SpO2Data(this.SpO2, this.datetime);
  final num SpO2;
  final DateTime datetime;
}

// Temperature data class
class TemperatureData {
  TemperatureData(this.Temperature, this.datetime);
  final num Temperature;
  final DateTime datetime;
}

// Health Index data class
class HealthIndexData {
  HealthIndexData(this.HealthIndex, this.datetime);
  final num HealthIndex;
  final DateTime datetime;
}

// Heart check calculation class
class HeartCheck {
  final List<HeartRateData> data;
  late num average;
  late Color color;

  // Constructor
  HeartCheck(this.data) {
    this.calculate();
    if (this.average < 75 || this.average > 120)
      color = const Color.fromRGBO(128, 0, 0, 1);
    else
      color = const Color.fromRGBO(0, 128, 0, 1);
  }

  // Calculate the health check parameter for a set of readings
  calculate() {
    num sum = 0;
    for (int count = 0; count < data.length; count++)
      sum += data[count].HeartRate;
    // Get the average
    average = sum ~/ data.length;
  }
}

// Temperature check calculation class
class TemperatureCheck {
  final List<TemperatureData> data;
  late num average;
  late Color color;

  // Constructor
  TemperatureCheck(this.data) {
    this.calculate();
    if (this.average < 98 || this.average > 106)
      color = const Color.fromRGBO(128, 0, 0, 1);
    else
      color = const Color.fromRGBO(0, 128, 0, 1);
  }

  // Calculate the health check parameter for a set of readings
  calculate() {
    num sum = 0;
    for (int count = 0; count < data.length; count++)
      sum += data[count].Temperature;
    // Get the average
    average = sum ~/ data.length;
  }
}

// SpO2 check calculation class
class SpO2Check {
  final List<SpO2Data> data;
  late num average;
  late Color color;

  // Constructor
  SpO2Check(this.data) {
    this.calculate();
    if (this.average < 97)
      color = const Color.fromRGBO(128, 0, 0, 1);
    else
      color = const Color.fromRGBO(0, 128, 0, 1);
  }

  // Calculate the health check parameter for a set of readings
  calculate() {
    num sum = 0;
    for (int count = 0; count < data.length; count++) sum += data[count].SpO2;
    // Get the average
    average = sum ~/ data.length;
  }
}

// Health index check calculation class
class HealthIndexCheck {
  final List<HealthIndexData> data;
  late num average;
  late Color color;

  // Constructor
  HealthIndexCheck(this.data) {
    this.calculate();
    if (this.average < 80)
      color = const Color.fromRGBO(128, 0, 0, 1);
    else
      color = const Color.fromRGBO(0, 128, 0, 1);
  }

  // Calculate the health check parameter for a set of readings
  calculate() {
    num sum = 0;
    for (int count = 0; count < data.length; count++)
      sum += data[count].HealthIndex;
    // Get the average
    average = sum ~/ data.length;
  }
}

// Get IAM token
Future<String> getIAMToken(String IAM_api_key) async {
  // Cloudant
  // String IAM_api_key = "9jtFMX0LC5cab8x5I5OYermeMeDYf0hQKCegLnT0z50L";
  final response = await http.post(
      Uri.parse('https://iam.cloud.ibm.com/identity/token'),
      headers: {
        HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      },
      body:
          "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$IAM_api_key");

  final responseJson = jsonDecode(response.body);
  return responseJson['access_token'];
}

// Get document specific data from a db
Future<Map<String, dynamic>> fetchDocDB(String db, String doc_id) async {
  final String IAM_Token = await getIAMToken(apiKeyCloudant);

  final response =
      await http.get(Uri.parse('$dbURL/$db/$doc_id'), headers: <String, String>{
    HttpHeaders.authorizationHeader: "Bearer $IAM_Token",
    HttpHeaders.contentTypeHeader: 'application/json',
  });

  final responseJson = jsonDecode(response.body);

  return responseJson;
}

// Get data from cloudant
Future<Map<String, dynamic>> fetchCloudantData(String db) async {
  final String IAM_Token = await getIAMToken(apiKeyCloudant);

  final response = await http.post(Uri.parse('$dbURL/$db/_all_docs'),
      headers: <String, String>{
        HttpHeaders.authorizationHeader: "Bearer $IAM_Token",
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "include_docs": true,
        "descending": true,
        "limit": 10,
      }));

  final responseJson = jsonDecode(response.body);

  return responseJson;
}

// Process the rows
Future<List<HeartRateData>> updateHRBandData(String db) async {
  Map<String, dynamic> responseJson = await fetchCloudantData(db);
  List<HeartRateData> hrValues = [];
  final allRows = responseJson['rows'];

  for (var i = 9; i > -1; i--) {
    hrValues.add(HeartRateData(allRows[i]['doc']['hr_value'],
        DateFormat("dd/MM/yy hh:mm:ss").parse(allRows[i]['key'])));
  }
  return hrValues;
}

// Process the rows
Future<List<TemperatureData>> updateTemperatureBandData(String db) async {
  Map<String, dynamic> responseJson = await fetchCloudantData(db);
  List<TemperatureData> temperatureValues = [];
  final allRows = responseJson['rows'];

  for (var i = 9; i > -1; i--) {
    temperatureValues.add(TemperatureData(
        allRows[i]['doc']['temperature_value'],
        DateFormat("dd/MM/yy hh:mm:ss").parse(allRows[i]['key'])));
  }
  return temperatureValues;
}

// Process the rows
Future<List<SpO2Data>> updateSpO2BandData(String db) async {
  Map<String, dynamic> responseJson = await fetchCloudantData(db);
  List<SpO2Data> spo2Values = [];
  final allRows = responseJson['rows'];

  for (var i = 9; i > -1; i--) {
    spo2Values.add(SpO2Data(allRows[i]['doc']['spo2_value'],
        DateFormat("dd/MM/yy hh:mm:ss").parse(allRows[i]['key'])));
  }
  return spo2Values;
}

// Process the rows
Future<List<HealthIndexData>> updateHealthIndexBandData(String db) async {
  Map<String, dynamic> responseJson = await fetchCloudantData(db);
  List<HealthIndexData> indexValues = [];
  final allRows = responseJson['rows'];

  for (var i = 9; i > -1; i--) {
    indexValues.add(HealthIndexData(allRows[i]['doc']['health_index'],
        DateFormat("dd/MM/yy hh:mm:ss").parse(allRows[i]['key'])));
  }
  return indexValues;
}

// Check db existence
Future<bool> checkDB(String dbName, String IAM_Token) async {
  final response = await http.get(Uri.parse('$dbURL/$dbName'),
      headers: {HttpHeaders.authorizationHeader: "Bearer $IAM_Token"});

  print(response.statusCode);
  return (response.statusCode.toString() == '200');
}

// Sign in method
Future<Map<String, dynamic>> signIn(String dbName, String password) async {
  late Map<String, dynamic> results;
  final String IAM_Token = await getIAMToken(apiKeyCloudant);

  if (!(await checkDB(dbName, IAM_Token))) {
    return {"status": false, 'reason': 'error'};
  }
  // Get the database's data
  Map<String, dynamic> logInCheck = await fetchDocDB("key_pass", dbName);

  if (password != logInCheck['password']) {
    return {"status": false, 'reason': 'password'};
  }

  // Clean and give data
  results = {
    "status": true,
    "age": logInCheck['age'],
    "username": dbName,
  };
  return results;
}
