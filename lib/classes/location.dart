import 'package:tractian_challenge_app/classes/item.dart';

import 'base_item.dart';

class Location implements BaseItem {
  @override
  String id;
  @override
  String name;
  @override
  String locationId;
  @override
  String? get parentId => locationId;
  @override
  double position;
  @override
  List<Item> children = [];
  @override
  String get sensorType => '';
  @override
  String get status => '';
  @override
  ItemType get type => ItemType.location;

  Location({
    required this.id,
    required this.name,
    this.locationId = "",
    this.position = 0,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? "",
      id: json['id'] ?? "",
      locationId: json['parentId'] ?? "",
    );
  }
}