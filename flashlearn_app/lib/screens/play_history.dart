import 'package:flashlearn_app/helpers/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PlayHistoryScreen extends StatefulWidget {
  const PlayHistoryScreen({Key? key}) : super(key: key);

  @override
  PlayHistoryScreenState createState() => PlayHistoryScreenState();
}

class PlayHistoryScreenState extends State<PlayHistoryScreen> {
  Future<void> deleteHistory(int historyId) async {
    await DBHelper.deleteHistory(historyId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Assessment History Deleted"),
      ),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Assessment History'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(6.0),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: DBHelper.fetchHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred while fetching history.'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No assessment history available.'),
                );
              } else {
                final history = snapshot.data!;
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final item = history[index];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        tileColor: Colors.grey.withOpacity(0.1),
                        title: Text(
                          item['categoryName'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM. dd, yyyy')
                                  .format(DateTime.parse(item['datePlayed'])),
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Score: ${item['score']}',
                              style: const TextStyle(
                                color: Color(0xFF213DBB),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                          onPressed: () => showDeleteConfirmation(
                              context, item['historyId']),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void showDeleteConfirmation(BuildContext context, int historyId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this history?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteHistory(historyId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            )
          ],
        );
      },
    );
  }
}
