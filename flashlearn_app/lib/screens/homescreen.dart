import 'package:flashlearn_app/helpers/db_helper.dart';
import 'package:flashlearn_app/model/category.dart';
import 'package:flashlearn_app/screens/components/add_topic_component.dart';
import 'package:flashlearn_app/screens/play_history.dart';
import 'package:flashlearn_app/screens/view_all_topics_screen.dart';
import 'package:flashlearn_app/screens/view_topic_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Category> categories = [];
  List<Category> filteredCategories = []; // To store filtered categories
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories = await DBHelper.fetchCategories();
      debugPrint('Fetched Categories: $fetchedCategories');

      setState(() {
        categories = fetchedCategories
            .map((category) => Category(
                  id: category['catId'],
                  name: category['catName'],
                ))
            .toList();
        filteredCategories =
            categories; // display all categories initially if no search input
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterCategories(String query) {
    final updatedCategories = categories
        .where((category) =>
            category.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      filteredCategories = updatedCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/drawer_header/header_logo.png',
            height: 40, // Adjust the height as needed
          ),
          centerTitle: true,
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF213DBB),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/drawer_header/flashlearn_header.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.category_rounded,
                  color: Color(0xFF213DBB),
                ),
                title: const Text('View All Topics'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewAllTopicsScreen(),
                    ),
                  );

                  if (result == true) {
                    fetchCategories(); // Re-fetch or update data if changes occurred
                  }
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.history,
                  color: Color(0xFF213DBB),
                ),
                title: const Text('Assessment History'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PlayHistoryScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 12.0,
                  right: 12.0,
                  top: 8.0,
                  bottom: 4.0,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF213DBB),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(90),
                    ),
                    hintText: 'Search Topics...',
                  ),
                  onChanged:
                      filterCategories, // Trigger filtering sa search pag nag on text change
                ),
              ),
              // const SizedBox(height: 15),
              isLoading
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : filteredCategories.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text(
                              'No flashcards available. Add a new one!',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 4 / 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemBuilder: (_, index) {
                                final category = filteredCategories[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ViewTopicScreen(
                                          categoryList: category,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFF213DBB),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            textAlign: TextAlign.center,
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              itemCount: filteredCategories.length,
                            ),
                          ),
                        ),
            ],
          ),
        ),
        floatingActionButton: AddTopic(
          addNewTopic: addNewTopic,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  void addNewTopic(Category topic) async {
    try {
      await DBHelper.insertCategory({
        'catName': topic.name,
      });

      await fetchCategories();
    } catch (e) {
      debugPrint("Error adding new topic: $e");
    }
  }
}
