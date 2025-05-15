import processing.serial.*;
import controlP5.*;
import java.util.ArrayList;
import gifAnimation.*;
import java.io.PrintWriter;


// ======================
// ESTRUCTURAS DE DATOS
// ======================
class User {
  String uid;
  String nombreApellido;
  String cargo;
  
  User(String uid, String nombreApellido, String cargo) {
    this.uid = uid;
    this.nombreApellido = nombreApellido;
    this.cargo = cargo;
  }
}

class BotonEliminar {
  int x, y, ancho = 140, alto = 40;
  boolean hover = false, presionado = false;
  
  BotonEliminar() {
    x = 550;
    y = 310;
  }
}

class DialogoConfirmacion {
  boolean visible = false;
  String uid = "";
  String mensaje = "";
  boolean hoverSi = false;
  boolean hoverNo = false;
}

// ======================
// ENUMERACIONES Y CONSTANTES
// ======================
enum AppState {
  WAITING_CARD,
  NEW_CARD_DETECTED, 
  REGISTERED_CARD_DETECTED,
  DELETE_MODE,
  CONFIRM_DIALOG
}

final int DISPLAY_MESSAGE_TIME = 3000;
final int SEND_TIME_INTERVAL = 1000;
final color COLOR_ENTRADA = color(50, 255, 50);
final color COLOR_SALIDA = color(255, 50, 50);

// ======================
// VARIABLES GLOBALES                                                    =============VARIABLES GLOBALES================    
// ======================
// Hardware/Comunicación
Serial myPort;
boolean esEntrada = true;

// Datos
ArrayList<User> userList = new ArrayList<User>();
String uid = "";
String nombreUsuario = "";
String estadoUsuario = "";
color colorEstado;

// Interfaz
ControlP5 cp5;
Textfield inputField, cargoField;
BotonEliminar botonEliminar = new BotonEliminar();
DialogoConfirmacion dialogo = new DialogoConfirmacion();
Gif gif;

// Tiempo y estado
AppState currentState = AppState.WAITING_CARD;
int tiempoDisplay = 0;
int lastTimeSent = 0;
int ultimoClick = 0;
String lastMessage = "";

// ======================
// FUNCIONES PRINCIPALES                                                     ===============FUNCIONES PRINCIPALES====================
// ======================
void setup() {
  size(800, 400);
  frameRate(60);
  
  setupSerial();
  setupUI();
  loadUserData();
  setupGif();
}

void draw() {
  updateSystem();
  renderUI();
}

// ======================
// INICIALIZACIÓN                                                                ================INICIALIZACIÓN===============
// ======================
void setupSerial() {
  myPort = new Serial(this, "COM12", 9600);
  myPort.bufferUntil('\n');
}

void setupUI() {
  cp5 = new ControlP5(this);
  
  inputField = cp5.addTextfield("Nombre y Apellido")
    .setPosition(300, 175).setSize(300, 30)
    .setVisible(false);
    
  cargoField = cp5.addTextfield("Cargo")
    .setPosition(300, 225).setSize(300, 30)
    .setVisible(false);
    
  cp5.addButton("cancelarRegistro")
    .setPosition(330, 275).setSize(150, 30)
    .setLabel("Cancelar").setVisible(true);
}

void loadUserData() {
  String[] lines = loadStrings("usuarios.txt");
  if (lines != null) {
    for (String line : lines) {
      String[] parts = line.split(",");
      if (parts.length >= 3) {
        userList.add(new User(parts[0], parts[1], parts[2]));
      }
    }
  }
}

void setupGif() {
  gif = new Gif(this, "gif.gif");
  gif.loop();
}

// ======================
// LÓGICA PRINCIPAL                                                                ==============LÓGICA PRINCIPAL=============
// ======================
void updateSystem() {
  updateTimers();
  updateButtonStates();
}

void updateTimers() {
  if (millis() - lastTimeSent > SEND_TIME_INTERVAL) {
    sendTimeToArduino();
    lastTimeSent = millis();
  }
  
  if (currentState == AppState.REGISTERED_CARD_DETECTED && 
      millis() - tiempoDisplay > DISPLAY_MESSAGE_TIME) {
    changeState(AppState.WAITING_CARD);
  }
}

