import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(appBar: _appBar(), drawer: _sideBar(), body: _body()),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context)
                    .openDrawer(); // Correctly accessing the Scaffold context
              },
            );
          },
        ),
        title: const Text("aaa"));
  }

  Widget _body() {
    return const SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Text("a"),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text("Aa"),
          )
        ],
      ),
    );
  }

  void _FindTexts() {}

  Widget _sideBar() {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.all(20.9),
      children: [
        for (var test in testString2)
          ListTile(
            title: Text(test[0]),
          )
      ],
    ));
  }
}

List testString = ["a", "a", "b", "c"];

List testString2 = [
  ["a", "aaaaaa"],
  ["b", "bbbbbb"]
];
