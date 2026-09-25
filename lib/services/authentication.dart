import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firestore_service.dart';

/// Service providing Firebase Authentication actions and helpers with Google Sign-In & Firestore sync.
class AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirestoreService _firestoreService;

  AuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirestoreService? firestoreService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestoreService = firestoreService ?? FirestoreService();

  /// Current Firebase User
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Stream of user changes (token, profile, etc.)
  Stream<User?> get userChanges => _auth.userChanges();

  /// Extract human-friendly error messages from Firebase and other exceptions
  static String getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not formatted correctly.';
        case 'weak-password':
          return 'The password provided is too weak. Must be at least 6 characters.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'invalid-credential':
          return 'Invalid credentials provided. Please check your email and password.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/Password sign-in is not enabled in Firebase Console.';
        case 'network-request-failed':
          return 'Network error occurred. Please check your connection.';
        case 'account-exists-with-different-credential':
          return 'An account already exists with the same email address but different sign-in credentials.';
        case 'popup-closed-by-user':
          return 'Sign-in cancelled by user.';
        default:
          if (error.message != null && error.message!.isNotEmpty) {
            return error.message!;
          }
          return 'Authentication failed (${error.code}).';
      }
    }

    final raw = error.toString().replaceFirst('Exception: ', '').trim();
    if (raw.isNotEmpty) return raw;
    return 'An unexpected error occurred. Please try again.';
  }

  /// Sign in with Email and Password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    if (credential.user != null) {
      await _firestoreService.saveOrUpdateUser(credential.user!);
    }

    return credential;
  }

  /// Sign up with Email, Password, and Name
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      final f = firstName?.trim() ?? '';
      final l = lastName?.trim() ?? '';
      final fullName = '$f $l'.trim();

      if (fullName.isNotEmpty) {
        await user.updateDisplayName(fullName);
        await user.reload();
      }

      await _firestoreService.saveOrUpdateUser(
        _auth.currentUser ?? user,
        customDisplayName: fullName.isNotEmpty ? fullName : null,
      );
    }

    return credential;
  }

  /// Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      // User cancelled the sign-in
      return null;
    }

    // Obtain auth details from request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential
    final userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      await _firestoreService.saveOrUpdateUser(userCredential.user!);
    }

    return userCredential;
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Sign out current user
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
