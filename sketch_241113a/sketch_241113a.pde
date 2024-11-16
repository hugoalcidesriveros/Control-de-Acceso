import processing.serial.*;
import java.util.Date;

Serial myPort;
PrintWriter writer;
boolean alcidesEnabled = false;
boolean franEnabled = false;
boolean alcidesInside = false;
boolean franInside = false;

void setup() {
  size(400, 400);
  myPort = new Serial(this, "COM12", 9600); // Cambia "COM12" al puerto correcto
  writer = createWriter("datos_usuarios.txt");
  println("Esperando datos...");
}

void draw() {
  background(255);

  // Dibujar los sectores con color base (gris claro)
  fill(200);
  rect(50, 100, 150, 100);  // Rectángulo para Alcides
  rect(200, 100, 100, 100); // Cuadrado para Fran

  // Cambiar color de Alcides según el estado
  if (alcidesInside) {
    fill(255, 255, 0); // Amarillo cuando Alcides está adentro
    rect(50, 100, 150, 100);
  } else if (alcidesEnabled && !alcidesInside) {
    fill(200); // Gris cuando Alcides se ha retirado
    rect(50, 100, 150, 100);
  }

  // Cambiar color de Fran según el estado
  if (franInside) {
    fill(255, 255, 0); // Amarillo cuando Fran está adentro
    rect(200, 100, 100, 100);
  } else if (franEnabled && !franInside) {
    fill(200); // Gris cuando Fran se ha retirado
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

      // Manejo para Alcides
      if (inData.contains("Usuario registrado: Alcides")) {
        if (!alcidesEnabled) {
          alcidesEnabled = true;  // Habilitar acceso
          writer.println("Tarjeta Habilitada: Alcides - Hora: " + currentTime);
          writer.flush();
          println("Tarjeta Habilitada: Alcides - Hora: " + currentTime);
        } else if (!alcidesInside) {
          alcidesInside = true;  // Ingresar
          writer.println("Entrada: Alcides - Hora: " + currentTime);
          writer.flush();
          println("Entrada: Alcides - Hora: " + currentTime);
        } else {
          alcidesInside = false;  // Salir
          writer.println("Salida: Alcides - Hora: " + currentTime);
          writer.flush();
          println("Salida: Alcides - Hora: " + currentTime);
        }
      }
      
      // Manejo para Fran
      else if (inData.contains("Usuario registrado: Fran")) {
        if (!franEnabled) {
          franEnabled = true;  // Habilitar acceso
          writer.println("Tarjeta Habilitada: Fran - Hora: " + currentTime);
          writer.flush();
          println("Tarjeta Habilitada: Fran - Hora: " + currentTime);
        } else if (!franInside) {
          franInside = true;  // Ingresar
          writer.println("Entrada: Fran - Hora: " + currentTime);
          writer.flush();
          println("Entrada: Fran - Hora: " + currentTime);
        } else {
          franInside = false;  // Salir
          writer.println("Salida: Fran - Hora: " + currentTime);
          writer.flush();
          println("Salida: Fran - Hora: " + currentTime);
        }
      }
    }
  }
}

void keyPressed() {
  writer.close();
  println("Archivo cerrado");
}
