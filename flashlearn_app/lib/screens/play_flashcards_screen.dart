import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flashlearn_app/helpers/db_helper.dart';
import 'package:flashlearn_app/model/card_content.dart';
import 'score_screen.dart';

class PlayFlashcardsScreen extends StatefulWidget {
  PlayFlashcardsScreen(
      {super.key,
      required this.catId,
      required this.categoryName,
      required this.isShuffle});

  final int catId;
  final String categoryName;
  final bool isShuffle;
  @override
  _PlayFlashcardsScreenState createState() => _PlayFlashcardsScreenState();
}

class _PlayFlashcardsScreenState extends State<PlayFlashcardsScreen> {
  int currentIndex = 0;
  int correctAnswers = 0;
  bool isQuestion = true; // Controls whether the question or answer is shown
  final FlutterTts flutterTts = FlutterTts();

  List<CardContent> cardContents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCardContents();
    configureTTS();
  }

  Future<void> fetchCardContents() async {
    try {
      final fetchedCards = await DBHelper.fetchFlashcards(widget.catId);

      setState(() {
        cardContents = fetchedCards
            .map((card) => CardContent(
                  question: card['question'],
                  answer: card['answer'],
                  topicId: card['categoryId'],
                ))
            .toList();

        // Shuffle the cards if nag yes yung user sa dialog box
        if (widget.isShuffle == true) {
          cardContents.shuffle(Random());
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Error fetching flashcards: $e");
    }
  }

  void configureTTS() {
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
    flutterTts.setPitch(1.0);
  }

  List<CardContent> missedCards = [];

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.categoryName),
            centerTitle: true,
            backgroundColor: Color(0xFF213DBB),
          ),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (cardContents.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
          centerTitle: true,
          backgroundColor: Color(0xFFd9e9ff),
        ),
        body: Center(
          child: Text(
            'No flashcards available for this topic.',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    final currentCard = cardContents[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF213DBB),
        foregroundColor: Colors.white,
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: SizedBox(
                height: 10.0,
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / cardContents.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF213DBB)),
                ),
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Dismissible(
                key: UniqueKey(),
                direction: DismissDirection.horizontal,
                onDismissed: handleSwipe,
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.check, color: Colors.white, size: 32),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(Icons.close, color: Colors.white, size: 32),
                ),
                child: GestureDetector(
                  onDoubleTap: flipCard,
                  child: buildCardUI(currentCard),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCardUI(CardContent card) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: isQuestion ? Colors.white : Color(0xFF213DBB),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF213DBB).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isQuestion ? card.question : card.answer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isQuestion ? Color(0xFF213DBB) : Colors.white,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.volume_up,
                color: isQuestion ? Color(0xFF213DBB) : Colors.white),
            iconSize: 32.0,
            onPressed: () =>
                speakText(isQuestion ? card.question : card.answer),
          ),
        ],
      ),
    );
  }

  Future<void> speakText(String text) async {
    try {
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error during text-to-speech: $e");
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  void navigateToScoreScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreScreen(
          categoryName: widget.categoryName,
          totalCards: cardContents.length,
          correctAnswers: correctAnswers,
          missedCards: missedCards,
          catId: widget.catId,
        ),
      ),
    );
  }

  void handleSwipe(DismissDirection direction) {
    if (direction == DismissDirection.endToStart) {
      // Swiped left (incorrect answer)
      missedCards.add(cardContents[currentIndex]);
    } else if (direction == DismissDirection.startToEnd) {
      // Swiped right (correct answer)
      correctAnswers++;
    }

    if (currentIndex < cardContents.length - 1) {
      setState(() {
        currentIndex++;
        isQuestion = true; // Reset to show the question
      });
    } else {
      navigateToScoreScreen();
    }
  }

  void flipCard() {
    setState(() {
      isQuestion = !isQuestion; // Toggle between question and answer
    });
  }
}
