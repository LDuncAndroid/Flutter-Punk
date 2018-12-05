import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Beer {
  final int id;
  final String name;

  Beer({this.id, this.name});

  factory Beer.fromJson(Map<String, dynamic> json) {
    return Beer(id: json['id'], name: json['name']);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Punk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Punk'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: BeerFuture(),
    );
  }
}

List<Beer> parseBeers(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Beer>((json) => Beer.fromJson(json)).toList();
}

class BeerFuture extends StatelessWidget {
  Future<List<Beer>> fetchBeers() async {
    final response = await http.get('https://api.punkapi.com/v2/beers');

    if (response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      return compute(parseBeers, response.body);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Beer>>(
        future: fetchBeers(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Text(snapshot.data.first.name);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }

          // By default, show a loading spinner
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
