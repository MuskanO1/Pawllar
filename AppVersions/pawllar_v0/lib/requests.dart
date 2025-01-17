import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Global variables
final String apiKeyCloudant = "iTKNYiDWhOhM71Ay-q1faeu1Zp2U0u8jyrm-h2juXyyJ";
final String dbURL =
    "https://dbb024f3-9e7d-44fd-b99c-cbcdb456cc83-bluemix.cloudantnosqldb.appdomain.cloud";

// Heart rate data class
class HeartRateData {
  HeartRateData(this.HeartRate, this.datetime);
  final int HeartRate;
  final DateTime datetime;
}

// Health check calculation class
class HealthCheck {
  final List<HeartRateData> data;
  late int average;
  late Color color;

  // Constructor
  HealthCheck(this.data) {
    this.calculate();
    if (this.average < 75 || this.average > 120)
      color = const Color.fromRGBO(128, 0, 0, 1);
    else
      color = const Color.fromRGBO(0, 128, 0, 1);
  }

  // Calculate the health check parameter for a set of readings
  calculate() {
    int sum = 0;
    for (int count = 0; count < data.length; count++)
      sum += data[count].HeartRate;
    // Get the average
    average = sum ~/ data.length;
  }
}

// Get IAM token
Future<String> getIAMToken(String IAM_api_key) async {
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
      }));

  final responseJson = jsonDecode(response.body);
  print(responseJson);
  return responseJson;
}

// Process the rows
Future<List<HeartRateData>> updateBandData(String db) async {
  Map<String, dynamic> responseJson = await fetchCloudantData(db);
  List<HeartRateData> values = [];
  final allRows = responseJson['rows'];

  for (var i = 9; i > -1; i--)
    values.add(HeartRateData(
        allRows[i]['doc']['value'],
        DateFormat("dd-MM-yy hh:mm:ss")
            .parse(allRows[i]['key'].replaceAll("/", "-"))));

  return values;
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