void updateButtonStates() {
  // Actualizar estado hover del botón eliminar
  botonEliminar.hover = mouseX > botonEliminar.x && 
                        mouseX < botonEliminar.x + botonEliminar.ancho &&
                        mouseY > botonEliminar.y && 
                        mouseY < botonEliminar.y + botonEliminar.alto;
}

// ======================
// MANEJO DE ESTADOS                                                              ===================MANEJO DE ESTADOS=================
// ======================
void changeState(AppState newState) {
  switch(currentState) {
    case NEW_CARD_DETECTED:
      inputField.setVisible(false);
      cargoField.setVisible(false);
      break;
    case DELETE_MODE:
      dialogo.visible = false;
      break;
  }
  currentState = newState;
  tiempoDisplay = millis();
}

// ======================
// RENDERIZADO                                                                    ======================RENDERIZADO===================
// ======================
void renderUI() {
  renderBackground();
  renderMainPanel();
  
  switch(currentState) {
    case WAITING_CARD:
      renderWaitingState();
      break;
    case NEW_CARD_DETECTED:
      renderNewCardState();
      break;
    case REGISTERED_CARD_DETECTED:
      renderRegisteredCardState();
      break;
    case DELETE_MODE:
      renderDeleteMode();
      break;
    case CONFIRM_DIALOG:
      renderConfirmDialog();
      break;
  }
  
  renderCommonElements();
}

void renderBackground() {
  background(0);
  image(gif, 0, 0, width, height);
}

void renderMainPanel() {
  fill(50, 180);
  noStroke();
  rect(100, 50, 600, 300, 20);
}

void renderWaitingState() {
  fill(255);
  textSize(24);
  textAlign(CENTER);
  text("Acerca la tarjeta al lector", width/2, height/2);
}

void renderNewCardState() {
  fill(255);
  textSize(20);
  text("Nueva tarjeta detectada", 300, 100);
  text("UID: " + uid, 300, 140);
  
  inputField.setVisible(true);
  cargoField.setVisible(true);
}

void renderRegisteredCardState() {
  fill(colorEstado);
  textSize(36);
  textAlign(CENTER);
  text(nombreUsuario, width/2, height/2 - 30);
  textSize(28);
  text(estadoUsuario, width/2, height/2 + 20);
}

void renderCommonElements() {
  dibujarBotonEliminar();
  
  if (!lastMessage.isEmpty()) {
    fill(0, 255, 0);
    textAlign(CENTER);
    text(lastMessage, width/2, height - 30);
  }
}

// ======================
// FUNCIONES DE SERIAL                                                  =========================FUNCIONES DE SERIAL====================
// ======================
void serialEvent(Serial port) {
  String message = port.readStringUntil('\n').trim();
  println("Mensaje recibido: " + message); // Debug
  
  if (message.equals("1")) {
    esEntrada = true;
  } else if (message.equals("0")) {
    esEntrada = false;
  } else {
    processCardUID(message);
  }
}

void processCardUID(String uid) {
  this.uid = uid;
  User user = getUserByUID(uid);
  
  // 1. Primero verificar si estamos en modo eliminación
  if (currentState == AppState.DELETE_MODE) {
    if (user != null) {
      dialogo.visible = true;
      dialogo.uid = uid;
      dialogo.mensaje = "¿Eliminar a " + user.nombreApellido + "?";
      currentState = AppState.CONFIRM_DIALOG;
      println("Mostrando diálogo para eliminar: " + user.nombreApellido);
    } else {
      lastMessage = "Tarjeta no registrada";
      tiempoDisplay = millis();
      println("Tarjeta no registrada: " + uid);
    }
    return; // Importante salir aquí para no procesar otros estados
  }
  
  // 2. Manejar otros estados
  if (user == null) {
    // Tarjeta no registrada - modo registro
    changeState(AppState.NEW_CARD_DETECTED);
    println("Nueva tarjeta detectada: " + uid);
  } else {
    // Tarjeta registrada - procesar entrada/salida
    processRegisteredUser(user);
    println("Tarjeta registrada: " + user.nombreApellido);
  }
}
void processRegisteredUser(User user) {
  nombreUsuario = user.nombreApellido;
  
  if (esEntrada) {
    estadoUsuario = "ENTRADA";
    colorEstado = COLOR_ENTRADA;
    myPort.write("INGRESO:" + nombreUsuario + "\n");
  } else {
    estadoUsuario = "SALIDA";
    colorEstado = COLOR_SALIDA;
    myPort.write("SALIDA:" + nombreUsuario + "\n");
  }
  
  saveTimeLog(uid, nombreUsuario, estadoUsuario);
  changeState(AppState.REGISTERED_CARD_DETECTED);
}

