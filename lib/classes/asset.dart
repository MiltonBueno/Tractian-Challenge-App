import 'package:tractian_challenge_app/classes/item.dart';

import 'base_item.dart';

class Asset implements BaseItem {
  @override
  String id;
  @override
  String name;
  @override
  String parentId;
  @override
  String locationId;
  @override
  double position;
  @override
  List<Item> children = [];
  String sensorType;
  String status;
  @override
  ItemType get type => ItemType.asset;

  Asset({
    required this.id,
    required this.name,
    this.parentId = "",
    this.sensorType = "",
    this.status = "",
    this.locationId = "",
    this.position = 0,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      name: json['name'] ?? "",
      id: json['id'] ?? "",
      parentId: json['parentId'] ?? "",
      sensorType: json['sensorType'] ?? "",
      status: json['status'] ?? "",
      locationId: json['locationId'] ?? "",
    );
  }
}