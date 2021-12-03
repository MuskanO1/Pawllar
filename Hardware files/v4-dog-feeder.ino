#include <Arduino.h>

#include <ESP8266WiFi.h>
#include <ESP8266WiFiMulti.h>

#include <ESP8266HTTPClient.h>

#include <WiFiClientSecureBearSSL.h>

#include <Servo.h>


Servo myservo;



const uint8_t fingerprint[20] = {0x8F, 0xE4, 0xB1, 0x0D, 0x34, 0xA4, 0x5B, 0x47, 0x73, 0xD7, 0x0D, 0x21, 0x58, 0xC9, 0x7A, 0x89, 0x8A, 0x87, 0x51, 0xAC};
// const uint8_t fingerprint[20] = {0x8F, 0xE4, 0xB1, 0x0D, 0x34, 0xA4, 0x5B, 0x47, 0x73, 0xD7, 0x0D, 0x21, 0x58, 0xC9, 0x7A, 0x89, 0x8A, 0x87, 0x51, 0xAC};
// 8F E4 B1 0D 34 A4 5B 47 73 D7 0D 21 58 C9 7A 89 8A 87 51 AC
// Fingerprint for the hosted website
ESP8266WiFiMulti WiFiMulti;

void setup() {

  Serial.begin(115200);
  // Serial.setDebugOutput(true);

  Serial.println();
  Serial.println();
  Serial.println();

  for (uint8_t t = 4; t > 0; t--) {
    Serial.printf("[SETUP] WAIT %d...\n", t);
    Serial.flush();
    delay(1000);
  }

  WiFi.mode(WIFI_STA);
  WiFiMulti.addAP("12345678", "12345678");
  myservo.attach(2);  //D4
  myservo.write(0);
  delay(5000);

}

void loop() {
  // wait for WiFi connection
  if ((WiFiMulti.run() == WL_CONNECTED)) {

    std::unique_ptr<BearSSL::WiFiClientSecure>client(new BearSSL::WiFiClientSecure);

    client->setFingerprint(fingerprint);
    // Or, if you happy to ignore the SSL certificate, then use the following line instead:
    // client->setInsecure();

    HTTPClient https;

    Serial.print("[HTTPS] begin...\n");
    if (https.begin(*client, "https://pawllar.jxt1n.repl.co/dispense_food")) {  // HTTPS

      Serial.print("[HTTPS] GET...\n");
      // start connection and send HTTP header
      int httpCode = https.GET();

      // httpCode will be negative on error
      if (httpCode > 0) {
        // HTTP header has been send and Server response header has been handled
        Serial.printf("[HTTPS] GET... code: %d\n", httpCode);

        // file found at server
        if (httpCode == HTTP_CODE_OK || httpCode == HTTP_CODE_MOVED_PERMANENTLY) {
          String payload = https.getString();
          Serial.println(payload);
          Serial.println(payload.substring(16,20));
          if (payload.substring(16,20)=="true")
          {
            // code for servo ;_;
            Serial.println("Open the gates");
            myservo.write(180);
            delay(2000);
            myservo.write(0);
            delay(20000);


          }else
          {
            Serial.println("Keep the gates closed the gates");
          }
          
        }
      } else {
        Serial.printf("[HTTPS] GET... failed, error: %s\n", https.errorToString(httpCode).c_str());
      }

      https.end();
    } else {
      Serial.printf("[HTTPS] Unable to connect\n");
    }
  }

  Serial.println("Wait 7s before next round...");
  delay(7000);
} 
