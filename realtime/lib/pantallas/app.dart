import 'package:flutter/material.dart';
import 'package:realtime/pantallas/login_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.purple,
          primarySwatch: Colors.deepPurple,
          useMaterial3: true),
      home: LoginPage(),
    );
  }
}
