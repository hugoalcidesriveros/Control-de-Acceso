# Control-de-Acceso
Este proyecto tiene como objetivo utilizar tarjetas magnéticas en conjunto con Arduino y el módulo RC522, que permite leer las tarjetas y activar funciones específicas. Al hacerlo, se almacena el nombre del usuario en una base de datos, facilitando la gestión de acceso y registro. Además, se integra una interfaz gráfica desarrollada en Processing, que proporciona una visualización intuitiva y está conectada al sistema de Arduino para mejorar la interacción con el usuario
### Los dispositivos utilizados son:

- Arduino UNO
- Modulo RFID RC522
- Tarjetas RFID
- LCD 16x2-I2C
- Buzzer
- LEDs
- Potenciometro

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
Cuando un usuario pase su tarjeta RFID por el lector, se habilitará su acceso al sistema. En la primera pasada, el nombre del usuario será registrado y su tarjeta quedará habilitada.

- **Registro de la hora de entrada**
En la segunda vez que el usuario pase su tarjeta, el sistema marcará automáticamente la hora de entrada. Además, Processing mostrará gráficamente el sector que ocupa la persona dentro del auditorio. Este sector será representado como un plano del auditorio, y el área correspondiente al usuario se resaltará en color amarillo.

- **Salida del personal**
Al marcar la tarjeta nuevamente para salir, el sistema registrará la hora de salida y actualizará la interfaz gráfica. El sector previamente ocupado por el usuario será restaurado a su color original (gris), indicando que la persona ha dejado ese espacio.

## Esquema de Circuito Realizado en Fritzing
### Ingresa al archivo [Fritzing](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/sketch_241112b/sketch_241112b.pde)
![](https://github.com/hugoalcidesriveros/Control-de-Acceso/blob/main/Circuito%20Arduino.jpg)
