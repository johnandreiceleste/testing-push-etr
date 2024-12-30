import 'package:flashlearn_app/model/category.dart';
import 'package:flutter/material.dart';

class AddTopic extends StatefulWidget {
  AddTopic({
    super.key,
    required this.addNewTopic,
  });

  final Function(Category topic) addNewTopic;

  @override
  State<AddTopic> createState() => AddTopicState();
}

class AddTopicState extends State<AddTopic> {
  final topicCtrl = TextEditingController();
  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Add New Topic'),
            content: TextField(
              controller: topicCtrl,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                label: Text("Topic Name"),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  topicCtrl.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF213DBB),
                  foregroundColor: Colors.white,
                ),
                onPressed: isAdding ? null : addTopic,
                child: isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Add'),
              ),
            ],
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Future<void> addTopic() async {
    final newTopicName = topicCtrl.text.trim();

    // Check if input is valid
    if (newTopicName.isEmpty) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Topic name cannot be empty')),
      );
      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      // Create a new Category object
      final newTopic = Category(
          id: DateTime.now().millisecondsSinceEpoch, name: newTopicName);

      // Call the addNewTopic function to insert into the database and update UI
      widget.addNewTopic(newTopic);

      // Close the dialog and clear the input field
      Navigator.of(context).pop();
      topicCtrl.clear();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Topic "$newTopicName" added successfully')),
      );
    } catch (e) {
      debugPrint("Error adding topic: $e");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add topic. Please try again.')),
      );
    } finally {
      setState(() {
        isAdding = false;
      });
    }
  }

  @override
  void dispose() {
    topicCtrl.dispose();
    super.dispose();
  }
}
