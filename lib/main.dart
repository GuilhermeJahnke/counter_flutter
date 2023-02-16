// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Flutter teste'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MethodChannel _channel = const MethodChannel('samples.flutter.dev/battery');

  @override
  void initState() {
    _getBatteryLevel();
    super.initState();
  }

  // Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await _channel.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<List> _getUsers() async {
    List users = [];
    try {
      var result = await _channel.invokeMethod('getUsers');

      final result2 = jsonDecode(result);

      users = result2.map((e) => User.fromMap(e)).toList();
    } on PlatformException catch (e) {
      print("Failed to get users: '${e.message}'.");
    }

    return users;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _getBatteryLevel(),
              child: const Text('Ola mundoaaaaaa'),
            ),
            Text(_batteryLevel),
            ElevatedButton(
              onPressed: () => _getUsers(),
              child: const Text('Get Users'),
            ),
            FutureBuilder<List>(
              future: _getUsers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].name),
                        subtitle: Text(snapshot.data![index].document),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final String name;
  final String document;
  final String age;

  const User({
    required this.name,
    required this.document,
    required this.age,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'document': document,
      'age': age,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] as String,
      document: map['document'] as String,
      age: map['age'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);
}
