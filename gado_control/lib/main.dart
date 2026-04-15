import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Barra de status transparente — visual mais moderno
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Bloqueia orientação em retrato — app é mobile-first
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load(fileName: '.env');

  runApp(const GadoControlApp());
}

class GadoControlApp extends StatelessWidget {
  const GadoControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GadoControl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light, // Único ponto de controle visual do app
      home: const LoginScreen(),
    );
  }
}
