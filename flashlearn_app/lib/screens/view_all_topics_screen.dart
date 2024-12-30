import 'package:flutter/material.dart';
import 'package:flashlearn_app/helpers/db_helper.dart';

class ViewAllTopicsScreen extends StatefulWidget {
  const ViewAllTopicsScreen({Key? key}) : super(key: key);

  @override
  State<ViewAllTopicsScreen> createState() => ViewAllTopicsScreenState();
}

class ViewAllTopicsScreenState extends State<ViewAllTopicsScreen> {
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await DBHelper.fetchCategories();
      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching categories: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteCategory(int catId) async {
    try {
      await DBHelper.deleteCategory(catId);
      await fetchCategories(); // Refresh categories after mag delete
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted successfully')),
      );
    } catch (e) {
      debugPrint("Error deleting category: $e");
    }
  }

  Future<void> confirmDelete(int catId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteCategory(catId);
                Navigator.pop(
                    context, true); // Notify the previous screen of the change
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> editCategory(int catId, String currentName) async {
    final TextEditingController nameController =
        TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213DBB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty && newName != currentName) {
                  Navigator.of(context).pop();
                  confirmEdit(catId, newName);
                } else if (newName == currentName) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No changes made to the category'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> confirmEdit(int catId, String newName) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Edit'),
          content: const Text('Are you sure you want to edit this category?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213DBB),
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await DBHelper.updateCategory(catId, newName);
                  await fetchCategories();
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category updated successfully'),
                    ),
                  );
                  Navigator.pop(context, true);
                } catch (e) {
                  debugPrint("Error updating category: $e");
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating category: $e'),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('All Topics'),
          backgroundColor: Color(0xFF213DBB),
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF213DBB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          category['catName'],
                          style: TextStyle(
                            color: Color(0xFF213DBB),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: FutureBuilder<int>(
                          future: DBHelper.countCards(category['catId']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading...');
                            }
                            return Text('${snapshot.data ?? 0} cards');
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF213DBB),
                              ),
                              onPressed: () => editCategory(
                                  category['catId'], category['catName']),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                              onPressed: () => confirmDelete(category['catId']),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
