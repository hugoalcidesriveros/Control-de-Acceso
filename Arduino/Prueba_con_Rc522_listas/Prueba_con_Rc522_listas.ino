#include <Wire.h>
#include <LiquidCrystal_PCF8574.h>
#include <SPI.h>
#include <MFRC522.h>

#define SDA_PIN 9
#define RST_PIN 5

MFRC522 mfrc522(SDA_PIN, RST_PIN);
LiquidCrystal_PCF8574 lcd(0x27);

struct NodoUsuario {
  byte id[4];
  String nombre;
  NodoUsuario* siguiente;
};

NodoUsuario* listaUsuarios = nullptr;
int contadorTarjetas = 0;

void setup() {
  Serial.begin(9600);
  Serial.println("Iniciando sistema...");

  lcd.begin(16, 2);
  lcd.setBacklight(1);
  lcd.print("Iniciando...");
  
  SPI.begin();
  mfrc522.PCD_Init();

  delay(1000);
  lcd.clear();
  lcd.print("Escanear tarjeta");
}

void loop() {
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    Serial.println("Tarjeta detectada.");
    lcd.clear();

    if (contadorTarjetas < 2) {
      registrarTarjeta();
    } else {
      if (verificarAcceso()) {
        lcd.print("Acceso autorizado");
      } else {
        lcd.print("Acceso denegado");
      }
    }

    delay(2000);
    lcd.clear();
    lcd.print("Escanear tarjeta");

    mfrc522.PICC_HaltA();
  }
}

void registrarTarjeta() {
  String nombre = (contadorTarjetas == 0) ? "Alcides" : "Fran";
  agregarUsuario(mfrc522.uid.uidByte, nombre);

  Serial.print("Usuario registrado: ");
  Serial.println(nombre);

  lcd.print("Registrado:");
  lcd.setCursor(0, 1);
  lcd.print(nombre);

  contadorTarjetas++;
}

bool verificarAcceso() {
  NodoUsuario* actual = listaUsuarios;
  while (actual != nullptr) {
    if (compararUID(actual->id, mfrc522.uid.uidByte)) {
      lcd.setCursor(0, 1);
      lcd.print(actual->nombre);
      Serial.print("Usuario registrado: ");
      Serial.println(actual->nombre);
      return true;
    }
    actual = actual->siguiente;
  }
  Serial.println("Acceso denegado.");
  return false;
}

bool compararUID(byte* uid1, byte* uid2) {
  for (byte i = 0; i < 4; i++) {
    if (uid1[i] != uid2[i]) {
      return false;
    }
  }
  return true;
}

void agregarUsuario(byte id[], String nombre) {
  NodoUsuario* nuevoUsuario = new NodoUsuario;
  memcpy(nuevoUsuario->id, id, 4);
  nuevoUsuario->nombre = nombre;
  nuevoUsuario->siguiente = listaUsuarios;
  listaUsuarios = nuevoUsuario;

  Serial.print("Nuevo usuario agregado: ");
  Serial.println(nombre);
}

void liberarListaUsuarios() {
  NodoUsuario* actual = listaUsuarios;
  while (actual != nullptr) {
    NodoUsuario* siguiente = actual->siguiente;
    delete actual;
    actual = siguiente;
  }
}
