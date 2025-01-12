import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mynewapp/data/local_storage/shared_preference.dart';
import 'package:mynewapp/data/models/recipes.dart';
import 'package:mynewapp/profile_page.dart';
import 'package:mynewapp/recipe_list_page.dart';
import 'package:mynewapp/services/service_locator.dart';
import 'login_page.dart';
import 'sign_in_page.dart';
import 'about_page.dart';
import 'SearchByIngredientPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AdvancedSearchPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiKey =
      'c6ab8afed6414c3e994ecafdbd0ee35b'; // Replace with your API key
  bool isLoading = false;
  final sharedPrefService = serviceLocator<SharedPreferencesService>();
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();

  Future<void> _searchRecipe(String recipeName) async {
    if (recipeName.isEmpty) {
      _showMessage('Please enter a recipe name.');
      return;
    }
    setState(() {
      isLoading = true;
    });
    final url =
        'https://api.spoonacular.com/recipes/complexSearch?query=$recipeName&apiKey=$apiKey';
    print('Request URL: $url');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          isLoading = false;
        });
        var data = json.decode(response.body);
        print(data); // Debugging output

        if (data['results'].isNotEmpty) {
          var recipes = Recipes.fromJson(data);
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeListPage(recipesList: recipes),
              ));
        } else {
          _showMessage('No recipes found for "$recipeName".');
        }
      } else {
        setState(() {
          isLoading = false;
        });
        _showMessage(
            'Failed to fetch recipes. Response code: ${response.statusCode}');
      }
    } catch (e) {
      print("Exception: $e");
      _showMessage('An error occurred: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        title: const Center(
          child: Text(
            'Easy Cook',
            style: TextStyle(
              // fontSize: 50, // Increased font size
              fontWeight: FontWeight.bold,
              // color: Color.fromARGB(255, 11, 169, 177), // Changed color
            ),
          ),
        ),
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.menu), // Menu icon on the left
          onSelected: (value) {
            if (sharedPrefService.userUid != "") {
              if (value == 'Search by Ingredient') {
                // Navigate to Search by Ingredient Page
                // Uncomment and create the respective page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchByIngredientPage()));
              } else if (value == 'Advanced Search') {
                // Navigate to Advanced Search Page
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdvancedSearchPage()));
              }
            } else {
              _showMessage(
                  "Only members can access this sections, Please login to access");
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem<String>(
                value: 'Search by Ingredient',
                child: Text('Search by Ingredient'),
              ),
              const PopupMenuItem<String>(
                value: 'Advanced Search',
                child: Text('Advanced Search'),
              ),
            ];
          },
        ),
        actions: [
          sharedPrefService.userUid != ""
              ? IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Logout'),
                          content: Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Logout'),
                              onPressed: () {
                                setState(() {
                                  sharedPrefService.clearData();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Logged out successfully')));
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.power_settings_new_outlined))
              : IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  icon: Icon(Icons.login)),
          IconButton(
              onPressed: () {
                if (sharedPrefService.userUid != "") {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                } else {
                  _showMessage(
                      "Only members can access these sections, Please login to access");
                }
              },
              icon: const Icon(Icons.person)),
          // PopupMenuButton<String>(
          //   icon: const Icon(Icons.person_rounded),
          //   onSelected: (value) {
          //     if(sharedPrefService.userUid != "") {
          //       if (value == 'Profile') {
          //         // Navigate to Profile Page
          //         /*Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => ProfilePage()),
          //       );*/
          //       } else if (value == 'App Settings') {
          //         // Navigate to App Settings Page
          //         // Navigator.push(
          //         // context,
          //         // MaterialPageRoute(builder: (context) => AppSettingsPage()),
          //       // );
          //       }
          //     } else {
          //       _showMessage("Only members can access these sections, Please login to access");
          //     }
          //   },
          //   itemBuilder: (BuildContext context) {
          //     return [
          //       const PopupMenuItem<String>(
          //         value: 'Profile',
          //         child: Text('Profile'),
          //       ),
          //       const PopupMenuItem<String>(
          //         value: 'App Settings',
          //         child: Text('App Settings'),
          //       ),
          //     ];
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.history),
          //   onPressed: () {
          //     // Navigate to history
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              ); // Navigate to about
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/food_background.jpg'),
                      // Add your background image here
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TypeAheadField(
                        controller: _searchController,
                        builder: (context, editingController, node) {
                          return TextField(
                            controller: editingController,
                            focusNode: node,
                            autofocus: true,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Search Recipes',
                                prefixIcon: Icon(Icons.search),
                                filled: true,
                                fillColor: Colors.white),
                            onSubmitted: (value) {
                              _searchRecipe(value);
                            },
                          );
                        },
                        itemBuilder:
                            (context, Map<String, dynamic> suggestion) {
                          return ListTile(
                            leading: Image.network(
                              suggestion['imageUrl'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(suggestion['title']),
                          );
                        },
                        onSelected: (Map<String, dynamic> suggestion) {
                          // Handle suggestion selection (e.g., navigate to details page)
                          _searchController.text = suggestion['title'];
                          print('Selected recipe: ${suggestion['title']}');
                        },
                        suggestionsCallback: (pattern) async {
                          return await _getRecipeSuggestions(pattern);
                        },
                        emptyBuilder: (context) => const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('No recipes found.'),
                        ),
                      ),
                      // child: TextField(
                      //   controller: _searchController,
                      //   decoration: InputDecoration(
                      //     hintText: 'Search for recipes...',
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10.0),
                      //       borderSide: BorderSide.none,
                      //     ),
                      //     prefixIcon: const Icon(Icons.search),
                      //   ),
                      //   onSubmitted: (value) {
                      //     _searchRecipe(value);
                      //     // Implement search functionality
                      //   },
                      // ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        _searchRecipe(
                            _searchController.text); // Navigate to search
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Search'),
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: const BottomAppBar(
        color: Colors.orangeAccent,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '© 2024 Easy Cook. All rights reserved.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // Function to fetch recipe suggestions from Spoonacular API
  Future<List<Map<String, dynamic>>> _getRecipeSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url =
        'https://api.spoonacular.com/recipes/autocomplete?number=10&query=$query&apiKey=$apiKey';

    try {
      final response = await _dio.get(url);
      List<dynamic> data = response.data;
      return data.map((item) {
        return {
          'id': item['id'],
          'title': item['title'],
          'imageUrl':
              'https://spoonacular.com/recipeImages/${item['id']}-312x231.${item['imageType']}',
        };
      }).toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }
}
