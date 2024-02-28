import 'package:flutter/material.dart';

class RecipeDetail extends StatelessWidget {
  final String recipeSteps;
  final String imageURL;
  final List<Map<String, String>> ingredients;
  final String recipeName;
  RecipeDetail({
    required this.recipeSteps,
    required this.imageURL,
    required this.ingredients,
    required this.recipeName,
  });

  @override
  Color mainColor = Color.fromARGB(255, 0, 0, 0);
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipeName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: mainColor,
            fontSize: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Image.network(
                imageURL,
                height: 400,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients:',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  buildIngredientsList(),
                  SizedBox(height: 16),
                  Text(
                    'Recipe:',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...recipeSteps
                                .split('\n')
                                .where((step) => step
                                    .trim()
                                    .isNotEmpty) // Exclude empty lines
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key + 1;
                              String step = entry.value;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$index.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        step.trim(),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIngredientsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients
          .asMap()
          .entries
          .map((entry) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}.',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${entry.value['name']} - ${entry.value['measure']}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}
