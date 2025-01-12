import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mynewapp/Recipedetailpage.dart';
import 'package:mynewapp/data/models/recipes.dart';
import 'package:http/http.dart' as http;

class RecipeListPage extends StatefulWidget {
  final Recipes recipesList;

  const RecipeListPage({super.key, required this.recipesList});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const String apiKey = 'c6ab8afed6414c3e994ecafdbd0ee35b';
    final result = widget.recipesList.results;

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Recipe List"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.separated(
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () async {
                  _showLoadingDialog();
                  var recipe = result[index]; // Get the first recipe

                  // Fetch detailed information about the recipe
                  final recipeResponse = await http.get(Uri.parse(
                      'https://api.spoonacular.com/recipes/${recipe.id}/information?apiKey=$apiKey'));
                  if (recipeResponse.statusCode == 200) {
                    Navigator.of(context).pop();
                    var recipeDetail = json.decode(recipeResponse.body);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailPage.fromJson(recipeDetail),
                      ),
                    );
                  } else {
                    Navigator.of(context).pop();
                    _showMessage('Failed to fetch recipe details.');
                  }
                },
                child: ListTile(
                  leading: CachedNetworkImage(
                      width: 70.0,
                      height: 70.0,
                      imageUrl: result[index].image,
                      placeholder: (context, url) =>
                          Image.asset('assets/images/placeholder.jpeg'),
                      errorWidget: (context, url, error) =>
                          Image.asset('assets/images/placeholder.jpeg')),
                  title: Text(result[index].title),
                  // subtitle: Text("Ready in: ${result[index].readyInMinutes} minutes"),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(height: 20.0);
            },
            itemCount: result.length),
      ),
    ));
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
