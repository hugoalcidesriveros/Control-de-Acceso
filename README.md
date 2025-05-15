# Control-de-Acceso

Este proyecto tiene como objetivo utilizar tarjetas magnéticas en conjunto con Arduino y el módulo RC522, que permite leer las tarjetas y activar funciones específicas. Al hacerlo, se almacena el nombre del usuario en una base de datos, facilitando la gestión de acceso y registro. Además, se integra una interfaz gráfica desarrollada en Processing, que proporciona una visualización intuitiva y está conectada al sistema de Arduino para mejorar la interacción con el usuario. Se identifican tarjetas magnéticas para:

✔ Registrar nuevos usuarios (almacenando nombre y cargo en una base de datos local)

✔ Registrar entradas/salidas (con confirmación mediante botones físicos y LEDs)

✔ Eliminar usuarios (desde una interfaz gráfica segura)

#Interfaz en Processing

La interfaz desarrollada en Processing complementa el sistema brindando:

- Visualización en tiempo real de operaciones
- Gestión intuitiva de usuarios
- Historial completo de movimientos

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

- **Fritzing**
Fritzing es un software de diseño y prototipado electrónico que facilita la creación de esquemas, diagramas de circuito y placas PCB, permitiendo a los usuarios visualizar y documentar proyectos de hardware de manera intuitiva.


### Objetivo
El objetivo de este proyecto es implementar un sistema de control de acceso que permita:

- Registrar usuarios de manera segura mediante identificación por tarjeta magnética o llavero electrónico.
- Monitorear y registrar las entradas y salidas del personal en tiempo real.
- Generar una base de datos centralizada con todos los movimientos (registros, accesos y salidas) almacenados en archivos para su posterior análisis y consulta."


## Desarrollo del Proyecto de Control de Acceso
En esta segunda parte del proyecto, nos enfocaremos en la entrada y salida de personal. A través de la interfaz gráfica de Processing, se visualiza el proceso de ingreso y salida de cada persona en tiempo real.

### Funcionamiento:
- **Ingreso del personal**
Cada tarjeta posee un UID único que, una vez registrado, queda asociado a un usuario específico. Al pasar la tarjeta por el lector, el sistema identifica al usuario y registra automáticamente su hora de entrada.

- **Registro de la hora de entrada**
Luego de Registrarse, al pasar nuevamente la tarjeta el sistema registrará automáticamente la hora de entrada del usuario. Al pasar la tarjeta, Processing mostrará el nombre del usuario junto con el mensaje 'Entrando', mientras un LED verde se encenderá para confirmar el acceso. Simultáneamente, el LCD conectado a Arduino mostrará el nombre y la hora exacta de entrada.

- **Salida del personal**
Al marcar la tarjeta nuevamente para salir, el sistema registrará la hora de salida y actualizará la interfaz gráfica, mostrará el nombre del usuario junto con el mensaje 'Saliendo'. mientras un LED rojo se encenderá para confirmar la salida. Simultáneamente, el LCD conectado a Arduino mostrará el nombre y la hora exacta de salida.

- **Eliminar Usuario**
La interfaz gráfica de Processing cuenta con un botón 'Eliminar' para remover usuarios registrados. Al ejecutarse esta acción, se mostrará el mensaje 'Usuario eliminado' tanto en la interfaz de Processing como en el LCD conectado a Arduino. Simultáneamente, el UID de la tarjeta eliminada quedará disponible para ser asignado a un nuevo usuario.


## Esquema de Circuito Realizado en Fritzing
### Ingresa al archivo [Fritzing](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/esquema-aduino.fzz)
![](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/Circuito%20Arduino.jpg)

## Codigo en Arduino
Este código implementa un sistema de control de acceso basado en RFID con un lector MFRC522, una pantalla LCD y control de LEDs. Utiliza una lista enlazada de usuarios, donde cada uno tiene un UID, nombre y trabajo. Los usuarios se registran al escanear su tarjeta RFID, mostrando la información en la LCD. Además, permite encender o apagar LEDs mediante comandos seriales desde un programa como Processing. Se utiliza memoria dinámica con new para crear los usuarios y delete para liberar la memoria cuando ya no se necesita. La biblioteca LiquidCrystal_PCF8574 gestiona la pantalla LCD I2C, y la comunicación SPI se usa para interactuar con el lector RFID.
Para acceder al codigo hace click aca [Arduino](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/lista_arduino/lista_arduino.ino)

## Codigo en Processing
Este código en Processing gestiona un sistema de control de acceso basado en un lector de RFID, el cual se comunica a través de un puerto serial con un dispositivo Arduino. En la pantalla principal, el programa muestra un mensaje de bienvenida y una animación de puntos mientras espera la entrada de datos desde el lector de RFID. Cuando se recibe un identificador de usuario, el sistema verifica si coincide con algún usuario registrado, y si es así, muestra su nombre y rol en pantalla, además de registrar la hora de entrada o salida en un archivo de texto. La animación de los puntos en la pantalla sirve para dar feedback visual al usuario mientras el sistema espera. Los datos de cada usuario, como su nombre, rol y UID, se almacenan en una lista de objetos User, que también incluye la lógica para alternar entre los estados de "entrada" y "salida". Además, si no se detecta actividad durante un período de 10 segundos, el sistema vuelve automáticamente a la pantalla de inicio. Por último, el programa envía información al Arduino para controlar el hardware conectado, como los LEDs o cualquier otro componente relacionado con el acceso.
Para acceder al codigo hace click aca [Processing](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/Pro-Acceso-de-Control/Pro-Acceso-de-Control.pde)
