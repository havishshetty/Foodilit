import 'package:flutter/material.dart';
import 'package:foodilit/recipe_detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeCard extends StatelessWidget {
  final String? MealThumb;
  final String? MealName;
  final String? MealId;

  const RecipeCard({
    required this.MealThumb,
    required this.MealName,
    required this.MealId,
  });

  Future<Map<String, dynamic>> getRecipeData() async {
    if (MealId == null) {
      throw Exception("MealId is null");
    }
    try {
      final res = await http.get(Uri.parse(
          "https://www.themealdb.com/api/json/v1/1/lookup.php?i=$MealId"));
      if (res.statusCode != 200) {
        throw Exception("Failed to Load Recipe ${res.statusCode}");
      }
      final Map<String, dynamic> data = jsonDecode(res.body);
      final List<dynamic> meals = data['meals'];
      if (meals != null && meals.isNotEmpty) {
        final Map<String, dynamic> firstMeal = meals[0];
        return firstMeal;
      } else {
        throw Exception("Meals data is null or empty");
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  List<Map<String, String>> getIngredient(Map<String, dynamic> recipeData) {
    List<Map<String, String>> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String ingredientName = recipeData['strIngredient$i'];
      String ingredientMeasure = recipeData['strMeasure$i'];
      if (ingredientName != null && ingredientName.isNotEmpty) {
        ingredients.add({
          'name': ingredientName,
          'measure': ingredientMeasure ?? '',
        });
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Map<String, dynamic>? recipeData = await getRecipeData();
        if (recipeData != null && recipeData.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetail(
                recipeSteps: recipeData['strInstructions'] ?? '',
                imageURL: recipeData['strMealThumb'] ?? '',
                ingredients: getIngredient(recipeData),
                recipeName: recipeData['strMeal'] ?? '',
              ),
            ),
          );
        } else {
          print("Error: Recipe data is null");
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.network(
                  MealThumb ?? '',
                  fit: BoxFit.cover,
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                ),
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.black.withOpacity(0.6),
                    ),
                    child: Text(
                      MealName ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
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
