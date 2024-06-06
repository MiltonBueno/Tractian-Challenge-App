import 'package:tractian_challenge_app/classes/asset.dart';
import 'package:tractian_challenge_app/classes/location.dart';

import 'base_item.dart';

class Item implements BaseItem {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? parentId;
  @override
  final String? locationId;
  @override
  final String sensorType;
  @override
  final String status;
  @override
  double position;
  @override
  List<Item> children;
  @override
  final ItemType type;

  Item({
    required this.id,
    required this.name,
    this.parentId,
    this.locationId,
    this.sensorType = '',
    this.status = '',
    this.position = 0,
    this.children = const [],
    required this.type,
  });

  factory Item.fromBaseItem(BaseItem baseItem) {
    return Item(
      id: baseItem.id,
      parentId: baseItem.parentId,
      locationId: baseItem.locationId,
      name: baseItem.name,
      sensorType: baseItem.sensorType,
      status: baseItem.status,
      position: baseItem.position,
      children: List<Item>.from(baseItem.children), // Ensure children is a modifiable list
      type: baseItem.type,
    );
  }
}
