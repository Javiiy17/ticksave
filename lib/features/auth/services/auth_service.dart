import 'package:firebase_auth/firebase_auth.dart';

/// Servicio de autenticación.
///
/// La idea de un "service" es separar la lógica (Firebase) de la UI (pantallas).
/// Así las pantallas quedan más limpias y, si mañana cambias Firebase por otra
/// solución, solo tocarías esta capa.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Devuelve el usuario actual si hay sesión iniciada.
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con email/contraseña.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Crea una cuenta con email/contraseña.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Cierra la sesión.
  Future<void> signOut() => _auth.signOut();
}

/// Traduce errores comunes de FirebaseAuth a mensajes entendibles para el usuario.
///
/// Nota: estos códigos pueden variar entre versiones, pero los más comunes se mantienen.
String friendlyAuthError(Object error) {
  if (error is! FirebaseAuthException) {
    return 'Ha ocurrido un error inesperado. Inténtalo de nuevo.';
  }

  switch (error.code) {
    case 'invalid-email':
      return 'El email no tiene un formato válido.';
    case 'user-not-found':
      return 'No existe ninguna cuenta con ese email.';
    case 'wrong-password':
      return 'La contraseña no es correcta.';
    case 'email-already-in-use':
      return 'Ese email ya está registrado. Prueba a iniciar sesión.';
    case 'weak-password':
      return 'La contraseña es demasiado débil (mínimo 6 caracteres).';
    case 'operation-not-allowed':
      return 'El método de acceso no está habilitado en Firebase.';
    case 'network-request-failed':
      return 'Parece que no hay conexión. Revisa Internet e inténtalo de nuevo.';
    default:
      return 'No se pudo completar la operación (${error.code}).';
  }
}

