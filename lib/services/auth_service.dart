import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with Email and Password
  Future<UserCredential?> signUpWithEmailPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Errors to provide cleaner user messages
  Exception _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No user found for that email.');
      case 'wrong-password':
        return Exception('Wrong password provided for that user.');
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'email-already-in-use':
        return Exception('An account already exists for that email.');
      case 'invalid-email':
        return Exception('The email address is badly formatted.');
      case 'weak-password':
        return Exception('The password provided is too weak.');
      default:
        return Exception(e.message ?? 'Authentication failed.');
    }
  }
}