// ======================
// FUNCIONES AUXILIARES                                                      =======================FUNCIONES AUXILIARES===================
// ======================
User getUserByUID(String uid) {
  for (User user : userList) {
    if (user.uid.equals(uid)) {
      return user;
    }
  }
  return null;
}

void printUserList() {
  println("=== LISTA DE USUARIOS ===");
  for (User u : userList) {
    println(u.uid + " - " + u.nombreApellido);
  }
  println("=========================");
}

void saveUserData() {
  String[] lines = new String[userList.size()];
  for (int i = 0; i < userList.size(); i++) {
    User u = userList.get(i);
    lines[i] = u.uid + "," + u.nombreApellido + "," + u.cargo;
  }
  saveStrings("usuarios.txt", lines);
  println("Datos guardados. Total usuarios: " + userList.size()); // Debug
  printUserList(); // Debug
}

// ======================
// INTERACCIÓN CON USUARIO                                                   =======================INTERACCIÓN CON USUARIO======================
// ======================
void keyPressed() {
  if (key != '\n' || currentState != AppState.NEW_CARD_DETECTED) return;

  String nombreApellido = inputField.getText().trim();
  String cargo = cargoField.getText().trim();

  if (nombreApellido.isEmpty() || cargo.isEmpty()) {
    lastMessage = "Error: Complete todos los campos";
    tiempoDisplay = millis();
    return;
  }

  User nuevoUsuario = new User(uid, nombreApellido, cargo);
  userList.add(nuevoUsuario);
  saveUserData();
  
  inputField.clear().setVisible(false);
  cargoField.clear().setVisible(false);
  
  lastMessage = "Usuario registrado: " + nombreApellido;
  changeState(AppState.WAITING_CARD);
}

void mousePressed() {
  if (millis() - ultimoClick < 300) return;
  ultimoClick = millis();

  if (mouseButton == LEFT) {
    // Verificar clic en botones del diálogo primero
    if (dialogo.visible) {
      if (mouseX > width/2-80 && mouseX < width/2-10 && 
          mouseY > height/2+10 && mouseY < height/2+50) {
        confirmarEliminacionSi();
        return;
      }
      else if (mouseX > width/2+10 && mouseX < width/2+80 && 
               mouseY > height/2+10 && mouseY < height/2+50) {
        confirmarEliminacionNo();
        return;
      }
    }
    
    // Luego verificar otros botones
    if (!dialogo.visible && botonEliminar.hover) {
      activarEliminacion();
    }
  }
}

// ======================
// FUNCIONES DE ELIMINACIÓN                                                           =================FUNCIONES DE ELIMINACIÓN=====================
// ======================
void activarEliminacion() {
  changeState(AppState.DELETE_MODE);
  lastMessage = "Modo eliminación: Pase la tarjeta a eliminar";
}

void confirmarEliminacionSi() {
  if (dialogo.uid != null && !dialogo.uid.isEmpty()) {
    for (int i = userList.size() - 1; i >= 0; i--) {
      if (userList.get(i).uid.equals(dialogo.uid)) {
        String nombreEliminado = userList.get(i).nombreApellido;
        userList.remove(i);
        saveUserData();
        lastMessage = "Usuario eliminado: " + nombreEliminado;
        println("Usuario eliminado: " + nombreEliminado); // Debug
        break;
      }
    }
  } else {
    lastMessage = "Error: No se pudo eliminar";
  }
  limpiarDespuesDeEliminacion();
}

void confirmarEliminacionNo() {
  lastMessage = "Eliminación cancelada";
  limpiarDespuesDeEliminacion();
}

void despedirEmpleado(String uidOBuscar) {
  for (int i = userList.size() - 1; i >= 0; i--) {
    if (userList.get(i).uid.equals(uidOBuscar)) {
      userList.remove(i);
      saveUserData();
      break;
    }
  }
}

