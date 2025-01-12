import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up
  Future<User?> signUp(
      {required String email,
      required String password,
      required Map<String, dynamic> userData}) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        try {
          await _firestore.collection('users').doc(user.uid).set(userData);
        } catch (e) {
          print("Firestore error: $e");
          throw e;
        }
      }
      return user;
    } catch (error) {
      throw error;
    }
  }

  // Sign In
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (error) {
      throw error;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      throw error;
    }
  }

  // Get Current User
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Save User Data to Firestore
  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(uid).set(userData);
    } catch (e) {
      throw e;
    }
  }
}
