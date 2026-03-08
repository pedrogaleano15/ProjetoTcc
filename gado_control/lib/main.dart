import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // Garante que o Flutter está pronto para ler arquivos antes de rodar o app
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega o arquivo secreto com a sua chave
  await dotenv.load(fileName: ".env");

  // Inicia o app com a classe correta
  runApp(GadoControlApp());
}

class GadoControlApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadoControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: LoginScreen(), // O app começa no Login!
    );
  }
}
