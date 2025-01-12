import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mynewapp/advanced_recipe_list_page.dart';
import 'package:mynewapp/data/local_storage/shared_preference.dart';
import 'dart:convert';

import 'package:mynewapp/data/models/recipes.dart';
import 'package:mynewapp/services/service_locator.dart';

class AdvancedSearchPage extends StatefulWidget {
  @override
  _AdvancedSearchPageState createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends State<AdvancedSearchPage> {
  String? selectedCuisine;
  String? selectedDiet;
  String? selectedDifficulty;
  String? selectedTime;

  final sharedPrefService = serviceLocator<SharedPreferencesService>();

  final List<String> cuisines = ['Italian', 'Chinese', 'Mexican', 'Indian'];
  final List<String> diets = [
    'Vegan',
    'Vegetarian',
    'Gluten Free',
    'Ketogenic',
    'None'
  ];
  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> times = [
    'Under 30 minutes',
    '30-60 minutes',
    'Over 60 minutes'
  ];

  Future<void> _searchRecipes() async {
    _showLoadingDialog();
    String apiKey = 'c6ab8afed6414c3e994ecafdbd0ee35b'; // Your API key
    String url =
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey';

    // Construct the query parameters
    Map<String, String> queryParams = {};
    if (selectedCuisine != null) {
      queryParams['cuisine'] = selectedCuisine!;
    }
    if (selectedDiet != null) {
      queryParams['diet'] = selectedDiet!;
    }
    if (selectedDifficulty != null) {
      queryParams['difficulty'] = selectedDifficulty!.toLowerCase();
    }
    if (selectedTime != null) {
      queryParams['maxReadyTime'] = selectedTime!.contains('Under')
          ? '30'
          : selectedTime!.contains('30-60')
              ? '60'
              : '120'; // Approximate time limits
    }

    // Construct full URL with parameters
    String fullUrl = '$url&${Uri(queryParameters: queryParams).query}';
    print('Request URL: $fullUrl'); // For debugging

    final response = await http.get(Uri.parse(fullUrl));

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      var data = json.decode(response.body);
      var results = Recipes.fromJson(data);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => AdvancedRecipeListPage(advancedRecipes: results),
      ));
      // Handle the data as needed, e.g., navigate to a results page
      print(data);
    } else {
      Navigator.of(context).pop();
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    selectedCuisine = sharedPrefService.preferredCuisine;
    selectedDiet = sharedPrefService.dietryRestriction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Advanced Search'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Preferred Cuisine'),
              value: selectedCuisine,
              onChanged: (value) {
                setState(() {
                  selectedCuisine = value;
                });
              },
              items: cuisines.map((cuisine) {
                return DropdownMenuItem(
                  value: cuisine,
                  child: Text(cuisine),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Dietary Restriction'),
              value: selectedDiet,
              onChanged: (value) {
                setState(() {
                  selectedDiet = value;
                });
              },
              items: diets.map((diet) {
                return DropdownMenuItem(
                  value: diet,
                  child: Text(diet),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Difficulty Level'),
              value: selectedDifficulty,
              onChanged: (value) {
                setState(() {
                  selectedDifficulty = value;
                });
              },
              items: difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Cooking Time'),
              value: selectedTime,
              onChanged: (value) {
                setState(() {
                  selectedTime = value;
                });
              },
              items: times.map((time) {
                return DropdownMenuItem(
                  value: time,
                  child: Text(time),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _searchRecipes,
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.orangeAccent),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
                child: const Text('Search Recipes')),
          ],
        ),
      ),
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
