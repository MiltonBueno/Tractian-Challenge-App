import 'package:flutter/material.dart';
import 'package:tractian_challenge_app/bloc/home_bloc.dart';
import 'package:tractian_challenge_app/pages/asset_page.dart';
import 'package:tractian_challenge_app/pages/home_page.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  HomeBloc homeBloc = HomeBloc();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Color(0xff17192D),
          foregroundColor: Color(0xffFFFFFF),
          toolbarHeight: 48,
        ),
      ),
      home: HomePage(homeBloc: homeBloc),
    ),
  );
}