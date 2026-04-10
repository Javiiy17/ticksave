<div align="center">
  
  # 🧾✨ TickSave 
  
  **Protege tus garantías en la nube con un solo escaneo.**  
  ¡Nunca más pierdas un ticket de compra importante ni olvides el plazo de devolución!
  
</div>

---

## 🚀 ¿Qué es TickSave?

**TickSave** es una aplicación móvil moderna desarrollada en Flutter diseñada para revolucionar la forma en que gestionas tus recibos y tickets de compra. Integrada plenamente con la nube, permite a los usuarios escanear, guardar, categorizar y monitorizar el estado de sus garantías directamente desde su dispositivo móvil, todo envuelto en una interfaz *Premium Glassmorphism* (Pink & Purple Dark Theme).

Desarrollada como **Trabajo de Fin de Grado (TFG)**, demostrando habilidades avanzadas en la creación de aplicaciones móviles multiplataforma, bases de datos no relacionales y procesamiento de imágenes con Inteligencia Artificial.

---

## 🌟 Características Principales

*   📸 **Escaneo Inteligente (OCR):** Toma una foto de tu ticket y nuestra IA (vía Google ML Kit) extraerá automáticamente la fecha y el nombre del comercio.
*   ☁️ **Sincronización en la Nube:** Tus datos están seguros. Gracias a Firebase Firestore y Firebase Storage, nunca perderás un recibo aunque cambies de móvil.
*   🔔 **Alertas de Garantía:** El sistema detecta y resalta visualmente los tickets con garantías a punto de expirar (menos de 30 días).
*   🔐 **Autenticación Segura:** Inicio de sesión clásico con correo electrónico o un solo toque usando tu cuenta de Google.
*   🎨 **Diseño Moderno & Premium:** Interfaz oscura (Dark Mode), con efectos de cristal (*Glassmorphism*), gradientes de color y transiciones fluidas.
*   🌍 **Internacionalización y Ajustes:** Soporte multi-idioma nativo (ES/EN) y selector ajustable de moneda global.

---

## 🛠 Herramientas y Tecnologías

El ecosistema técnico de **TickSave** está construido sobre las mejores herramientas del mercado actual:

*   **Frontend:** [Flutter](https://flutter.dev/) (Dart)
*   **Backend & Cloud:** [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore, Cloud Storage)
*   **Inteligencia Artificial:** Google ML Kit (Text Recognition para OCR)
*   **Procesamiento:** `image_picker`, `flutter_image_compress` 

---

## ⚙️ Manual de Instalación y Despliegue (Entorno de Desarrollo)

Si quieres compilar y ejecutar **TickSave** localmente, sigue estos pasos:

### 1. Prerrequisitos

Asegúrate de tener instalado en tu sistema:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión 3.3.0 o superior)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio o VS Code (con las extensiones de Flutter instaladas)
- Git

### 2. Clonar el Repositorio

Abra la terminal y ejecute:
```bash
git clone https://github.com/Javiiy17/ticksave.git
cd ticksave
```

### 3. Instalar Dependencias

Descarga todas las librerías descritas en el archivo `pubspec.yaml`:
```bash
flutter pub get
```

### 4. Configurar Firebase (Opcional, si deseas usar un entorno propio)

*La app ya cuenta con los archivos de configuración para nuestro propio backend, pero si deseas compilarlo para otro entorno:*
1. Ve a la [Consola de Firebase](https://console.firebase.google.com/) y crea un nuevo proyecto.
2. Añade aplicaciones para Android y/o iOS.
3. Sustituye los archivos `google-services.json` (Android) y `GoogleService-Info.plist` (iOS) generados.

### 5. Compilar y Ejecutar

Conecta un emulador o tu dispositivo físico por USB/Wi-Fi y asegúrate de que es detectado haciendo `flutter devices`. Para correr el proyecto:
```bash
flutter run
```

---

## 👨‍💻 Autores y Desarrolladores

*   **Javier Abellán** - *Desarrollo Backend (Firebase), Lógica de Estado y Arquitectura.*
*   **Luis Bermeo** - *Desarrollo Frontend, UX/UI (Tema Premium), Integraciones IA (Sistemas OCR) e Infraestructura Git.*

---

<div align="center">
  Hecho con ❤️ y mucho código para nuestro <strong>TFG</strong>. 🎓
</div>
