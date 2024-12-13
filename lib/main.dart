import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:foodilit/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: LoginPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodilit',
      theme: ThemeData.light(useMaterial3: true),
      home: LoginPage(),
    );
  }
}