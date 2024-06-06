import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import '../classes/asset.dart';
import '../classes/item.dart';
import '../classes/location.dart';
import '../classes/base_item.dart';

class HomeBloc {

  bool isTablet(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    double deviceWidth = mediaQuery.size.shortestSide;
    return deviceWidth > 600;
  }

  ///Utilização de compute

  BehaviorSubject<bool> isExpanded = BehaviorSubject();

  final BehaviorSubject<List<Item>> apexItems = BehaviorSubject();
  final BehaviorSubject<List<Item>> jaguarItems = BehaviorSubject();
  final BehaviorSubject<List<Item>> tobiasItems = BehaviorSubject();

  late final List<BaseItem> apexItemsList;
  late final List<BaseItem> jaguarItemsList;
  late final List<BaseItem> tobiasItemsList;

  BehaviorSubject<bool> filterEnergy = BehaviorSubject();
  BehaviorSubject<bool> filterAlert = BehaviorSubject();
  BehaviorSubject<String> searchQuery = BehaviorSubject();

  bool filterEnergyBool = false;
  bool filterAlertBool = false;
  String searchQueryString = '';

  TextEditingController textEditingController = TextEditingController();

  Future<void> loadDatabase() async {
    try {
      apexItemsList = await _loadAndParse('database/apex_assets.json', 'database/apex_locations.json');
      jaguarItemsList = await _loadAndParse('database/jaguar_assets.json', 'database/jaguar_locations.json');
      tobiasItemsList = await _loadAndParse('database/tobias_assets.json', 'database/tobias_locations.json');

      organize();
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<List<BaseItem>> _loadAndParse(String assetPath, String locationPath) async {
    var assetJsonString = await rootBundle.loadString(assetPath);
    var locationJsonString = await rootBundle.loadString(locationPath);

    List<Asset> assetList = await compute(parseAssets, assetJsonString);
    List<Location> locationList = await compute(parseLocations, locationJsonString);

    return [...assetList, ...locationList];
  }

  static List<Asset> parseAssets(String jsonString) {
    final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
    return parsed.map<Asset>((json) => Asset.fromJson(json)).toList();
  }

  static List<Location> parseLocations(String jsonString) {
    final parsed = jsonDecode(jsonString).cast<Map<String, dynamic>>();
    return parsed.map<Location>((json) => Location.fromJson(json)).toList();
  }

  void organize() {
    try {
      organizeItems(apexItemsList, apexItems.sink);
      organizeItems(jaguarItemsList, jaguarItems.sink);
      organizeItems(tobiasItemsList, tobiasItems.sink);
    } catch (e) {
      print("Error organizing data: $e");
    }
  }

  void organizeItems(List<BaseItem> sourceList, StreamSink<List<Item>> sink) {
    final mainList = <Item>[];
    final allItemsMap = {for (var item in sourceList) item.id: Item.fromBaseItem(item)};
    final childrenMap = <String, List<Item>>{};

    for (var item in allItemsMap.values) {
      final parentId = item.parentId?.isNotEmpty == true ? item.parentId : item.locationId;
      if (parentId == null || parentId.isEmpty) {
        mainList.add(item);
      } else {
        childrenMap.putIfAbsent(parentId, () => []).add(item);
      }
    }

    for (var item in mainList) {
      organizeSubItems(item, childrenMap, 20);
    }

    for (var entry in childrenMap.entries) {
      if (!allItemsMap.containsKey(entry.key)) {
        mainList.addAll(entry.value);
      }
    }

    sink.add(mainList);
  }

  void organizeSubItems(Item parent, Map<String, List<Item>> childrenMap, double positionIncrement) {
    if (childrenMap.containsKey(parent.id)) {
      final children = childrenMap[parent.id]!;
      for (var child in children) {
        child.position = positionIncrement;
        parent.children.add(child);
        organizeSubItems(child, childrenMap, positionIncrement);
      }
    }
  }

  void toggleEnergyFilter(String database) {
    filterEnergyBool = !filterEnergyBool;
    filterEnergy.sink.add(filterEnergyBool);
    applyFiltersAndOrganize(database);
  }

  void toggleAlertFilter(String database) {
    filterAlertBool = !filterAlertBool;
    filterAlert.sink.add(filterAlertBool);
    applyFiltersAndOrganize(database);
  }

  void updateSearchQuery(String database) {
    searchQueryString = textEditingController.text;
    searchQuery.sink.add(searchQueryString);
    applyFiltersAndOrganize(database);
  }

  void applyFiltersAndOrganize(String database) {
    switch (database) {
      case 'Jaguar Unit':
        List<BaseItem> newList = filterItems(jaguarItemsList);
        organizeItems(newList, jaguarItems.sink);
        break;
      case 'Tobias Unit':
        List<BaseItem> newList = filterItems(tobiasItemsList);
        organizeItems(newList, tobiasItems.sink);
        break;
      case 'Apex Unit':
      default:
        List<BaseItem> newList = filterItems(apexItemsList);
        organizeItems(newList, apexItems.sink);
    }
  }

  List<Item> filterItems(List<BaseItem> items) {
    Set<String> idsToInclude = {};
    Map<String, String?> parentsMap = {for (var item in items) item.id: item.parentId != null && item.parentId!.isNotEmpty ? item.parentId : item.locationId};

    for (var item in items) {
      bool matches = item.name.toLowerCase().contains(searchQueryString.toLowerCase());
      if (filterEnergyBool) matches &= item.sensorType == 'energy';
      if (filterAlertBool) matches &= item.status == 'alert';

      if (matches) {
        String? currentId = item.id;
        while (currentId != null) {
          idsToInclude.add(currentId);
          currentId = parentsMap[currentId];
        }
      }
    }

    Set<String> allIncludedIds = Set<String>.from(idsToInclude);
    for (String id in allIncludedIds) {
      String? parentId = parentsMap[id];
      while (parentId != null && !idsToInclude.contains(parentId)) {
        idsToInclude.add(parentId);
        parentId = parentsMap[parentId];
      }
    }

    return items.where((item) => idsToInclude.contains(item.id)).map(Item.fromBaseItem).toList();
  }

  ///Sem utilização de compute, redução dos códigos, funções e variáveis

  // BehaviorSubject<bool> isExpanded = BehaviorSubject();
  //
  // final BehaviorSubject<List<Item>> apexItems = BehaviorSubject();
  // final BehaviorSubject<List<Item>> jaguarItems = BehaviorSubject();
  // final BehaviorSubject<List<Item>> tobiasItems = BehaviorSubject();
  //
  // late final List<BaseItem> apexItemsList;
  // late final List<BaseItem> jaguarItemsList;
  // late final List<BaseItem> tobiasItemsList;
  //
  // BehaviorSubject<bool> filterEnergy = BehaviorSubject();
  // BehaviorSubject<bool> filterAlert = BehaviorSubject();
  // BehaviorSubject<String> searchQuery = BehaviorSubject();
  //
  // bool filterEnergyBool = false;
  // bool filterAlertBool = false;
  // String searchQueryString = '';
  //
  // TextEditingController textEditingController = TextEditingController();
  //
  // Future<void> loadDatabase() async {
  //   try {
  //     final apexAssetsList = await _loadAndParse<Asset>("database/apex_assets.json", Asset.fromJson);
  //     final jaguarAssetsList = await _loadAndParse<Asset>("database/jaguar_assets.json", Asset.fromJson);
  //     final tobiasAssetsList = await _loadAndParse<Asset>("database/tobias_assets.json", Asset.fromJson);
  //
  //     final apexLocationsList = await _loadAndParse<Location>("database/apex_locations.json", Location.fromJson);
  //     final jaguarLocationsList = await _loadAndParse<Location>("database/jaguar_locations.json", Location.fromJson);
  //     final tobiasLocationsList = await _loadAndParse<Location>("database/tobias_locations.json", Location.fromJson);
  //
  //     apexItemsList = [...apexAssetsList, ...apexLocationsList];
  //     jaguarItemsList = [...jaguarAssetsList, ...jaguarLocationsList];
  //     tobiasItemsList = [...tobiasAssetsList, ...tobiasLocationsList];
  //
  //     organize();
  //   } catch (e) {
  //     print("Error loading data: $e");
  //   }
  // }
  //
  // Future<List<T>> _loadAndParse<T extends BaseItem>(
  //     String path,
  //     T Function(Map<String, dynamic>) fromJson,
  //     ) async {
  //   final jsonString = await rootBundle.loadString(path);
  //   final List<dynamic> parsed = jsonDecode(jsonString);
  //   return parsed.map<T>((json) => fromJson(json as Map<String, dynamic>)).toList();
  // }
  //
  // void organize() {
  //   try {
  //     organizeItems(apexItemsList, apexItems.sink);
  //     organizeItems(jaguarItemsList, jaguarItems.sink);
  //     organizeItems(tobiasItemsList, tobiasItems.sink);
  //   } catch (e) {
  //     print("Error organizing data: $e");
  //   }
  // }
  //
  // void organizeItems(List<BaseItem> sourceList, StreamSink<List<Item>> sink) {
  //   try {
  //
  //     final mainList = <Item>[];
  //     final allItemsMap = {for (var item in sourceList) item.id: Item.fromBaseItem(item)};
  //     final childrenMap = <String, List<Item>>{};
  //
  //     for (var item in allItemsMap.values) {
  //       final parentId = item.parentId?.isNotEmpty == true ? item.parentId : item.locationId;
  //       if (parentId == null || parentId.isEmpty) {
  //         mainList.add(item);
  //       } else {
  //         childrenMap.putIfAbsent(parentId, () => []).add(item);
  //       }
  //     }
  //
  //     for (var item in mainList) {
  //       organizeSubItems(item, childrenMap, 20);
  //     }
  //
  //     for (var entry in childrenMap.entries) {
  //       if (!allItemsMap.containsKey(entry.key)) {
  //         mainList.addAll(entry.value);
  //       }
  //     }
  //
  //     sink.add(mainList);
  //   } catch (e) {
  //     print("Error in organizeItems: $e");
  //   }
  // }
  //
  // void organizeSubItems(Item parent, Map<String, List<Item>> childrenMap, double positionIncrement) {
  //   if (childrenMap.containsKey(parent.id)) {
  //     final children = childrenMap[parent.id]!;
  //     for (var child in children) {
  //       child.position = positionIncrement;
  //       parent.children.add(child);
  //       organizeSubItems(child, childrenMap, positionIncrement);
  //     }
  //   }
  // }
  //
  // void toggleEnergyFilter(database) {
  //   filterEnergyBool = !filterEnergyBool;
  //   filterEnergy.sink.add(filterEnergyBool);
  //   applyFiltersAndOrganize(database);
  // }
  //
  // void toggleAlertFilter(database) {
  //   filterAlertBool = !filterAlertBool;
  //   filterAlert.sink.add(filterAlertBool);
  //   applyFiltersAndOrganize(database);
  // }
  //
  // void updateSearchQuery(database) {
  //   searchQueryString = textEditingController.text;
  //   searchQuery.sink.add(searchQueryString);
  //   applyFiltersAndOrganize(database);
  // }
  //
  // applyFiltersAndOrganize(database){
  //   switch (database) {
  //     case 'Jaguar Unit':
  //       List<BaseItem> newList = filterItems(jaguarItemsList);
  //       organizeItems(newList, jaguarItems.sink);
  //       break;
  //     case 'Tobias Unit':
  //       List<BaseItem> newList = filterItems(tobiasItemsList);
  //       organizeItems(newList, tobiasItems.sink);
  //       break;
  //     case 'Apex Unit':
  //     default:
  //       List<BaseItem> newList = filterItems(apexItemsList);
  //       organizeItems(newList, apexItems.sink);
  //   }
  // }
  //
  // List<Item> filterItems(List<BaseItem> items) {
  //
  //   Set<String> idsToInclude = {};
  //   Map<String, String?> parentsMap = {for (var item in items) item.id: item.parentId != null && item.parentId!.isNotEmpty ? item.parentId : item.locationId};
  //
  //   print(parentsMap.toString());
  //
  //   for (var item in items) {
  //     bool matches = item.name.toLowerCase().contains(searchQueryString.toLowerCase());
  //     if (filterEnergyBool) matches &= item.sensorType == 'energy';
  //     if (filterAlertBool) matches &= item.status == 'alert';
  //
  //     if (matches) {
  //       String? currentId = item.id;
  //       // Incluir o item e subir pela cadeia de pais para garantir que todos sejam incluídos
  //       while (currentId != null) {
  //         idsToInclude.add(currentId);
  //         currentId = parentsMap[currentId];
  //       }
  //     }
  //   }
  //
  //   // Garantir que todos os pais dos itens incluídos sejam também incluídos na lista final
  //   Set<String> allIncludedIds = Set<String>.from(idsToInclude);
  //   for (String id in allIncludedIds) {
  //     String? parentId = parentsMap[id];
  //     while (parentId != null && !idsToInclude.contains(parentId)) {
  //       idsToInclude.add(parentId);
  //       parentId = parentsMap[parentId];
  //     }
  //   }
  //
  //   List<Item> finalList = items.where((item) => idsToInclude.contains(item.id))
  //       .map(Item.fromBaseItem).toList();
  //
  //   return finalList;
  // }

}
