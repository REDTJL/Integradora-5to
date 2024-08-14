#include <Arduino.h>
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <Adafruit_Sensor.h>
#include <DHT.h>
#include <HTTPClient.h>
#include <LiquidCrystal.h>
#include <EEPROM.h>
#include <Keypad.h>
#include <ESP32Servo.h>

// Digital pin connected to the DHT sensor
#define DHTPIN 4
#define DHTTYPE DHT11
DHT dht(DHTPIN, DHTTYPE);

// Variables to hold sensor readings
float temperature = 1.0;
float humidity = 1.0;
bool magnetico = HIGH;
const int sensorPuerta = 34;

// Your WiFi credentials
#define WIFI_SSID "your_wifi_ssid"
#define WIFI_PASSWORD "your_wifi_password"

// Your Firebase Project Web API Key
#define API_KEY "your_firebase_api_key"

// Datos para consumir firebase realtime
#define FIREBASE_HOST "your_firebase_host_url"
#define FIREBASE_AUTH "your_firebase_auth_token"

// Firebase Authentication Object
FirebaseAuth auth;
// Firebase configuration Object
FirebaseConfig config;

// Firebase Data Object
FirebaseData fbdo;

// Store device authentication status
bool isAuthenticated = false;

// Timers
unsigned long previousMillisFirestore = 0;
const long intervalFirestore = 60000; // 1 minute

// Define pins for LCD
const int rs = 13, en = 14, rw = 12, d4 = 27, d5 = 26, d6 = 32, d7 = 33;
LiquidCrystal lcd(rs, rw, en, d4, d5, d6, d7);

// Time variables
String currentDate = "";
String currentTime = "";

// EEPROM address to store the document counter
#define EEPROM_ADDRESS 100

// Document counter
int documentCounter = 0;

// Define the Servo
Servo myservo;
int servoPin = 25; // Define the pin for the servo motor

// Keypad setup
const byte ROWS = 4;
const byte COLS = 4;
char keys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte rowPins[ROWS] = {5, 18, 19, 21}; // Connect to the row pinouts of the keypad
byte colPins[COLS] = {22, 23, 16, 17}; // Connect to the column pinouts of the keypad
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

String inputCode = "";
String personaQueAbre= "";
String contra="";

void Wifi_Init() {
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();
}

void firebase_init() {
  config.api_key = API_KEY;
  config.database_url = FIREBASE_HOST;
  Firebase.reconnectWiFi(true);
  Serial.println("------------------------------------");
  Serial.println("Signing up new user...");
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Success");
    isAuthenticated = true;
  } else {
    Serial.printf("Failed, %s\n", config.signer.signupError.message.c_str());
    isAuthenticated = false;
  }
  Firebase.begin(&config, &auth);
}

int ledG = 15;
int buzzer = 2;
void setup() {
  Serial.begin(115200);
  Wifi_Init();
  firebase_init();
  Firebase.reconnectWiFi(true);
  dht.begin();
  // Pin del sensor magnético
  pinMode(sensorPuerta, INPUT);
  // Pins del LED y buzzer
  pinMode(ledG, OUTPUT);
  pinMode(buzzer, OUTPUT);
  // Inicializar EEPROM con tamaño 512 bytes
  EEPROM.begin(512);
  
  // Leer el documentCounter almacenado desde EEPROM
  documentCounter = EEPROM.read(EEPROM_ADDRESS);
  
  // Inicializar LCD
  lcd.begin(16, 2);  // Inicializar el LCD con 16 columnas y 2 filas
  lcd.print("Starting...");

  // Inicializar Servo
  myservo.attach(servoPin);
  myservo.write(0); // Asegurarse de que el servo esté en 0 grados
}

void updateSensorReadings() {
  temperature = dht.readTemperature();
  humidity = dht.readHumidity();
  Serial.print("Temperature: ");
  Serial.println(temperature);
  Serial.print("Humidity: ");
  Serial.println(humidity);

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println(F("Failed to read from DHT sensor!"));
    lcd.clear();
    lcd.print("Sensor Error!");
    return;
  }

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Temp: ");
  lcd.print(temperature);
  lcd.print(" C");
  lcd.setCursor(0, 1);
}

void updateDateTime() {
  HTTPClient http;
  http.begin("http://worldtimeapi.org/api/timezone/America/Mexico_City");
  int httpResponseCode = http.GET();
  
  if (httpResponseCode > 0) {
    String payload = http.getString();
    int dateIndex = payload.indexOf("datetime") + 11;
    currentDate = payload.substring(dateIndex, dateIndex + 10);
    currentTime = payload.substring(dateIndex + 11, dateIndex + 19);
    Serial.println("Date: " + currentDate);
    Serial.println("Time: " + currentTime);
  } else {
    Serial.printf("Time API Error: HTTP Response code: %d\n", httpResponseCode);
  }
  http.end();
}

