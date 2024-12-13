import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:foodilit/recipecard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:foodilit/recipe_detail.dart';
import 'package:foodilit/services/auth_service.dart';
import 'package:foodilit/login_page.dart';

class Recipes extends StatefulWidget {
  const Recipes({Key? key}) : super(key: key);

  @override
  State<Recipes> createState() => _RecipesState();
}

class _RecipesState extends State<Recipes> {
  final AuthService _auth = AuthService();
  TextEditingController _controller = TextEditingController();
  String storedText = " ";
  var fooditem = "Pizza";
  Widget cardWidget = Container();
  Color mainColor = Color.fromARGB(255, 0, 0, 0);

  @override
  void initState() {
    super.initState();
    getRandomRecipe();
  }

  Future<Map<String, dynamic>> getRandomRecipe() async {
    try {
      final res = await http
          .get(Uri.parse("https://www.themealdb.com/api/json/v1/1/random.php"));
      if (res.statusCode != 200) {
        throw Exception("Failed to Load Recipe ${res.statusCode}");
      }
      final Map<String, dynamic> data = jsonDecode(res.body);
      final List<dynamic> meals = data['meals'];
      if (meals != null && meals.isNotEmpty) {
        final Map<String, dynamic> randomMeal = meals[0];
        return randomMeal;
      } else {
        throw Exception("Meals data is null or empty");
      }
    } catch (e) {
      throw Exception('Unexpected Error Ocurred!');
    }
  }