void limpiarDespuesDeEliminacion() {
  dialogo.visible = false;
  dialogo.uid = "";
  dialogo.mensaje = "";
  changeState(AppState.WAITING_CARD);
}

// ======================
// FUNCIONES DE VISUALIZACIÓN                                                ===================FUNCIONES DE VISUALIZACIÓN===================
// ======================

void cancelarRegistro() {
  // Limpiar campos y mensajes
  inputField.clear();
  cargoField.clear();
  lastMessage = "Operación cancelada";
  
  // Ocultar campos
  inputField.setVisible(false);
  cargoField.setVisible(false);
  
  // Volver al estado inicial
  changeState(AppState.WAITING_CARD);
  
  println("Registro cancelado - Volviendo al estado inicial");
}

void dibujarBotonEliminar() {
  noStroke();
  fill(botonEliminar.presionado ? color(0, 50, 150) : 
       botonEliminar.hover ? color(0, 100, 200) : color(0, 150, 255));
  rect(botonEliminar.x, botonEliminar.y, botonEliminar.ancho, botonEliminar.alto, 5);

  fill(255);
  textAlign(CENTER, CENTER);
  textSize(16);
  text("Eliminar Usuario", botonEliminar.x + botonEliminar.ancho/2, 
                          botonEliminar.y + botonEliminar.alto/2);
  textAlign(LEFT);
}

void renderDeleteMode() {
  fill(255, 255, 0);
  textSize(24);
  textAlign(CENTER);
  text("Pase la tarjeta para eliminar usuario", width/2, height/2);
  
  // Agregar texto adicional para mejor feedback
  textSize(16);
  text("Modo eliminación activo", width/2, height/2 + 30);
}

void renderConfirmDialog() {
  fill(0, 150);
  noStroke();
  rect(0, 0, width, height);

  fill(70);
  rect(width/2-200, height/2-100, 400, 200, 15);

  fill(240);
  textAlign(CENTER);
  text("Confirmar", width/2, height/2-70);
  text(dialogo.mensaje, width/2, height/2-30);
  
  dibujarBotonConfirmacion("Sí", width/2-80, height/2+10, dialogo.hoverSi);
  dibujarBotonConfirmacion("No", width/2+10, height/2+10, dialogo.hoverNo);
}

void dibujarBotonConfirmacion(String label, float x, float y, boolean hover) {
  noStroke();
  fill(hover ? (label.equals("Sí") ? color(120, 220, 120) : color(220, 120, 120)) : 
               (label.equals("Sí") ? color(100, 200, 100) : color(200, 100, 100)));
  rect(x, y, 70, 40, 5);

  fill(0);
  textAlign(CENTER, CENTER);
  text(label, x + 35, y + 20);
}
// ======================
// FUNCION  PARA ENVIAR HORA                                        ======================FUNCION  PARA ENVIAR HORA=====================
// ======================

void sendTimeToArduino() {
  if (myPort == null) {
    println("Error: Puerto serial no inicializado");
    return;
  }
  
  String currentTime = nf(hour(), 2) + ":" + nf(minute(), 2) + ":" + nf(second(), 2);
  String message = "HORA:" + currentTime + "\n"; // Asegurar el salto de línea
  
  myPort.write(message);
}

// ======================
// FUNCIONES DE ARCHIVOS                                              ======================FUNCIONES DE ARCHIVOS========================
// ======================

void saveTimeLog(String uid, String nombre, String accion) {
  String registro = String.format("%02d/%02d/%04d,%02d:%02d:%02d,%s,%s,%s", 
    day(), month(), year(), hour(), minute(), second(), uid, nombre, accion);
  saveStrings("registro_horarios.txt", appendToFile("registro_horarios.txt", new String[]{registro}));
}

String[] appendToFile(String filename, String[] newLines) {
  String[] existingLines = {};
  try {
    existingLines = loadStrings(filename);
  } catch (Exception e) {
    println("Creando archivo nuevo: " + filename);
  }
  
  String[] allLines = new String[existingLines.length + newLines.length];
  System.arraycopy(existingLines, 0, allLines, 0, existingLines.length);
  System.arraycopy(newLines, 0, allLines, existingLines.length, newLines.length);
  
  return allLines;
}
