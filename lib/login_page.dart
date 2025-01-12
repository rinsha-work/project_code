import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mynewapp/data/local_storage/shared_preference.dart';
import 'package:mynewapp/data/models/user.dart';
import 'package:mynewapp/homepage.dart';
import 'package:mynewapp/services/service_locator.dart';
import 'package:mynewapp/sign_in_page.dart';
import 'auth.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final sharedPrefService = serviceLocator<SharedPreferencesService>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextButton(
                      onPressed: () {
                        _showLoadingDialog();
                        _sendPasswordResetEmail();
                      },
                      child: const Text('Forgot password?',
                          style: TextStyle(color: Colors.orangeAccent)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                  Flexible(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SignInPage()));
                      },
                      child: const Text('Sign Up',
                          style: TextStyle(color: Colors.orangeAccent)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    _showLoadingDialog();
    String email = emailController.text.trim();
    String password = passwordController.text;

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user?.uid != null) {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential
            .user?.uid) // Access the document using the user's UID
            .get();
        if (documentSnapshot.exists) {
          print("Documents: ${documentSnapshot.data()}");
          final user = UserDetails.fromJson(
              documentSnapshot.data() as Map<String, dynamic>);
          sharedPrefService.userName = user.name;
          sharedPrefService.email = user.email;
          sharedPrefService.dietryRestriction = user.dietaryRestriction;
          sharedPrefService.preferredCuisine = user.preferredCuisine;
          sharedPrefService.userUid = userCredential.user!.uid;
          sharedPrefService.userLoggedInFlag = true;
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
                  (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pop();
          _showMessage("User data fetch error");
          print("User data fetch error");
        }
        // sharedPrefService.userLoggedInFlag = true;
      }

      print('User logged in: ${userCredential.user!.email}');
      // Navigate to the home page or another screen here
    } catch (e) {
      Navigator.of(context).pop();
      print('Login failed: $e');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    String email = emailController.text;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    if (email.isNotEmpty) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        Navigator.of(context).pop();
        _showMessage('Password reset email sent.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent.')),
        );
      } catch (e) {
        print('Error: $e');
        Navigator.of(context).pop();
        _showMessage('Failed to send reset email: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: $e')),
        );
      }
    } else {
      Navigator.of(context).pop();
      _showMessage('Please enter an email address.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address.')),
      );
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoadingDialog() {
    showDialog(
        context: context,
        builder: (context) => const Dialog(
          child: SizedBox(
            height: 100.0,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ));
  }
}
