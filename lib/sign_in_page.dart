import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynewapp/login_page.dart';

//import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth.dart';  // Make sure to import your AuthService

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  // Dropdown menu items
  String selectedCuisine = 'Italian'; // Default value
  String selectedDietaryRestriction = 'None'; // Default value

  List<String> cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'American'];
  List<String> dietaryRestrictions = ['None', 'Vegan', 'Vegetarian', 'Gluten-Free', 'Keto'];

  // Function to handle sign up
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      String name = nameController.text;
      String email = emailController.text;
      String password = passwordController.text;
      String confirmPassword = confirmPasswordController.text;

      if (password != confirmPassword) {
        _showMessage('Passwords do not match');
        return;
      }

      try {
        User? user = await AuthService().signUp(
          email: email,
          password: password,
          userData: {
            'name': name,
            'preferredCuisine': selectedCuisine,
            'dietaryRestriction': selectedDietaryRestriction,
            'email': email,
          },
        );

        if (user?.email != null) {
          // User signed up successfully, navigate to the home page or login
          // _showMessage('Sign-up successful. Welcome, ${user?.email}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Sign-up successful. Welcome, ${user?.email}')));
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginPage()), (Route<dynamic> route) => false); // Navigate back to the previous screen (or home page)
        } else {
          print("Some Error occured while signup");
        }
      } catch (e) {
        _showMessage('Error signing up: $e');
      }
    }
  }

  // Function to show a simple alert dialog
  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Name', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const Text('Preferred Cuisine', style: TextStyle(fontSize: 18)),
                DropdownButtonFormField<String>(
                  value: selectedCuisine,
                  items: cuisines.map((String cuisine) {
                    return DropdownMenuItem<String>(
                      value: cuisine,
                      child: Text(cuisine),
                    );
                  }).toList(),
                  onChanged: (String? newCuisine) {
                    setState(() {
                      selectedCuisine = newCuisine!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Dietary Restriction', style: TextStyle(fontSize: 18)),
                DropdownButtonFormField<String>(
                  value: selectedDietaryRestriction,
                  items: dietaryRestrictions.map((String restriction) {
                    return DropdownMenuItem<String>(
                      value: restriction,
                      child: Text(restriction),
                    );
                  }).toList(),
                  onChanged: (String? newRestriction) {
                    setState(() {
                      selectedDietaryRestriction = newRestriction!;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Email', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your email',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Password', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password should be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                const Text('Confirm Password', style: TextStyle(fontSize: 18)),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Confirm your password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text('Sign Up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
