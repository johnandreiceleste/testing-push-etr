import '../helpers/db_helper.dart';

class Flashcard {
  late int id;
  late int categoryId;
  late String question;
  late String answer;

  Flashcard({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.answer,
  });

  Flashcard.withoutId({
    required this.categoryId,
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toMap() {
    return {
      DBHelper.colCardId: id,
      DBHelper.colCategoryId: categoryId,
      DBHelper.colQuestion: question,
      DBHelper.colAnswer: answer,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      DBHelper.colCategoryId: categoryId,
      DBHelper.colQuestion: question,
      DBHelper.colAnswer: answer,
    };
  }
}
