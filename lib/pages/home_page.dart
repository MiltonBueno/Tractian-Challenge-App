import 'package:flutter/material.dart';
import 'package:tractian_challenge_app/bloc/home_bloc.dart';
import 'package:tractian_challenge_app/pages/asset_page.dart';

import '../widgets/home_button.dart';

class HomePage extends StatefulWidget {
  final HomeBloc homeBloc;

  const HomePage({Key? key, required this.homeBloc}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.homeBloc.loadDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.homeBloc.isTablet(context) ? 300 : 112, vertical: 16),
          child: Image.asset("images/TRACTIAN_LOGO.png"),
        )),
      ),
      body: FutureBuilder<void>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os dados'));
          } else {
            return buildHomeContent();
          }
        },
      ),
    );
  }

  Widget buildHomeContent() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildHomeButton("Jaguar Unit"),
            buildHomeButton("Tobias Unit"),
            buildHomeButton("Apex Unit"),
          ],
        ),
      ),
    );
  }

  Widget buildHomeButton(String text) {
    return HomeButton(
      text: text,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AssetPage(
              homeBloc: widget.homeBloc,
              database: text,
            ),
          ),
        );
      },
      homeBloc: widget.homeBloc,
    );
  }
}
