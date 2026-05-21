import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
 * ¿Qué hace este archivo?
 * Aquí gestionamos la puerta de entrada a la aplicación.
 * Básicamente es el portero de discoteca: permite a la gente registrarse 
 * con un correo y contraseña de toda la vida, o usar su cuenta de Google 
 * para entrar más rápido sin comerse la cabeza.
 */
class ServicioAutenticacion {
  ServicioAutenticacion({FirebaseAuth? autenticacionFirebase, GoogleSignIn? inicioSesionGoogle})
      : _autenticacion = autenticacionFirebase ?? FirebaseAuth.instance,
        _inicioSesionGoogle = inicioSesionGoogle ?? GoogleSignIn();

  final FirebaseAuth _autenticacion;
  final GoogleSignIn _inicioSesionGoogle;

  // Nos devuelve quién está logueado ahora mismo (si es que hay alguien).
  User? get usuarioActual => _autenticacion.currentUser;

  // Para entrar con correo y contraseña.
  Future<UserCredential> iniciarSesionConEmail({
    required String email,
    required String contrasena,
  }) {
    return _autenticacion.signInWithEmailAndPassword(
      email: email.trim(),
      password: contrasena,
    );
  }

  // Para crearse una cuenta nueva desde cero.
  Future<UserCredential> registrarConEmail({
    required String email,
    required String contrasena,
  }) {
    return _autenticacion.createUserWithEmailAndPassword(
      email: email.trim(),
      password: contrasena,
    );
  }

  // Para entrar rapidísimo usando la cuenta de Google.
  Future<UserCredential?> iniciarSesionConGoogle() async {
    try {
      final GoogleSignInAccount? usuarioGoogle = await _inicioSesionGoogle.signIn();
      // Si el usuario se echa para atrás y cancela a medias, no pasa nada
      if (usuarioGoogle == null) return null; 
      
      final GoogleSignInAuthentication authGoogle = await usuarioGoogle.authentication;
      final AuthCredential credenciales = GoogleAuthProvider.credential(
        accessToken: authGoogle.accessToken,
        idToken: authGoogle.idToken,
      );
      
      return await _autenticacion.signInWithCredential(credenciales);
    } catch (e) {
      // Si explota, lanzamos el error para arriba
      rethrow;
    }
  }

  // Para cerrar el chiringuito y salir de la cuenta.
  Future<void> cerrarSesion() async {
    await _inicioSesionGoogle.signOut();
    return _autenticacion.signOut();
  }
}

/*
 * Esta función es oro puro. Firebase nos devuelve unos errores rarísimos en inglés
 * cuando la gente la lía (ej. contraseña corta, correo malo), así que esto lo traduce
 * a algo que un humano normal pueda entender.
 */
String errorAutenticacionAmigable(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Ha ocurrido un error inesperado. Inténtalo de nuevo, a ver si hay suerte.';
  }

  switch (error.code) {
    case 'invalid-email':
      return 'El email tiene un formato rarísimo. Revísalo.';
    case 'user-not-found':
      return 'No nos suena ese email. ¿Seguro que estás registrado?';
    case 'wrong-password':
      return 'Contraseña incorrecta. Piénsala bien y vuelve a intentar.';
    case 'email-already-in-use':
      return 'Ese correo ya está pillado. Mejor intenta iniciar sesión directamente.';
    case 'weak-password':
      return 'Esa contraseña es muy floja (necesitas 6 caracteres mínimo). ¡Métele algo más fuerte!';
    case 'operation-not-allowed':
      return 'El método de acceso no está habilitado en Firebase. Culpa nuestra.';
    case 'network-request-failed':
      return 'Parece que no tienes Internet. Revisa el WiFi o los datos móviles.';
    default:
      return 'No se ha podido hacer la movida (${error.code}).';
  }
}
