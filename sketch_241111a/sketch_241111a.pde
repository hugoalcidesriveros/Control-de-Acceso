import processing.serial.*;
Serial myPort;
PrintWriter writer;

void setup() {
  size(400, 400);
  
  // Conectar al puerto serial donde Arduino está enviando los datos

  writer = createWriter("datos_usuarios.txt");
}

void draw() {
  if (myPort.available() > 0) {
    String inData = myPort.readStringUntil('\n');
    if (inData != null) {
      inData = trim(inData);
      println("Datos recibidos: " + inData); // Imprime los datos en la consola
      
      // Guardar los datos en el archivo
      writer.println(inData);
      writer.flush(); // Asegúrate de escribir los datos inmediatamente
    }
  }
}

void keyPressed() {
  // Cerrar el archivo cuando el usuario presiona una tecla
  writer.close();
  println("Archivo cerrado");
}