  Future<Map<String, dynamic>> getRecipeData() async {
    try {
      final res = await http.get(Uri.parse(
          "https://www.themealdb.com/api/json/v1/1/search.php?s=$fooditem"));
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

  Future<List<Map<String, dynamic>>> singleRecipeData() async {
    try {
      final res = await http.get(Uri.parse(
          "https://www.themealdb.com/api/json/v1/1/filter.php?i=$storedText"));
      if (res.statusCode != 200) {
        throw Exception("Failed to Load Recipe ${res.statusCode}");
      }
      final Map<String, dynamic> data = jsonDecode(res.body);
      final List<dynamic> meals = data['meals'];
      if (meals != null && meals.isNotEmpty) {
        //print(meals);
        final List<Map<String, dynamic>> cards = [];

        for (int i = 0; i <= 3; i++) {
          String? mealName = meals[i]['strMeal'];
          String? mealImg = meals[i]['strMealThumb'];
          String? mealId = meals[i]['idMeal'];
          if (mealName != null) {
            cards.add({
              'strMeal': mealName,
              'strMealThumb': mealImg ?? '',
              'Idmeal': mealId ?? '',
            });
          }
        }

        print(cards);

        return cards;
      } else {
        throw Exception("Meals data is null or empty");
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> combinedData() async {
    Map<String, dynamic> data1 = await getRecipeData();
    Map<String, dynamic> data2 = await getRandomRecipe();
    Map<String, dynamic> data3 = await getRandomRecipe();
    Map<String, dynamic> data4 = await getRandomRecipe();
    Map<String, dynamic> data5 = await getRandomRecipe();
    Map<String, dynamic> combinedMap = {
      'recipeData': data1,
      'randomRecipe1': data2,
      'randomRecipe2': data3,
      'randomRecipe3': data4,
      'randomRecipe4': data5,
    };

    return combinedMap;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: combinedData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        final data = snapshot.data;
        if (data == null) {
          return const Text("No Data Available");
        }
        final recipeData = data['recipeData'];
        final randomRecipe1 = data['randomRecipe1'];
        final randomRecipe2 = data['randomRecipe2'];
        final randomRecipe3 = data['randomRecipe3'];
        final randomRecipe4 = data['randomRecipe4'];
        List<Map<String, String>> getIngredient(
            Map<String, dynamic> recipeData) {
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

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Recipes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 25,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
            toolbarHeight: 80,
            // automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 40, right: 40),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    onSubmitted: (String value) async {
                      storedText = value;
                      print('Stored text: $storedText');
                      try {
                        List<Map<String, dynamic>> singleIngRecipe =
                            await singleRecipeData();
                        setState(() {
                          if (singleIngRecipe.isNotEmpty) {
                            cardWidget = Column(
                              children: singleIngRecipe.map((recipe) {
                                String mealName = recipe['strMeal'] ?? '';
                                String mealThumb = recipe['strMealThumb'] ?? '';
                                String mealId = recipe['Idmeal'] ?? '';
                                return RecipeCard(
                                  MealThumb: mealThumb,
                                  MealName: mealName,
                                  MealId: mealId,
                                );
                              }).toList(),
                            );
                          } else {
                            print('singleIngRecipe is empty or null');
                          }
                        });
                      } catch (e) {
                        print("Error: $e");
                      }
                    },
                    controller: _controller,
                    decoration: InputDecoration(
                        hintText: "Write Your Single Ingredient...",
                        prefixIcon: Icon(Icons.search),
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 84, 84, 84),
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 227, 226, 226),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.transparent,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        )),
                  ),
                ),
                if (cardWidget != null) cardWidget,
                const Padding(
                  padding: EdgeInsets.only(
                    top: 40,
                    left: 30,
                    bottom: 15,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Popular Dishes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (recipeData != null && recipeData.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(
                                  recipeSteps:
                                      randomRecipe1['strInstructions'] ?? '',
                                  imageURL: randomRecipe1['strMealThumb'] ?? '',
                                  ingredients: getIngredient(randomRecipe1),
                                  recipeName: randomRecipe1['strMeal'] ?? '',
                                ),
                              ),
                            );
                          } else {
                            print("Error: Random recipe data is null or empty");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.center,
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
                                      randomRecipe1['strMealThumb'] ?? '',
                                      fit: BoxFit.cover,
                                      height: 270,
                                      width: 270,
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        child: Text(
                                          randomRecipe1['strMeal'] ?? '',
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
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (recipeData != null && recipeData.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(
                                  recipeSteps:
                                      randomRecipe2['strInstructions'] ?? '',
                                  imageURL: randomRecipe2['strMealThumb'] ?? '',
                                  ingredients: getIngredient(randomRecipe2),
                                  recipeName: randomRecipe2['strMeal'] ?? '',
                                ),
                              ),
                            );
                          } else {
                            print("Error: Random recipe data is null or empty");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.center,
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
                                      randomRecipe2['strMealThumb'] ?? '',
                                      fit: BoxFit.cover,
                                      height: 270,
                                      width: 270,
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        child: Text(
                                          randomRecipe2['strMeal'] ?? '',
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
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (recipeData != null && recipeData.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(
                                  recipeSteps:
                                      randomRecipe3['strInstructions'] ?? '',
                                  imageURL: randomRecipe3['strMealThumb'] ?? '',
                                  ingredients: getIngredient(randomRecipe3),
                                  recipeName: randomRecipe3['strMeal'] ?? '',
                                ),
                              ),
                            );
                          } else {
                            print("Error: Random recipe data is null or empty");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.center,
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
                                      randomRecipe3['strMealThumb'] ?? '',
                                      fit: BoxFit.cover,
                                      height: 270,
                                      width: 270,
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        child: Text(
                                          randomRecipe3['strMeal'] ?? '',
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
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (recipeData != null && recipeData.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(
                                  recipeSteps:
                                      randomRecipe4['strInstructions'] ?? '',
                                  imageURL: randomRecipe4['strMealThumb'] ?? '',
                                  ingredients: getIngredient(randomRecipe4),
                                  recipeName: randomRecipe4['strMeal'] ?? '',
                                ),
                              ),
                            );
                          } else {
                            print("Error: Random recipe data is null or empty");
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Align(
                            alignment: Alignment.center,
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
                                      randomRecipe4['strMealThumb'] ?? '',
                                      fit: BoxFit.cover,
                                      height: 270,
                                      width: 270,
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 5,
                                      right: 5,
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Colors.black.withOpacity(0.6),
                                        ),
                                        child: Text(
                                          randomRecipe4['strMeal'] ?? '',
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
                        ),
                      ),
                      SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(
                    top: 10,
                    left: 25,
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Trending Recipes",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            fooditem = "Burger";
                            Map<String, dynamic>? recipeData =
                                await getRecipeData();
                            if (recipeData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetail(
                                    recipeSteps:
                                        recipeData['strInstructions'] ?? '',
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
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                                child: SizedBox(
                                  height: 80,
                                  width: 100,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        "assets/burger.png",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Text(
                              //   "Burger",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () async {
                          fooditem = "Pizza";
                          Map<String, dynamic>? recipeData =
                              await getRecipeData();
                          if (recipeData != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(
                                  recipeSteps:
                                      recipeData['strInstructions'] ?? '',
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
                        child: Expanded(
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                                child: SizedBox(
                                  height: 80,
                                  width: 100,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Image.asset(
                                          "assets/pizza.png",
                                          height: 90,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Text(
                              //   "Pizza",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            fooditem = "Salad";
                            Map<String, dynamic>? recipeData =
                                await getRecipeData();
                            if (recipeData != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetail(
                                    recipeSteps:
                                        recipeData['strInstructions'] ?? '',
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
                          child: Column(
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                                child: SizedBox(
                                  height: 80,
                                  width: 100,
                                  child: Stack(
                                    children: [
                                      Image.asset(
                                        "assets/salad.png",
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Text(
                              //   "Salad",
                              //   style: TextStyle(fontWeight: FontWeight.bold),
                              // ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
