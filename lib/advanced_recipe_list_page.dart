import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mynewapp/Recipedetailpage.dart';
import 'package:mynewapp/data/models/recipes.dart';
import 'package:http/http.dart' as http;

class AdvancedRecipeListPage extends StatefulWidget {
  final Recipes advancedRecipes;
  const AdvancedRecipeListPage({super.key, required this.advancedRecipes});

  @override
  State<AdvancedRecipeListPage> createState() => _AdvancedRecipeListPageState();
}

class _AdvancedRecipeListPageState extends State<AdvancedRecipeListPage> {
  String apiKey = 'c6ab8afed6414c3e994ecafdbd0ee35b';
  @override
  Widget build(BuildContext context) {
    final results = widget.advancedRecipes.results;

    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'Advanced Recipes'
            ),
            backgroundColor: Colors.orangeAccent,
            foregroundColor: Colors.white,
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () async {
                      _showLoadingDialog();
                      final recipeResponse = await http.get(Uri.parse(
                          'https://api.spoonacular.com/recipes/${results[index].id}/information?apiKey=$apiKey'));
                      if (recipeResponse.statusCode == 200) {
                        Navigator.of(context).pop();
                        var recipeDetail = json.decode(recipeResponse.body);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailPage.fromJson(recipeDetail),
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
                          imageUrl: results[index].image,
                          placeholder: (context, url) => Image.asset('assets/images/placeholder.jpeg'),
                          errorWidget: (context, url, error) => Image.asset('assets/images/placeholder.jpeg')
                      ),
                      title: Text(results[index].title),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 20.0,
                  );
                },
                itemCount: results.length
            ),
          ),
        )
    );
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
        )
    );
  }
}
