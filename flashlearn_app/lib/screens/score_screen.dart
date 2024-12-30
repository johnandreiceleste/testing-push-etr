import 'package:flashlearn_app/helpers/db_helper.dart';
import 'package:flashlearn_app/model/card_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'missed_cards_screen.dart';
import 'package:flashlearn_app/screens/homescreen.dart';

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({
    super.key,
    required this.totalCards,
    required this.correctAnswers,
    required this.missedCards,
    required this.catId,
    required this.categoryName,
  });

  final int totalCards;
  final int correctAnswers;
  final List<CardContent> missedCards;
  final int catId;
  final String categoryName;

  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  @override
  void initState() {
    super.initState();
    _logPlayHistory();
  }

  void _logPlayHistory() {
    final String datePlayed =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    DBHelper.insertHistory({
      'categoryName': widget.categoryName,
      'score': '${widget.correctAnswers} / ${widget.totalCards}',
      'datePlayed': datePlayed,
    });
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = (widget.correctAnswers / widget.totalCards) * 100;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _getColor(percentage),
          title: const Text('Your Score'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: _getColor(percentage),
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 250.0,
                      child: Image.asset(
                        _getScoreImage(percentage),
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'You answered:',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${widget.correctAnswers} / ${widget.totalCards}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Correctly!',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (widget.missedCards.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MissedCardsScreen(
                                    missedCards: widget.missedCards,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text(
                              'View Missed Cards',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _getColor(percentage),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 18),
                            ),
                          ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text(
                            'Restart',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _getColor(percentage),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.exit_to_app),
                          label: const Text(
                            'Exit',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _getColor(percentage),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(double percentage) {
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 75) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }

  String _getScoreImage(double percentage) {
    if (percentage >= 0 && percentage < 50) {
      return 'assets/drawer_header/score_red.png';
    } else if (percentage >= 50 && percentage < 75) {
      return 'assets/drawer_header/score_yellow.png';
    } else if (percentage >= 75 && percentage <= 100) {
      return 'assets/drawer_header/score_green.png';
    }
    return 'assets/drawer_header/flashlearn_header.png'; // Default image
  }
}
