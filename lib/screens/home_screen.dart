import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> futureMeals;

  @override
  void initState() {
    super.initState();
    // Initialize the future with the API call
    futureMeals = fetchMeals();
  }

  Future<List<dynamic>> fetchMeals() async {
    final url =
        Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=a');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body)['meals'];
      } else {
        throw Exception('Failed to load meals');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meals"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureMeals,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final meals = snapshot.data!;
            return ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                final controller = ExpandedTileController();
                return ExpandedTile(
                  controller: controller,
                  title: Text(meal['strMeal'],
                      style: const TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      Image.network(meal['strMealThumb']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(meal['strInstructions'] ??
                            'No description available'),
                      ),
                    ],
                  ),
                  theme: const ExpandedTileThemeData(
                    headerColor: Colors.black12,
                    contentBackgroundColor: Colors.white,
                    contentPadding: EdgeInsets.all(10),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
