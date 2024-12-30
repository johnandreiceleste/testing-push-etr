import 'package:flutter/material.dart';
import 'package:flashlearn_app/model/card_content.dart';

class MissedCardsScreen extends StatelessWidget {
  const MissedCardsScreen({Key? key, required this.missedCards})
      : super(key: key);

  final List<CardContent> missedCards;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Missed Cards'),
          centerTitle: true,
          backgroundColor: Colors.red,
        ),
        body: missedCards.isEmpty
            ? const Center(
                child: Text(
                  'No missed cards!',
                  style: TextStyle(fontSize: 18),
                ),
              )
            : ListView.builder(
                itemCount: missedCards.length,
                itemBuilder: (context, index) {
                  final card = missedCards[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      tileColor: Color(0xFFffbaba),
                      title: Text(
                        card.question,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Text(
                            "Answer:",
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            card.answer,
                            style: TextStyle(
                              color: Color(0xFFa70000),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
