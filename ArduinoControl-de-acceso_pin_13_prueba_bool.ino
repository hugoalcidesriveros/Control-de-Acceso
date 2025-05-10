#include <Wire.h>
#include <LiquidCrystal_PCF8574.h>
#include <SPI.h>
#include <MFRC522.h>

#define SDA_PIN 9
#define RST_PIN 5

MFRC522 mfrc522(SDA_PIN, RST_PIN);
LiquidCrystal_PCF8574 lcd(0x27);

class Usuario {
public:
  byte id[4];
  String nombre;
  String trabajo;
  Usuario* siguiente;

  Usuario(byte* uid, String nombre, String trabajo) {
    memcpy(this->id, uid, 4);
    this->nombre = nombre;
    this->trabajo = trabajo;
    this->siguiente = nullptr;
  }

  bool compararUID(byte* uid) {
    for (byte i = 0; i < 4; i++) {
      if (this->id[i] != uid[i]) {
        return false;
      }
    }
    return true;
  }
};

Usuario* listaUsuarios = nullptr;
int contadorTarjetas = 0;
int valorRecibido = 0; // Variable para almacenar el valor recibido
const int led1 = 3;
const int led2 = 2;
const int led3 = 4;
const int led4 = 6;

// Variables booleanas para controlar el estado de cada LED
bool estadoLed1 = false;
bool estadoLed2 = false;
bool estadoLed3 = false;
bool estadoLed4 = false;


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


  pinMode(led1, OUTPUT);
  digitalWrite(led1, LOW); // Asegurarse de que el LED esté apagado inicialmente
  pinMode(led2, OUTPUT);
  digitalWrite(led2, LOW); // Asegurarse de que el LED esté apagado inicialmente
  pinMode(led3, OUTPUT);
  digitalWrite(led3, LOW); // Asegurarse de que el LED esté apagado inicialmente
  pinMode(led4, OUTPUT);
  digitalWrite(led3, LOW); // Asegurarse de que el LED esté apagado inicialmente

  
}

void loop() {
  if (mfrc522.PICC_IsNewCardPresent() && mfrc522.PICC_ReadCardSerial()) {
    Serial.println("Tarjeta detectada.");

    lcd.clear();
    Serial.print("UID: ");
    for (byte i = 0; i < mfrc522.uid.size; i++) {
      Serial.print(mfrc522.uid.uidByte[i], HEX);
      if (i < mfrc522.uid.size - 1) {
        Serial.print("-");
      }
    }
    Serial.println(); // Al final, solo se agrega el salto de línea para finalizar la línea

    if (tarjetaYaRegistrada()) {
      mostrarUsuario();
    } else if (contadorTarjetas < 4) {
      registrarTarjeta();
    } else {
      lcd.print("No hay espacio");
      Serial.println("Máximo número de usuarios alcanzado.");
    }

    delay(2000); // Espera 2 segundos antes de continuar
    lcd.clear();
    lcd.print("Escanear tarjeta");

    mfrc522.PICC_HaltA();
  }

  
if (Serial.available() > 0) { // Verificar si hay datos disponibles en el puerto serial
    valorRecibido = Serial.read() - 0; // Leer el valor enviado desde Processing y convertirlo a número

    switch (valorRecibido) {
      case 1:
        estadoLed1 = !estadoLed1; // Alternar estado del LED 1
        digitalWrite(led1, estadoLed1 ? HIGH : LOW); // Cambiar estado del LED
        Serial.println(estadoLed1 ? "LED 1 Encendido" : "LED 1 Apagado");
        break;
      case 2:
        estadoLed2 = !estadoLed2; // Alternar estado del LED 2
        digitalWrite(led2, estadoLed2 ? HIGH : LOW); // Cambiar estado del LED
        Serial.println(estadoLed2 ? "LED 2 Encendido" : "LED 2 Apagado");
        break;
      case 3:
        estadoLed3 = !estadoLed3; // Alternar estado del LED 3
        digitalWrite(led3, estadoLed3 ? HIGH : LOW); // Cambiar estado del LED
        Serial.println(estadoLed3 ? "LED 3 Encendido" : "LED 3 Apagado");
        break;
      case 4:
        estadoLed4 = !estadoLed4; // Alternar estado del LED 4
        digitalWrite(led4, estadoLed4 ? HIGH : LOW); // Cambiar estado del LED
        Serial.println(estadoLed4 ? "LED 4 Encendido" : "LED 4 Apagado");
        break;
      default:
        Serial.println("Comando no válido");
        break;
    }
  }
}

bool tarjetaYaRegistrada() {
  Usuario* actual = listaUsuarios;
  while (actual != nullptr) {
    if (actual->compararUID(mfrc522.uid.uidByte)) {
      return true;
    }
    actual = actual->siguiente;
  }
  return false;
}

void mostrarUsuario() {
  Usuario* actual = listaUsuarios;
  while (actual != nullptr) {
    if (actual->compararUID(mfrc522.uid.uidByte)) {
      lcd.print("Usuario:");
      lcd.setCursor(0, 1);
      lcd.print(actual->nombre);

      Serial.print("Usuario registrado: ");
      Serial.println(actual->nombre);
      Serial.print("Trabajo: ");
      Serial.println(actual->trabajo);
      return;
    }
    actual = actual->siguiente;
  }
  lcd.print("Usuario no encontrado");
}

void registrarTarjeta() {
  String nombre, trabajo;

  // Asigna nombres y trabajos según el contador de tarjetas
  switch (contadorTarjetas) {
    case 0: nombre = "Alcides"; trabajo = "Iluminador"; break;
    case 1: nombre = "Fran"; trabajo = "Sonidista"; break;
    case 2: nombre = "Luis"; trabajo = "Electricista"; break;
    case 3: nombre = "Ana"; trabajo = "Directora"; break;
  }

  agregarUsuario(mfrc522.uid.uidByte, nombre, trabajo);

  Serial.print("Usuario registrado: ");
  Serial.println(nombre);
  Serial.print("Trabajo: ");
  Serial.println(trabajo);

  lcd.print("Registrado:");
  lcd.setCursor(0, 1);
  lcd.print(nombre);

  contadorTarjetas++;
}

void agregarUsuario(byte id[], String nombre, String trabajo) {
  Usuario* nuevoUsuario = new Usuario(id, nombre, trabajo);
  nuevoUsuario->siguiente = listaUsuarios;
  listaUsuarios = nuevoUsuario;

  Serial.print("Nuevo usuario agregado: ");
  Serial.println(nombre);
}

void liberarListaUsuarios() {
  Usuario* actual = listaUsuarios;
  while (actual != nullptr) {
    Usuario* siguiente = actual->siguiente;
    delete actual;
    actual = siguiente;
  }
}
