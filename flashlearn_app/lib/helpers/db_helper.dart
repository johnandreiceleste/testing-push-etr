import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const String dbName = 'flashlearn.db';
  static const int dbVersion = 5;

  // Table: Category
  static const String categoryTable = 'categories';
  static const String colCatId = 'catId';
  static const String colCatName = 'catName';

  // Table: Flashcard
  static const String flashcardTable = 'flashcards';
  static const String colCardId = 'cardId';
  static const String colCategoryId = 'categoryId';
  static const String colQuestion = 'question';
  static const String colAnswer = 'answer';

//Table: History
  static const String historyTable = 'history';
  static const String colHistoryId = 'historyId';
  static const String colCategoryName = 'categoryName';
  static const String colScore = 'score';
  static const String colDatePlayed = 'datePlayed';

//for debuging pag nag error ang db edited dec. 29, 2024, 3pm
  static Future<void> deleteDatabaseFile() async {
    var path = join(await getDatabasesPath(), dbName);
    await deleteDatabase(path);
  }

// Open Database
  static Future<Database> openDB() async {
    var path = join(await getDatabasesPath(), dbName);

    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $categoryTable (
            $colCatId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colCatName TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE $flashcardTable (
            $colCardId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colCategoryId INTEGER NOT NULL,
            $colQuestion TEXT NOT NULL,
            $colAnswer TEXT NOT NULL,
            FOREIGN KEY ($colCategoryId) REFERENCES $categoryTable ($colCatId)
          )
        ''');
        await db.execute('''
          CREATE TABLE $historyTable (
            $colHistoryId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colCategoryName TEXT NOT NULL,
            $colScore TEXT NOT NULL,
            $colDatePlayed TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Insert Category/Topic
  static Future<int> insertCategory(Map<String, dynamic> category) async {
    var db = await openDB();
    return await db.insert(categoryTable, category);
  }

  // Fetch All Categories/Topics
  // static Future<List<Map<String, dynamic>>> fetchCategories() async {
  //   var db = await openDB();
  //   return await db.query(categoryTable);
  // }

  static Future<List<Map<String, dynamic>>> fetchCategories() async {
    var db = await openDB();
    return await db.query(
      categoryTable,
      orderBy: 'catId DESC', // descending na siya, new topic on top of old
    );
  }

  // Insert flashcard
  static Future<int> insertFlashcard(Map<String, dynamic> flashcard) async {
    var db = await openDB();
    return await db.insert(flashcardTable, flashcard);
  }

  // Fetch flashcards by Category ID
  static Future<List<Map<String, dynamic>>> fetchFlashcards(
      int categoryId) async {
    var db = await openDB();
    return await db.query(
      flashcardTable,
      where: '$colCategoryId = ?',
      whereArgs: [categoryId],
    );
  }

  // Update flashcard
  static Future<int> updateFlashcard(
      Map<String, dynamic> flashcard, int cardId) async {
    var db = await openDB();
    return await db.update(
      flashcardTable,
      flashcard,
      where: '$colCardId = ?',
      whereArgs: [cardId],
    );
  }

  // Delete flashcard
  static Future<int> deleteFlashcard(int cardId) async {
    var db = await openDB();
    return await db.delete(
      flashcardTable,
      where: '$colCardId = ?',
      whereArgs: [cardId],
    );
  }

  // Count Cards of topic/category
  static Future<int> countCards(int categoryId) async {
    try {
      final db = await openDB();
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $flashcardTable WHERE $colCategoryId = ?',
        [categoryId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Error counting cards: $e');
      return 0;
    }
  }

  // Delete Category
  static Future<void> deleteCategory(int categoryId) async {
    try {
      final db = await openDB();

      //  delete all flashcards associated with this category
      await db.delete(
        flashcardTable,
        where: '$colCategoryId = ?',
        whereArgs: [categoryId],
      );

      // delete the category itself
      await db.delete(
        categoryTable,
        where: '$colCatId = ?',
        whereArgs: [categoryId],
      );
    } catch (e) {
      print('Error deleting category: $e');
      throw Exception('Failed to delete category');
    }
  }

//Udating category
  static Future<void> updateCategory(int catId, String newName) async {
    final db = await DBHelper.openDB();
    await db.update(
      'categories',
      {'catName': newName},
      where: 'catId = ?',
      whereArgs: [catId],
    );
  }

//HISTORY DB <-------->

// Insert History
  static Future<int> insertHistory(Map<String, dynamic> history) async {
    var db = await openDB();
    return await db.insert(historyTable, history);
  }

// Fetch all history (ordered by datePlayed DESC)
  static Future<List<Map<String, dynamic>>> fetchHistory() async {
    var db = await openDB();
    return await db.query(
      historyTable,
      orderBy: '$colDatePlayed DESC',
    );
  }

  // delete history

  static Future<int> deleteHistory(int historyId) async {
    print("Deleting history ID: $historyId");

    var db = await openDB();
    return await db.delete(
      historyTable,
      where: '$colHistoryId = ?',
      whereArgs: [historyId],
    );
  }
}
