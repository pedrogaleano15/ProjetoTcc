import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Obrigatório para o SQLite funcionar corretamente depois
  runApp(GadoControlApp());
}

class GadoControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadoControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: LoginScreen(), // O app agora começa no Login!
    );
  }
}
