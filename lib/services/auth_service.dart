import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con correo y contraseña
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Crea cuenta nueva, actualiza nombre visible y crea documento privado en /users/{uid}
  Future<UserCredential> registerWithEmail({
    required String displayName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final cleanName = displayName.trim();
      final user = credential.user;

      if (user != null) {
        await user.updateDisplayName(cleanName);
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'displayName': cleanName,
          'email': user.email ?? email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e.code));
    }
  }

  /// Cierra sesión de forma limpia
  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido.';
      case 'user-disabled':
        return 'Esta cuenta se encuentra deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta registrada con este correo.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera unos minutos antes de reintentar.';
      default:
        return 'Error de autenticación ($code). Intenta de nuevo.';
    }
  }
}