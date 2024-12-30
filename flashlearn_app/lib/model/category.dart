import '../helpers/db_helper.dart';

class Category {
  late int? id;
  late String name;

  Category({
    this.id,
    required this.name,
  });

  Category.withoutId({required this.name});

  Map<String, dynamic> toMap() {
    return {
      DBHelper.colCatId: id,
      DBHelper.colCatName: name,
    };
  }

  Map<String, dynamic> toMapWithoutId() {
    return {
      DBHelper.colCatName: name,
    };
  }
}
