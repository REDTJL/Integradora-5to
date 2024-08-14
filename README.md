<h1>Proyecto integrador BioSafe</h1>
<p>Este proyecto es el proyecto que engloba todas las materias que curse durante mi 5to cuatrimestre en la Universidad Tecnológica de Chihuahua en la carrera de tecnologias de la informacion en el area de desarrollo de software multiplataforma</p>
<h2>¿Qué se realizó?</h2>
Se realizó un proyecto que era un ecosistema de programas que incluye una pagina o app web, una app movil y un dispositivo de IoT, todo esto conectado a una base de datos en google firebase
<h2>¿Qué se utilizó?</h2>
Para el desarrollo de este proyecto utilizamos React con node.js para el desarrollo web, Flutter con dart para el desarrollo movil y para IoT se utilizó una placa ESP 32 WROOM programada con arduino
<h2>¿Qué hace?</h2>

Este proyecto gestiona el inventario de las vacunas en la app web, la cual es unicamente para el encargado del area de las vacunas, ademas monitorea y lleva un registro de las temperaturas en tiempo real, alertando por cambios fuera de lo nomal, también hay un apartado para ver quien accedió al dispositivo IoT que es un refrigerador con cerradra inteligente

En la app web el usuario igual inicia sesion (esto es para cualquier persona con acceso al refrigerador), una vez que ha iniciado sesion le aparecerá la temperatura en tiempo real y la opcion de sacar vacunas, esta opcion lo envia a otra view y en esa selecciona cuales vacunas quiere sacar o no y hay un boton de abrir refrigerador, el cual arroja un pin dinamico de uso unico que se ingresa en el dispositivo IoT y abre la cerradura inteligente.

El dispositivo IoT cuenta con un display LCD 2x16 en el cual muestra la temperatura en tiempo real y la contraseña que el usuario ingresa mediante un pinpad matricial 4x4, cuenta ademas con una cerradura inteligente que en este caso es un servomotor pero se puede integrar cualquier otra cerradura electronica, por ultimo tiene un sensor magnetico de ventana para sensar cuando el refrigerador está abierto o cerrado.
