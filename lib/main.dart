import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final FlutterActivityRecognition activityRecognition =
      FlutterActivityRecognition.instance;
  late final Future<bool> reqPermission;
  final List<Activity> activities = <Activity>[];

  @override
  void initState() {
    super.initState();
    reqPermission = getPermission();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> getPermission() async {
    PermissionRequestResult permission =
        await activityRecognition.checkPermission();
    if (permission == PermissionRequestResult.PERMANENTLY_DENIED) {
      return false;
    } else if (permission == PermissionRequestResult.DENIED) {
      permission = await activityRecognition.requestPermission();
      if (permission != PermissionRequestResult.GRANTED) {
        return false;
      }
    }
    FlutterActivityRecognition.instance.activityStream.listen((event) {
      setState(() {
        activities.add(event);
      });
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: reqPermission,
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.data == true) {
                return ListView(
                  children: activities
                      .map<Text>((e) => Text(
                            e.type.name + e.confidence.name,
                            textAlign: TextAlign.center,
                          ))
                      .toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
