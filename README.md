# Control-de-Acceso

Este proyecto tiene como objetivo utilizar tarjetas magnéticas en conjunto con Arduino y el módulo RC522, que permite leer las tarjetas y activar funciones específicas. Al hacerlo, se almacena el nombre del usuario en una base de datos, facilitando la gestión de acceso y registro. Además, se integra una interfaz gráfica desarrollada en Processing, que proporciona una visualización intuitiva y está conectada al sistema de Arduino para mejorar la interacción con el usuario
### Los dispositivos utilizados son:

- Arduino UNO
- Modulo RFID RC522
- Tarjetas RFID
- LCD 16x2-I2C
- LEDs
- 1 leds Verde
- 1 leds rojo

### Simuladores
- **El Arduino IDE**
El Arduino IDE (Integrated Development Environment) es un entorno de desarrollo que permite escribir, compilar y cargar código en microcontroladores Arduino de forma sencilla, utilizando un lenguaje basado en C/C++, ideal para desarrollar proyectos de electrónica y programación.
-**Proteus**
Proteus es un software de simulación y diseño electrónico que permite crear y probar circuitos integrados, microcontroladores y sistemas embebidos en un entorno virtual antes de implementarlos físicamente.
- **Fritzing**
Fritzing es un software de diseño y prototipado electrónico que facilita la creación de esquemas, diagramas de circuito y placas PCB, permitiendo a los usuarios visualizar y documentar proyectos de hardware de manera intuitiva.


### Objetivo
El dispositivo Arduino debe tener un lector de tarjetas magnéticas o llavero electrónico. Desde processing debe dar de alta (habilitar) una tarjeta. Notificar desde Arduino a Processing si una tarjeta (habilitada o no) quiere ingresar.


## Desarrollo del Proyecto de Control de Acceso
En esta segunda parte del proyecto, nos enfocaremos en la entrada y salida de personal de un auditorio. A través de la interfaz gráfica de Processing, se visualiza el proceso de ingreso y salida de cada persona en tiempo real.

### Funcionamiento:
- **Ingreso del personal**
Las tarjetas están preprogramadas para usuarios previamente registrados. Al pasar una tarjeta por el lector, se registra la entrada del usuario.

- **Registro de la hora de entrada**
El sistema registrará automáticamente la hora de entrada del usuario. Además, en Processing se mostrará un plano del auditorio, donde el sector correspondiente al usuario se resaltará en color amarillo, indicando gráficamente su ubicación. Al mismo tiempo, se encenderá un LED para señalar que el usuario está dentro del lugar.

- **Salida del personal**
Al marcar la tarjeta nuevamente para salir, el sistema registrará la hora de salida y actualizará la interfaz gráfica. El sector previamente ocupado por el usuario será restaurado a su color original (gris), indicando que la persona ha dejado ese espacio. Al mismo tiempo, se apagará un LED para señalar que el usuario se ha retirado del lugar.


## Esquema de Circuito Realizado en Fritzing
### Ingresa al archivo [Fritzing](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/esquema-aduino.fzz)
![](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/Circuito%20Arduino.jpg)

## Codigo en Arduino
Este código implementa un sistema de control de acceso basado en RFID con un lector MFRC522, una pantalla LCD y control de LEDs. Utiliza una lista enlazada de usuarios, donde cada uno tiene un UID, nombre y trabajo. Los usuarios se registran al escanear su tarjeta RFID, mostrando la información en la LCD. Además, permite encender o apagar LEDs mediante comandos seriales desde un programa como Processing. Se utiliza memoria dinámica con new para crear los usuarios y delete para liberar la memoria cuando ya no se necesita. La biblioteca LiquidCrystal_PCF8574 gestiona la pantalla LCD I2C, y la comunicación SPI se usa para interactuar con el lector RFID.
Para acceder al codigo hace click aca [Arduino](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/ArduinoControl-de-acceso_pin_13_prueba_bool.ino)

## Codigo en Processing
Este código en Processing gestiona un sistema de control de acceso basado en un lector de RFID, el cual se comunica a través de un puerto serial con un dispositivo Arduino. En la pantalla principal, el programa muestra un mensaje de bienvenida y una animación de puntos mientras espera la entrada de datos desde el lector de RFID. Cuando se recibe un identificador de usuario, el sistema verifica si coincide con algún usuario registrado, y si es así, muestra su nombre y rol en pantalla, además de registrar la hora de entrada o salida en un archivo de texto. La animación de los puntos en la pantalla sirve para dar feedback visual al usuario mientras el sistema espera. Los datos de cada usuario, como su nombre, rol y UID, se almacenan en una lista de objetos User, que también incluye la lógica para alternar entre los estados de "entrada" y "salida". Además, si no se detecta actividad durante un período de 10 segundos, el sistema vuelve automáticamente a la pantalla de inicio. Por último, el programa envía información al Arduino para controlar el hardware conectado, como los LEDs o cualquier otro componente relacionado con el acceso.
Para acceder al codigo hace click aca [Processing](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/Processing_archivos_y_leds.pde)
