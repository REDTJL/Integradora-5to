<h1>App movil en Flutter</h1>

Esta app necesita que se incluyan los pasos para utilizar la base de datos de firebase, para esto necesitas ingresar a la consola de firebase ingresar al proyecto que vayas a usar para esto y seguir los pasos que te arroja en la opcion de agregar firebase a flutter, te dará una seria de comandos que necesitas ejecutar en la consola al nivel del archivo main.dart en tu proyecto flutter para que te creé el archivo firebase-options el cual te generará en automatico un array con las credenciales para ingresar a firebase desde cualquier dispositivo en el que quieras desarrollar tu app, si no haces esto el proyecto no funcionará ya que no tendrá de donde traer los datos

Para las colecciones que se tienen que crear en la base de datos solo serán dos, una para el inventario de vacunas
![image](https://github.com/user-attachments/assets/efe1b4c9-71c5-49c9-97c6-e4df265f856d)

Y la otra será la de los usuarios con la siguiente estructura
[Tu proyecto firebase]/Usuarios/(IdUsuario)/Apellido:"" (string),Nombre:"" (string), Correo:""(string), Password:""(String)
Esta coleccion será la encargada de los inicios de sesion en ambas apps, en la web y en la movil, el IdUsuario NO debe de ser aleatorio ya que será con el que se ingrese en la app web, y el correo será con el que se inicie sesion en la app movil, la contraseña es compartida.

