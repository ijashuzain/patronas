import 'package:flutter/material.dart';
import 'package:petronas/home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:petronas/login.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Login(),
    );
  }
}

requestPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
  } else if (status.isDenied) {
    requestPermission();
  }
}

