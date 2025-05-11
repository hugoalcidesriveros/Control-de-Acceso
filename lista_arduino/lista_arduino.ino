#include <Wire.h>
#include <LiquidCrystal_PCF8574.h>
#include <SPI.h>
#include <MFRC522.h>

#define SDA_PIN 9
#define RST_PIN 5
#define LED_ENTRADA 6    // Pin para el LED de entrada
#define LED_SALIDA 7    

#define BOTON_ENTRADA 2
#define BOTON_SALIDA 3

MFRC522 mfrc522(SDA_PIN, RST_PIN);
LiquidCrystal_PCF8574 lcd(0x27);

struct Usuario {
  byte uid[4];
  String nombre;
  String cargo;
  Usuario* siguiente;
};

Usuario* listaUsuarios = nullptr;
String currentTime = "00:00:00";
String lastMessage = "Escanear tarjeta";
String usuarionombre;

void setup() {
  Serial.begin(9600);
  lcd.begin(16, 2);
  lcd.setBacklight(1);
  lcd.print("Iniciando...");

  SPI.begin();
  mfrc522.PCD_Init();

  pinMode(BOTON_ENTRADA, INPUT_PULLUP);
  pinMode(BOTON_SALIDA, INPUT_PULLUP);

  delay(1000);
  lcd.clear();
  updateLCD();
}

void loop() {
  
 // Leer botones
  if (digitalRead(BOTON_ENTRADA) == LOW) {
    Serial.println("1");  // Entrada
    digitalWrite(LED_ENTRADA, HIGH);  // Encender LED entrada
    digitalWrite(LED_SALIDA, LOW);    // Apagar LED salida
    delay(300); // Antirebote simple
  } else if (digitalRead(BOTON_SALIDA) == LOW) {
    Serial.println("0");  // Salida
    digitalWrite(LED_SALIDA, HIGH);   // Encender LED salida
    digitalWrite(LED_ENTRADA, LOW);   // Apagar LED entrada
    delay(300);
  }
  // Procesar datos entrantes del serial
  
if (Serial.available()) {
    String data = Serial.readStringUntil('\n');
    data.trim();

    if (data.startsWith("HORA:")) {
      currentTime = data.substring(5);
      updateLCD();
    }
    else if (data.startsWith("REGISTRO:")) {
      int separatorIndex = data.indexOf(',', 9);
      if (separatorIndex != -1) {
        String nombre = data.substring(9, separatorIndex);
        String cargo = data.substring(separatorIndex + 1);
        agregarUsuario(mfrc522.uid.uidByte, nombre, cargo);
        lastMessage = "Registrado";
      
        updateLCD();
      }
    }
    else if (data.startsWith("INGRESO:") || data.startsWith("SALIDA:")) {
      lastMessage = data;
      updateLCD();
    }
  }

  // Leer tarjeta
  
if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    String uid = "";
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      uid += String(mfrc522.uid.uidByte[i] < 0x10 ? "0" : "");
      uid += String(mfrc522.uid.uidByte[i], HEX);
    }
    Serial.println(uid);
    mfrc522.PICC_HaltA();
    delay(300);
  }
}
void updateLCD() {
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Hora: " + currentTime);
  lcd.setCursor(0, 1);
  lcd.print(lastMessage);
  
}

bool tarjetaYaRegistrada(byte* uid) {
  Usuario* actual = listaUsuarios;
  while (actual != nullptr) {
    if (memcmp(actual->uid, uid, 4) == 0) {
      return true;
    }
    actual = actual->siguiente;
  }
  return false;
}

void agregarUsuario(byte* uid, String nombre, String cargo) {
  Usuario* nuevoUsuario = new Usuario;
  memcpy(nuevoUsuario->uid, uid, 4);
  nuevoUsuario->nombre = nombre;
  nuevoUsuario->cargo = cargo;
  nuevoUsuario->siguiente = listaUsuarios;
  listaUsuarios = nuevoUsuario;
}

void limpiarListaUsuarios() {
  Usuario* actual = listaUsuarios;
  while (actual != nullptr) {
    Usuario* temp = actual;
    actual = actual->siguiente;
    delete temp;
  }
  listaUsuarios = nullptr;
}
