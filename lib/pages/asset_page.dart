import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tractian_challenge_app/bloc/home_bloc.dart';
import 'package:tractian_challenge_app/classes/asset.dart';
import 'package:tractian_challenge_app/classes/location.dart';
import 'package:tractian_challenge_app/widgets/customized_expansion_tile.dart';

import '../classes/base_item.dart';
import '../classes/item.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../classes/item.dart';

class AssetPage extends StatefulWidget {
  final HomeBloc homeBloc;
  final String database;

  const AssetPage({Key? key, required this.homeBloc, required this.database}) : super(key: key);

  @override
  _AssetPageState createState() => _AssetPageState();
}

class _AssetPageState extends State<AssetPage> {
  // Map to hold the expansion state of each item
  Map<String, bool> expansionState = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.homeBloc.filterAlertBool = false;
    widget.homeBloc.filterEnergyBool = false;
    widget.homeBloc.filterAlert.sink.add(widget.homeBloc.filterAlertBool);
    widget.homeBloc.filterEnergy.sink.add(widget.homeBloc.filterEnergyBool);
    widget.homeBloc.textEditingController.clear();

  }

  @override
  void dispose() {

    widget.homeBloc.organize();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Assets"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
          splashRadius: 20,
        ),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: StreamBuilder<List<Item>>(
              stream: _getStreamForDatabase(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar os dados'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Nenhum item disponível'));
                } else {
                  // var filteredItems = widget.homeBloc.filterItems(snapshot.data!);
                  final itemTree = snapshot.data!;
                  return ListView.builder(
                    itemCount: itemTree.length,
                    itemBuilder: (context, index) => buildItemTile(itemTree[index]),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 104,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffEAEEF2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xffEAEFF3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: TextField(
                // onChanged: (a){widget.homeBloc.updateSearchQuery(widget.database);},
                textAlignVertical: TextAlignVertical.center,
                controller: widget.homeBloc.textEditingController,
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "Buscar Ativo ou Local",
                  hintStyle: const TextStyle(
                      color: Color(0xff8E98A3), fontWeight: FontWeight.w400),
                  prefixIcon: IconButton(onPressed: (){widget.homeBloc.updateSearchQuery(widget.database);},
                    icon: const Icon(
                    Icons.search,
                    color: Color(0xff8E98A3),
                    size: 20,
                  )),
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              children: [
                StreamBuilder<bool>(
                  stream: widget.homeBloc.filterEnergy.stream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          widget.homeBloc.toggleEnergyFilter(widget.database);
                        });
                      },
                      child: Container(
                        width: 166,
                        height: 32,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              CupertinoIcons.bolt,
                              size: 16,
                              color: snapshot.data! ? const Color(0xffFFFFFF) : const Color(0xff77818C),
                            ),
                            Text(
                              "Sensor de Energia",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: snapshot.data! ? const Color(0xffFFFFFF) : const Color(0xff77818C),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xffD8DFE6),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(3),
                          color: snapshot.data! ? const Color(0xff2188FF) : const Color(0xffFFFFFF)
                        ),
                      ),
                    );
                  }
                ),
                StreamBuilder<bool>(
                  stream: widget.homeBloc.filterAlert.stream,
                  initialData: false,
                  builder: (context, snapshot) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            widget.homeBloc.toggleAlertFilter(widget.database);
                          });
                        },
                        child: Container(
                          width: 94,
                          height: 32,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 18,
                                color: snapshot.data! ? const Color(0xffFFFFFF) : const Color(0xff77818C),
                              ),
                              Text(
                                "Crítico",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: snapshot.data! ? const Color(0xffFFFFFF) : const Color(0xff77818C),
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xffD8DFE6),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(3),
                              color: snapshot.data! ? const Color(0xff2188FF) : const Color(0xffFFFFFF)
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Stream<List<Item>> _getStreamForDatabase() {
    switch (widget.database) {
      case 'Jaguar Unit':
        return widget.homeBloc.jaguarItems.stream;
      case 'Tobias Unit':
        return widget.homeBloc.tobiasItems.stream;
      case 'Apex Unit':
      default:
        return widget.homeBloc.apexItems.stream;
    }
  }

  Widget buildItemTile(Item item) {
    if (item.children.isEmpty) {
      return Padding(
        padding: ((item.parentId == null || item.parentId!.isEmpty) && (item.locationId == null || item.locationId!.isEmpty)) ? EdgeInsets.only(left: item.position) : EdgeInsets.only(left: item.position + 25),
        child: ListTile(
          leading: item.type == ItemType.location
              ? const Icon(Icons.location_on_outlined, size: 30, color: Color(0xff2188FF))
              : item.sensorType.isNotEmpty ? SizedBox(width: 30, height: 30, child: Image.asset("images/small_box.png"))
              : (item.type == ItemType.asset && item.sensorType.isEmpty)
              ? SizedBox(width: 30, height: 30, child: Image.asset("images/big_box.png", fit: BoxFit.cover,)) : const SizedBox.shrink(),
          title: Text(item.name),
          trailing: SizedBox(
            height: 20,
            width: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              Align(alignment: Alignment.centerLeft, child: SizedBox(width: 20, height: 20, child: item.sensorType.isNotEmpty && item.sensorType == "energy" ? const Icon(Icons.bolt, color: Color(0xff52C41A),) : const SizedBox.shrink())),
              Align(alignment: Alignment.centerLeft, child: SizedBox(width: 20, height: 20, child: item.status.isNotEmpty && item.status == "alert" ? const Icon(Icons.circle, size: 15, color: Color(0xffED3833),) : const SizedBox.shrink())),
            ],),
          ),
        ),
      );
    } else {
      return StreamBuilder<bool>(
        stream: widget.homeBloc.isExpanded.stream,
        initialData: false,
        builder: (context, snapshot) {
          return Theme(
            data: ThemeData().copyWith(dividerColor: Colors.transparent),
            child: Padding(
              padding: EdgeInsets.only(left: item.position),
              child: CustomizedExpansionTile(
                key: PageStorageKey(item.id),
                controlAffinity: ListTileControlAffinity.leading,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: widget.homeBloc.filterEnergyBool == true || widget.homeBloc.filterAlertBool == true || widget.homeBloc.textEditingController.text.isNotEmpty,
                // initiallyExpanded: expansionState[item.id] ?? false,
                onExpansionChanged: (bool expanded) {
                  // setState(() {
                  // expansionState[item.id] = expanded;
                  // });
                },
                title: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  minLeadingWidth: 0,
                  leading: item.type == ItemType.location
                      ? const Icon(Icons.location_on_outlined, size: 30, color: Color(0xff2188FF))
                      : item.sensorType.isNotEmpty ? SizedBox(width: 30, height: 30, child: Image.asset("images/small_box.png"))
                      : (item.type == ItemType.asset && item.sensorType.isEmpty)
                      ? SizedBox(width: 30, height: 30, child: Image.asset("images/big_box.png")) : const SizedBox.shrink(),
                  title: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16, // Ajuste conforme necessário
                      color: Color(0xff17192D),
                    ),
                  ),
                  trailing: SizedBox(
                    height: 20,
                    width: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Align(alignment: Alignment.centerLeft, child: SizedBox(width: 20, height: 20, child: item.sensorType.isNotEmpty && item.sensorType == "energy" ? const Icon(Icons.bolt, color: Color(0xff52C41A),) : const SizedBox.shrink())),
                        Align(alignment: Alignment.centerLeft, child: SizedBox(width: 20, height: 20, child: item.status.isNotEmpty && item.status == "alert" ? const Icon(Icons.circle, size: 15, color: Color(0xffED3833),) : const SizedBox.shrink())),
                      ],),
                  ),
                ),
                children: item.children.map(buildItemTile).toList(),
                collapsedTextColor: const Color(0xff17192D),
                textColor: const Color(0xff17192D),
                iconColor: const Color(0xff17192D),
                collapsedIconColor: const Color(0xff17192D),
              ),
            )
          );
        }
      );
    }
  }
}
