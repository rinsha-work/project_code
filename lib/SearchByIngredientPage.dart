// lib/pages/search_by_ingredient_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mynewapp/data/models/ingredient_recipes.dart';
import 'package:mynewapp/ingredient_recipe_list_page.dart';
import 'dart:convert';

class SearchByIngredientPage extends StatefulWidget {
  @override
  _SearchByIngredientPageState createState() => _SearchByIngredientPageState();
}

class _SearchByIngredientPageState extends State<SearchByIngredientPage> {
  final Map<String, List<String>> _ingredients = {
    'Meats': ['Chicken', 'Beef', 'Pork', 'Fish'],
    'Vegetables': ['Carrot', 'Potato', 'Tomato', 'Spinach'],
    'Spices': ['Salt', 'Pepper', 'Paprika', 'Cumin'],
  };

  Map<String, bool> _selectedIngredients = {};
  final String apiKey =
      'c6ab8afed6414c3e994ecafdbd0ee35b'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    for (var category in _ingredients.keys) {
      for (var ingredient in _ingredients[category]!) {
        _selectedIngredients[ingredient] = false;
      }
    }
  }

  Future<void> _searchRecipes() async {
    List<String> selected = _selectedIngredients.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selected.isEmpty) {
      _showMessage('Please select at least one ingredient.');
      return;
    }
    _showLoadingDialog();

    String ingredientList = selected.join(',');
    print(
        "Request URL: 'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientList&apiKey=$apiKey");
    final response = await http.get(Uri.parse(
        'https://api.spoonacular.com/recipes/findByIngredients?ingredients=$ingredientList&apiKey=$apiKey'));

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      final recipes = json.decode(response.body);
      final ingredientRecipes = List<IngredientRecipes>.from(
          recipes.map((x) => IngredientRecipes.fromJson(x)));
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              IngredientRecipeListPage(recipes: ingredientRecipes)));
      // List<RecipeDetail> recipeDetails = await _fetchRecipeDetails(recipes);
      // Navigator.of(context).pop();
      // _showRecipes(recipeDetails);
    } else {
      Navigator.of(context).pop();
      _showMessage('Failed to fetch recipes.');
    }
  }

  Future<List<RecipeDetail>> _fetchRecipeDetails(List<dynamic> recipes) async {
    List<RecipeDetail> recipeDetails = [];
    for (var recipe in recipes) {
      int recipeId = recipe['id'];
      final response = await http.get(Uri.parse(
          'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey'));
      if (response.statusCode == 200) {
        var recipeInfo = json.decode(response.body);
        recipeDetails.add(RecipeDetail.fromJson(recipeInfo));
      }
    }
    return recipeDetails;
  }

  void _showRecipes(List<RecipeDetail> recipes) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recipes'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Set a height to allow scrolling
            child: ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recipes[index].title),
                  leading: Image.network(recipes[index].imageUrl,
                      width: 50, height: 50),
                  subtitle: Text(recipes[index].summary),
                  onTap: () {
                    _showRecipeDetails(recipes[index]);
                  },
                );
              },
            ),
          ),
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

  void _showRecipeDetails(RecipeDetail recipe) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(recipe.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(recipe.imageUrl),
                const SizedBox(height: 10),
                const Text('Ingredients:'),
                ...recipe.ingredients
                    .map((ingredient) => Text('- $ingredient'))
                    .toList(),
                const SizedBox(height: 10),
                const Text('Instructions:'),
                Text(recipe.instructions),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search by Ingredient'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView(
                children: _ingredients.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ...entry.value.map((ingredient) {
                        return CheckboxListTile(
                          title: Text(ingredient),
                          value: _selectedIngredients[ingredient],
                          activeColor: Colors.orangeAccent,
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedIngredients[ingredient] = value ?? false;
                            });
                          },
                        );
                      }).toList(),
                      const Divider(),
                    ],
                  );
                }).toList(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _searchRecipes,
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.orangeAccent),
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white)),
                  child: const Text('Search Recipes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetail {
  final String title;
  final String imageUrl;
  final String summary;
  final String instructions;
  final List<String> ingredients;

  RecipeDetail({
    required this.title,
    required this.imageUrl,
    required this.summary,
    required this.instructions,
    required this.ingredients,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      title: json['title'],
      imageUrl: json['image'],
      summary: json['summary'],
      instructions: json['instructions'] ?? 'No instructions available.',
      ingredients: List<String>.from(
          json['extendedIngredients'].map((ingredient) => ingredient['name'])),
    );
  }
}
