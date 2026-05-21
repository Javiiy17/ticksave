# 🚀🔥 GUÍA DEFINITIVA TICKSAVE: ¡A POR EL 10 EN EL TFG! 🔥🚀

¡Esta es tu biblia exprés! 📖 Aquí tienes las tripas de la app masticaditas, directas al grano y listas para que sueltes un discurso que deje al tribunal con la boca abierta. 🤯 ¡Vamos a romperla, Luis! 💪

---

## 📸 1. EL VIAJE ÉPICO DE UN TICKET (Del Papel a la Nube ☁️)

*Si te preguntan: "¿Qué magia ocurre al darle a Escanear?"*, tú sacas la artillería:

1. **💥 El Flash (`barcode_scanner_screen.dart`):**  
   El usuario le da al botón y... ¡PUM! 📸 Abrimos la cámara del móvil. Sacamos la foto al recibo arrugado del súper y la guardamos temporalmente. 

2. **🧠 El Cerebro IA (`ticket_service.dart`):**  
   ¡Aquí está la chicha! Le pasamos la foto a **Google ML Kit** 🤖 (nuestro motor de IA). Éste lee la imagen y nos devuelve una ensalada de texto.  
   - 🎣 **Modo Pescador (Regex):** Usamos *Expresiones Regulares* como redes mágicas para pescar la **fecha** 📅 (ej. `12/03/2026`) y el **dinero** 💸 (ej. `15,50`).  
   - 🏪 El nombre de la tienda lo adivinamos porque suele ser el letrero más grande arriba del todo.

3. **👀 Ojo Clínico (`edit_ticket_screen.dart`):**  
   ¡No nos fiamos de las máquinas al 100%! Le mostramos al usuario los datos que ha sacado la IA para que los valide o corrija si hace falta. ✍️

4. **🚀 Despegue a la Nube (Storage + Firestore):**  
   Al pulsar "Guardar", hacemos un combo doble en `ticket_service.dart`:
   - 🗜️ **Comprimir y Volar:** `subirImagenTicket` aplasta la foto (para no gastar datos) y la sube a **Firebase Storage**. Nos da un link 🔗.
   - 💾 **Guardado Seguro:** `anadirTicket` pilla ese link, el comercio, el precio y la fecha, y lo mete todo en una caja fuerte digital en **Firebase Firestore**, bien atado al ID de nuestro usuario. 🔒

---

## 🕵️‍♂️ 2. EL PORTERO DE DISCOTECA (Sistema de Sesión)

*¿Cómo sabe la app quién demonios está dentro?* 🧐

¡Fácil! Tenemos a nuestro propio gorila de seguridad: `auth_service.dart` 🕶️ (la clase `ServicioAutenticacion`).

- 📡 **El Radar:** La app tiene un radar encendido 24/7 (*StreamBuilder*) escuchando a Firebase.
- 🛑 **"¡Tú no pasas!":** Si Firebase dice *"Aquí no hay nadie"*, el portero te manda de una patada al Login (`login_screen.dart`). 
- 🟢 **"¡Pasa, VIP!":** Si Firebase dice *"Sí, es el usuario con este ID"*, se te abren las puertas del `home_screen.dart`. 🏰
- 🛡️ **Seguridad Anti-Hackers:** Para guardar o ver tickets, la app *siempre* comprueba primero tu carnet (`_autenticacion.currentUser`). ¡Sin carnet, no hay tickets! 🚫🎫

---

## 🔑 3. EL TOP 5: FUNCIONES PARA LUCIRTE 🌟

Llévalas tatuadas en la mente. Si el tribunal te pide código, suéltales estas joyas:

1. 🔍 **`extraerDatosTicket`**  
   *La joya de la corona.* Coge la foto, invoca a la IA de **Google ML Kit** y usa magia negra (*Regex*) para sacar nombre, fecha y pasta. 🤑

2. 📦 **`subirImagenTicket`**  
   *El optimizador.* Estruja la foto para que pese menos y la manda volando a **Firebase Storage**. 🚀

3. 📝 **`anadirTicket`**  
   *El notario.* Guarda el ticket oficial en la base de datos **Firestore**, sellado con el ID secreto del usuario para que nadie más lo fisgonee. 🕵️‍♂️

4. 🔄 **`obtenerTicketsUsuario`**  
   *El chivato en directo.* Abre un canal de TV (*Stream*) con la nube. Si compras algo ahora mismo, ¡PUM!, aparece en la pantalla sin tener que recargar. 📺✨

5. ⚡ **`iniciarSesionConGoogle`**  
   *El pase rápido.* Habla con Google para que entres a la app en un microsegundo, sin teclear ni una sola contraseña. ¡A toda pastilla! 🏎️💨

---
> [!TIP]
> **🌟 EL TRUCO DEL ALMENDRUCO (Para la Defensa):**  
> Cuando hables del OCR (ML Kit), ponte serio y di: *"Nos dimos cuenta de que la IA devolvía el texto muy sucio, así que Javi y yo implementamos Expresiones Regulares (Regex) nativas en Dart para filtrar fechas y divisas con precisión milimétrica"*.  
> ¡El tribunal se pondrá de pie a aplaudir! 👏👏👏 ¡A POR ELLOS! 🏆
