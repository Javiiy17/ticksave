import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Servicio de autenticación que maneja inicio de sesión (Google, Email)
/// y el registro de usuarios en Firebase Auth.
/// @author Javier Abellán
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

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

  /// Inicia sesión con Google.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Cancelado
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
    }
  }

  /// Cierra la sesión.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    return _auth.signOut();
  }
}

/// Traduce errores comunes de FirebaseAuth a mensajes entendibles para el usuario.
///
/// Nota: estos códigos pueden variar entre versiones, pero los más comunes se mantienen.
/// @author Javier Abellán
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

