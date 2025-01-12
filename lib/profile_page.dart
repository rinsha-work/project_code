import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynewapp/data/local_storage/shared_preference.dart';
import 'package:mynewapp/data/models/user.dart';
import 'package:mynewapp/services/service_locator.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final sharedPrefService = serviceLocator<SharedPreferencesService>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dietryRestrictionController = TextEditingController();
  final _preferredCuisineController = TextEditingController();

  List<String> cuisines = ['Italian', 'Chinese', 'Indian', 'Mexican', 'American'];
  List<String> dietaryRestrictions = ['None', 'Vegan', 'Vegetarian', 'Gluten-Free', 'Keto'];

  String selectedCuisine = ''; // Default value
  String selectedDietaryRestriction = '';

  @override
  void initState() {

    _nameController.text = sharedPrefService.userName;
    _emailController.text = sharedPrefService.email;
    _dietryRestrictionController.text = sharedPrefService.dietryRestriction;
    _preferredCuisineController.text = sharedPrefService.preferredCuisine;
    selectedCuisine = sharedPrefService.preferredCuisine;
    selectedDietaryRestriction = sharedPrefService.dietryRestriction;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.orangeAccent,
          foregroundColor: Colors.white,
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    label: Text("Name"),
                    border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      label: Text("Email"),
                      border: OutlineInputBorder()
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
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
                    label: const Text('Preferred Cuisine')
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                DropdownButtonFormField<String>(
                  value: selectedDietaryRestriction,
                  items: dietaryRestrictions.map((String diet) {
                    return DropdownMenuItem<String>(
                      value: diet,
                      child: Text(diet),
                    );
                  }).toList(),
                  onChanged: (String? newDiet) {
                    setState(() {
                      selectedDietaryRestriction = newDiet!;
                    });
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: const Text('Dietary Restriction')
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                      onPressed: () {
                        _showLoadingDialog();
                        updateUserData(name: _nameController.text, email: _emailController.text, dietaryRestriction: selectedDietaryRestriction, preferredCuisine: selectedCuisine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)
                      ),
                      child: const Text("Update"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> updateUserData({required String name, required String email, required String dietaryRestriction, required String preferredCuisine}) async {
    User? user = FirebaseAuth.instance.currentUser; // Get the current authenticated user

    if (user != null) {
      // Prepare the updated data
      Map<String, dynamic> updatedData = {
        'name': name,      // Update the 'name' field
        'email': email, // Update the 'email' field
        'dietaryRestriction': dietaryRestriction,
        'preferredCuisine': preferredCuisine
      };

      // Update the user's document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid) // Access the document using the user's UID
          .update(updatedData)
          .then((_) {
            updateSharedPref();
            Navigator.of(context).pop();
            _showMessage("User details Updated Successfully");
        print("User data updated successfully.");
      }).catchError((error) {
        Navigator.of(context).pop();
        _showMessage("Failed to update user data");
        print("Failed to update user data: $error");
      });
    } else {
      Navigator.of(context).pop();
      _showMessage("User not logged in");
      print("User is not logged in.");
    }
  }

  void updateSharedPref() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sharedPrefService.userUid) // Access the document using the user's UID
        .get();
    if (documentSnapshot.exists) {
      print("Documents: ${documentSnapshot.data()}");
      final user = UserDetails.fromJson(
          documentSnapshot.data() as Map<String, dynamic>);
      sharedPrefService.userName = user.name;
      sharedPrefService.email = user.email;
      sharedPrefService.dietryRestriction = user.dietaryRestriction;
      sharedPrefService.preferredCuisine = user.preferredCuisine;
      print("Local storage updated");
    } else {
      print("User data fetch error");
    }
  }

  void _showMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Message'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
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
