import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user type (owner or client)
  Future<String?> getUserType() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data()?['role'] as String?;
    } catch (e) {
      print('Error getting user type: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromMap({'id': doc.id, ...doc.data()!});
  }

  // Register with email and password
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      final now = DateTime.now();

      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        phone: phone,
        role: role,
        profileImage: null,
        createdAt: now,
        updatedAt: now,
      );

      await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

      return userModel;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      final updates = <String, dynamic>{'updatedAt': DateTime.now()};

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user by ID
  Future<UserModel> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) throw Exception('User not found');
      return UserModel.fromMap({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleAuthException(e);
    }
  }

  Exception _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return Exception('No user found with this email');
        case 'wrong-password':
          return Exception('Wrong password');
        case 'email-already-in-use':
          return Exception('Email is already in use');
        case 'invalid-email':
          return Exception('Invalid email address');
        case 'weak-password':
          return Exception('Password is too weak');
        case 'operation-not-allowed':
          return Exception('Operation not allowed');
        case 'user-disabled':
          return Exception('User has been disabled');
        default:
          return Exception('Authentication failed: ${e.message}');
      }
    }
    return Exception('Authentication failed: $e');
  }

  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> deleteAccount() async {
    try {
      await _firestore.collection('users').doc(currentUser!.uid).delete();
      await currentUser!.delete();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
}
