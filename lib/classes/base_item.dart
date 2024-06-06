import 'package:tractian_challenge_app/classes/item.dart';

enum ItemType { asset, location }

abstract class BaseItem {
  String get id;
  String get name;
  String? get parentId;
  String? get locationId;
  double get position;
  List<Item> get children;
  String get sensorType;
  String get status;
  ItemType get type;
}
