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

  // Dibujar los sectores
  fill(200);
  rect(50, 100, 150, 100);  // Rectángulo para Alcides
  rect(200, 100, 100, 100); // Cuadrado para Fran

  // Control de color para los sectores
  if (alcidesEntry) {
    fill(255, 255, 0); // Amarillo para Alcides
    rect(50, 100, 150, 100);
  }

  if (franEntry) {
    fill(255, 255, 0); // Amarillo para Fran
    rect(200, 100, 100, 100);
  }

  // Leer datos del puerto serial
  if (myPort.available() > 0) {
    String inData = myPort.readStringUntil('\n');
    if (inData != null) {
      inData = trim(inData);
      println("Datos recibidos: " + inData);

      // Verificar si el mensaje es de Alcides o Fran
      if (inData.contains("Usuario registrado: Alcides") && !alcidesEntry) {
        alcidesEntry = true;
        String currentTime = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
        writer.println("Nombre: Alcides - Horario de entrada: " + currentTime);
        writer.flush();
        println("Datos guardados: Nombre: Alcides - Horario de entrada: " + currentTime);
      } else if (inData.contains("Usuario registrado: Fran") && !franEntry) {
        franEntry = true;
        String currentTime = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
        writer.println("Nombre: Fran - Horario de entrada: " + currentTime);
        writer.flush();
        println("Datos guardados: Nombre: Fran - Horario de entrada: " + currentTime);
      }
    }
  }
}

void keyPressed() {
  writer.close();
  println("Archivo cerrado");
}
