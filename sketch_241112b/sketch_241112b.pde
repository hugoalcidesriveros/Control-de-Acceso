import processing.serial.*;
import java.util.Date;

Serial myPort;
PrintWriter writer;
boolean alcidesEntry = false;
boolean franEntry = false;

void setup() {
  size(400, 400);
  myPort = new Serial(this, "COM12", 9600); // Cambia "COM12" al puerto correcto
  writer = createWriter("datos_usuarios.txt");
  println("Esperando datos...");
}

void draw() {
  background(255);

  // Dibujar los sectores con color base
  fill(200);
  rect(50, 100, 150, 100);  // Rectángulo para Alcides
  rect(200, 100, 100, 100); // Cuadrado para Fran

  // Control de color para los sectores en función de la entrada/salida
  if (alcidesEntry) {
    fill(255, 255, 0); // Amarillo si Alcides está adentro
    rect(50, 100, 150, 100);
  }

  if (franEntry) {
    fill(255, 255, 0); // Amarillo si Fran está adentro
    rect(200, 100, 100, 100);
  }

  // Leer datos del puerto serial
  if (myPort.available() > 0) {
    String inData = myPort.readStringUntil('\n');
    if (inData != null) {
      inData = trim(inData);
      println("Datos recibidos: " + inData);

      // Obtener la hora actual para los registros
      String currentTime = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);

      // Verificar si el mensaje es de Alcides o Fran y alternar entre entrada/salida
      if (inData.contains("Usuario registrado: Alcides")) {
        if (!alcidesEntry) {
          // Registrar entrada
          alcidesEntry = true;
          writer.println("Nombre: Alcides - Horario de entrada: " + currentTime);
          writer.flush();
          println("Datos guardados: Nombre: Alcides - Horario de entrada: " + currentTime);
        } else {
          // Registrar salida
          alcidesEntry = false;
          writer.println("Nombre: Alcides - Horario de salida: " + currentTime);
          writer.flush();
          println("Datos guardados: Nombre: Alcides - Horario de salida: " + currentTime);
        }
      } else if (inData.contains("Usuario registrado: Fran")) {
        if (!franEntry) {
          // Registrar entrada
          franEntry = true;
          writer.println("Nombre: Fran - Horario de entrada: " + currentTime);
          writer.flush();
          println("Datos guardados: Nombre: Fran - Horario de entrada: " + currentTime);
        } else {
          // Registrar salida
          franEntry = false;
          writer.println("Nombre: Fran - Horario de salida: " + currentTime);
          writer.flush();
          println("Datos guardados: Nombre: Fran - Horario de salida: " + currentTime);
        }
      }
    }
  }
}

void keyPressed() {
  writer.close();
  println("Archivo cerrado");
}