String getPinEntrada() {
  if (Firebase.ready()) {
    if (Firebase.getString(fbdo, "/PinEntrada")) {
      Serial.print(fbdo.dataType());
      if (fbdo.dataType() == "string" ) {
        return fbdo.stringData();
      } else {
        return "El dato no es un entero";
      }
    } else {
      return "Error al leer los datos: " + fbdo.errorReason();
    }
  } else {
    return "Firebase no está listo";
  }
}

String getWhoIsIt() {
  if (Firebase.ready()) {
    if (Firebase.getString(fbdo, "/whoIsIt")) {
      Serial.print(fbdo.dataType());
      if (fbdo.dataType() == "string") {
        return fbdo.stringData();
      } else {
        return "El dato no es un Nombre valido";
      }
    } else {
      return "Error al leer los datos: " + fbdo.errorReason();
    }
  } else {
    return "Firebase no está listo";
  }
}

void uploadSensorDataToFirestore() {
  updateSensorReadings();
  updateDateTime();
  documentCounter++; // Incrementar el contador cada vez que se suben datos.
  
  FirebaseJson firestore_data;
  firestore_data.set("fields/temperature/doubleValue", temperature);
  firestore_data.set("fields/humidity/doubleValue", humidity);
  firestore_data.set("fields/date/stringValue", currentDate);
  firestore_data.set("fields/time/stringValue", currentTime);
  Serial.println(firestore_data.raw());

  HTTPClient http;
  String document_name = currentDate + "-" + String(documentCounter);
  String firestore_url = "https://firestore.googleapis.com/v1/projects/your_project_id/databases/(default)/documents/TempMinuto?documentId=" + document_name;

  http.begin(firestore_url);
  http.addHeader("Content-Type", "application/json");

  // Usar POST para crear un nuevo documento
  int httpResponseCode = http.POST(firestore_data.raw());
  if (httpResponseCode > 0) {
    Serial.printf("Firestore Create: HTTP Response code: %d\n", httpResponseCode);
    String payload = http.getString();
    Serial.println("Response payload: " + payload);
    Serial.print("Document added successfully");
    
    // Actualizar el documentCounter en EEPROM
    EEPROM.write(EEPROM_ADDRESS, documentCounter);
    EEPROM.commit();
  } else {
    Serial.printf("Firestore Create: HTTP Error code: %d\n", httpResponseCode);
  }
  http.end();
}

void uploadTemperatureToRTDB() {
  if (Firebase.ready()) {
    if (Firebase.setFloat(fbdo, "/REFRIGERADOR/temperature/value", temperature)) {
      Serial.println("Temperature uploaded successfully to RTDB");
    } else {
      Serial.println("Failed to upload temperature: " + fbdo.errorReason());
    }
  }
}

String getExtraidosFromRTDB() {
  if (Firebase.ready()) {
    if (Firebase.getString(fbdo, "/realtime/Extraidos")) {
      Serial.print(fbdo.dataType());
      if (fbdo.dataType() == "string") {
        String extraidos = fbdo.stringData();
        Serial.println("Extraidos: " + extraidos);
        return extraidos;
      } else {
        Serial.println("El dato no es una cadena válida");
      }
    } else {
      Serial.println("Error al leer los datos: " + fbdo.errorReason());
    }
  } else {
    Serial.println("Firebase no está listo");
  }
  return "";
}

void checkKeypad() {
  char key = keypad.getKey();
  if (key) {
    Serial.println(key);
    if (key == '#') {
      contra = getPinEntrada();
      personaQueAbre = getWhoIsIt();
      if (inputCode.equals(contra)) {
        digitalWrite(ledG, HIGH);
        tone(buzzer, 2000, 100);
        myservo.write(90); // Abrir el servo
        delay(10000); // Esperar 10 segundos
        myservo.write(0); // Cerrar el servo
        digitalWrite(ledG, LOW);
        
        if (Firebase.ready()) {
          String rtdbTemp = getExtraidosFromRTDB();
          int counter = rtdbTemp.toInt();
          counter++;
          Firebase.setInt(fbdo, "/realtime/Extraidos", counter);
        }
        
        if (Firebase.ready()) {
          FirebaseJson rtdb_data;
          rtdb_data.set("/quien", personaQueAbre);
          rtdb_data.set("/hora", currentTime);
          rtdb_data.set("/fecha", currentDate);
          Firebase.updateNode(fbdo, "/realtime/Extraidos/Logs", rtdb_data);
        }
      }
      inputCode = "";
    } else if (key == '*') {
      inputCode = "";
    } else {
      inputCode += key;
    }
    
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Input: " + inputCode);
  }
}

void loop() {
  checkKeypad();
  unsigned long currentMillis = millis();
  if (currentMillis - previousMillisFirestore >= intervalFirestore) {
    previousMillisFirestore = currentMillis;
    uploadSensorDataToFirestore();
    uploadTemperatureToRTDB();
  }
  magnetico = digitalRead(sensorPuerta);
  if (magnetico == LOW) {
    lcd.clear();
    lcd.print("Puerta cerrada");
  }
}
