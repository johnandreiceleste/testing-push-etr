import 'package:flashlearn_app/helpers/db_helper.dart';
import 'package:flashlearn_app/model/category.dart';
import 'package:flashlearn_app/screens/play_flashcards_screen.dart';
import 'package:flutter/material.dart';

class ViewTopicScreen extends StatefulWidget {
  ViewTopicScreen({
    super.key,
    required this.categoryList,
  });

  final Category categoryList;
  @override
  State<ViewTopicScreen> createState() => ViewTopicScreenState();
}

class ViewTopicScreenState extends State<ViewTopicScreen> {
  Future<List<Map<String, dynamic>>> fetchFlashcards() async {
    return await DBHelper.fetchFlashcards(widget.categoryList.id!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryList.name),
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                showAddFlashcard(context);
              },
              icon: Icon(
                Icons.add_circle,
              ),
            )
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchFlashcards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No flashcards found.'));
            } else {
              var flashcards = snapshot.data!;

              return ListView.builder(
                itemCount: flashcards.length,
                itemBuilder: (context, index) {
                  var flashcard = flashcards[index];

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 3.0,
                      bottom: 3.0,
                      left: 8.0,
                      right: 8.0,
                    ),
                    child: Card(
                      color: Color(0xFFd9eaff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ),
                      ),
                      child: ListTile(
                        title: Text(flashcard['question']),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Answer: ",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                "${flashcard['answer']}",
                                style: TextStyle(
                                  color: Color(0xFF213DBB),
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                showEditQuestionDialog(context, flashcard);
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Color(0xFF213DBB),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showDeleteConfirmationDialog(
                                    context, flashcard);
                              },
                              icon: Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: showPlayInstructions,
          child: const Icon(Icons.play_arrow),
        ),
      ),
    );
  }

  void showPlayInstructions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('How to Use Play Feature'),
          content: const SingleChildScrollView(
            child: Text(
              textAlign: TextAlign.left,
              '''Here’s how to use the Play feature:

1. Each flashcard has two sides:
The front side contains the question or term. The back side contains the answer, which will be revealed when you double-tap the card.

2. A button at the bottom center of the card enables text-to-speech functionality.

3. After finding out the answer:
   - Swipe RIGHT if you got it right.
   - Swipe LEFT if you got it wrong.

4. Once all cards have been played:
A score screen will display your score.If you missed some cards, a button will allow you to view all missed cards for review.''',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213DBB),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                startPlayingFlashcards();
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void showAddFlashcard(BuildContext context) {
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF213DBB),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final newQuestion = questionController.text.trim();
                final newAnswer = answerController.text.trim();

                if (newQuestion.isEmpty || newAnswer.isEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Question or Answer cannot be empty.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  return;
                }

                DBHelper.insertFlashcard({
                  DBHelper.colCategoryId: widget.categoryList.id,
                  DBHelper.colQuestion: newQuestion,
                  DBHelper.colAnswer: newAnswer,
                }).then((_) {
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('New flashcard added.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(
      BuildContext context, Map<String, dynamic> flashcard) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this flashcard?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteFlashcard(flashcard['cardId']);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void deleteFlashcard(int cardId) async {
    try {
      await DBHelper.deleteFlashcard(cardId);
      setState(() {}); // Refresh the list of flashcards
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flashcard deleted successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete flashcard: $e')),
      );
    }
  }

  void showEditQuestionDialog(
      BuildContext context, Map<String, dynamic> flashcard) {
    final questionController =
        TextEditingController(text: flashcard[DBHelper.colQuestion]);
    final answerController =
        TextEditingController(text: flashcard[DBHelper.colAnswer]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF213DBB),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final updatedQuestion = questionController.text.trim();
                final updatedAnswer = answerController.text.trim();

                if (updatedQuestion.isNotEmpty && updatedAnswer.isNotEmpty) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Changes'),
                        content: Text(
                            'Are you sure you want to save these changes?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF213DBB),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              DBHelper.updateFlashcard({
                                DBHelper.colCategoryId: widget.categoryList.id,
                                DBHelper.colQuestion: updatedQuestion,
                                DBHelper.colAnswer: updatedAnswer,
                              }, flashcard[DBHelper.colCardId])
                                  .then((_) {
                                setState(() {});

                                Navigator.pop(context);
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Flashcard updated successfully'),
                                  ),
                                );
                              });
                            },
                            child: Text('Confirm'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void startPlayingFlashcards() async {
    bool isShuffle = false; // Default to not shuffled

    // Show shuffle dialog, tanong user if want the card to be shuffled before playing
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Shuffle Flashcards'),
          content: const Text(
              'Do you want to shuffle the flashcards before playing?'),
          actions: [
            TextButton(
              onPressed: () {
                isShuffle = false; // No shuffle
                Navigator.pop(context);
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF213DBB),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                isShuffle = true; // Shuffle
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    // Fetch flashcards for the category
    final flashcards = await fetchFlashcards();

    if (flashcards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flashcards to play!')),
      );
      return;
    }

    // Navigate to PlayFlashcardsScreen with shuffle preference
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayFlashcardsScreen(
          catId: widget.categoryList.id!,
          categoryName: widget.categoryList.name,
          isShuffle: isShuffle, // Pass the shuffle preference
        ),
      ),
    );
  }
}
