import processing.serial.*;
import java.io.PrintWriter;

// Variables de estado
boolean mostrandoPantallaInicio = true;
String mensajeEstado = "Esperando...";
String nombreUsuario = "";
String rolUsuario = "";
String estadoEntradaSalida = "";

// Variables para la animación de los puntos
int puntoActual = 0; // Comienza desde el primer punto (izquierda)
int intervalo = 500; // Intervalo entre cambios (milisegundos)
int ultimoCambio = 0; // Registro del tiempo del último cambio

// Temporizador de inactividad
int tiempoUltimoEscaneo = 0; // Registro del último escaneo
int tiempoInactividad = 10000; // Tiempo de inactividad (10 segundos)

// Puerto serial y archivo de escritura
Serial myPort;
PrintWriter writer;

// Lista de usuarios con sus datos de sector, nombre, y UID
User[] users = {
  new User("Alcides", "Iluminador", "UID: 8E-73-90-2", 50, 100, 150, 100),
  new User("Francisco", "Sonidista", "UID: B3-F-7E-14", 250, 100, 100, 100),
  new User("Pablo", "Electricista", "UID: 38540869", 400, 100, 100, 100),
  new User("Rubén", "Directora", "UID: 5796692", 200, 250, 150, 100)
};

void setup() {
  size(600, 400); // Tamaño de la ventana
  textAlign(CENTER, CENTER); // Centrar texto
  
  // Configurar puerto serial
  myPort = new Serial(this, "COM12", 9600); //puerto correcto
  writer = createWriter("datos_usuarios.txt"); // Archivo para guardar los datos
}

void draw() {
  background(50); // Fondo oscuro

  // Verificar si ha pasado el tiempo de inactividad
  if (!mostrandoPantallaInicio && millis() - tiempoUltimoEscaneo > tiempoInactividad) {
    regresarPantallaInicio();
  }

  // División de la pantalla
  float topHeight = height * 0.2; // 20% de la pantalla
  float bottomHeight = height * 0.8; // 80% de la pantalla

  if (mostrandoPantallaInicio) {
    // Pantalla de inicio (parte superior)
    fill(255); // Texto blanco
    textSize(48);
    text("Bienvenido", width / 2, height / 2 - topHeight / 4); // Título centrado
    textSize(24);
    text(mensajeEstado, width / 2, height / 2 + topHeight / 4); // Mensaje de estado centrado

    // Animación de los puntos
    mostrarPuntosAnimados(width / 2, height / 2 + topHeight / 4 + 40);
  } else {
    // Interfaz principal
    fill(255); // Texto blanco
    textSize(24);
    text("Usuario: " + nombreUsuario, width / 2, topHeight / 2 + 20); // Nombre centrado
    text("Rol: " + rolUsuario, width / 2, topHeight / 2 + 60); // Rol centrado
    text(estadoEntradaSalida, width / 2, topHeight / 2 + 100); // Estado (Entrada/Salida)

    // Dibujar los sectores para cada usuario en la parte inferior
    for (int i = 0; i < users.length; i++) {
      users[i].drawSector(bottomHeight);
    }
  }

  // Leer datos del puerto serial
  if (myPort.available() > 0) {
    String inData = myPort.readStringUntil('\n');
    if (inData != null) {
      inData = trim(inData);
      println("Datos recibidos: " + inData);

      // Obtener la hora actual para los registros
      String currentTime = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);

      // Procesar entrada/salida según el UID
      for (int i = 0; i < users.length; i++) {
        if (inData.contains(users[i].uid)) {
          users[i].processEntryExit(currentTime);
          nombreUsuario = users[i].name; // Establecer nombre del usuario
          rolUsuario = users[i].role; // Establecer rol del usuario
          estadoEntradaSalida = users[i].isEntry ? "Saliendo" : "Entrando"; // Establecer estado
          mostrandoPantallaInicio = false; // Mostrar la pantalla de usuario
          tiempoUltimoEscaneo = millis(); // Registrar el momento del último escaneo
          break;
        }
      }
    }
  }
}

// Función para mostrar los puntos animados
void mostrarPuntosAnimados(float xCentro, float yBase) {
  int radio = 10; // Radio de los puntos
  int separacion = 20; // Separación entre puntos

  // Dibujar cinco puntos
  for (int i = 0; i < 5; i++) {
    if (i == puntoActual) {
      fill(255); // Puntos encendidos en blanco
    } else {
      fill(100); // Puntos apagados en gris
    }
    ellipse(xCentro - (2 * separacion) + i * separacion, yBase, radio, radio);
  }

  // Controlar la animación con un temporizador
  if (millis() - ultimoCambio > intervalo) {
    puntoActual++; // Mover al siguiente punto (de izquierda a derecha)
    if (puntoActual > 4) {
      puntoActual = 0; // Reiniciar al primer punto
    }
    ultimoCambio = millis();
  }
}

// Función para regresar a la pantalla de inicio
void regresarPantallaInicio() {
  mostrandoPantallaInicio = true;
  nombreUsuario = "";
  rolUsuario = "";
  estadoEntradaSalida = "";
}

class User {
  String name;
  String role;
  String uid;
  int x, y, w, h;
  boolean isEntry = false;

  User(String name, String role, String uid, int x, int y, int w, int h) {
    this.name = name;
    this.role = role;
    this.uid = uid;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void drawSector(float bottomHeight) {
    // Cambiar el color del sector si el usuario está dentro (amarillo)
    if (isEntry) {
      fill(255, 255, 0); // Amarillo
    } else {
      fill(0); // Gris por defecto
    }
    rect(x, y + bottomHeight * 0.1, w, h); // Subir las áreas para no estar tan pegados al borde
    fill(255); // Color blanco para el texto
    textSize(12); // Tamaño de texto
    textAlign(CENTER, CENTER); // Alinear el texto en el centro
    text(role, x + w / 2, y + h / 2 + bottomHeight * 0.1); // Escribe el texto dentro del sector
  }

  void processEntryExit(String currentTime) {
    if (!isEntry) {
      // Registrar entrada
      writer.println("Nombre: " + name + " (" + role + ") - Horario de entrada: " + currentTime);
      writer.flush();
      println("Datos guardados: Nombre: " + name + " (" + role + ") - Horario de entrada: " + currentTime);
    } else {
      // Registrar salida
      writer.println("Nombre: " + name + " (" + role + ") - Horario de salida: " + currentTime);
      writer.flush();
      println("Datos guardados: Nombre: " + name + " (" + role + ") - Horario de salida: " + currentTime);
    }
    isEntry = !isEntry; // Alternar estado
  }
}

void keyPressed() {
  if (key == 'r') { // Regresa a la pantalla de inicio manualmente
    regresarPantallaInicio();
  }
}
