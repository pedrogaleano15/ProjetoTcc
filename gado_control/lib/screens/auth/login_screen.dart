import 'package:flutter/material.dart';
// Importações das telas de destino
import '../admin/admin_dashboard.dart';
import '../peao/peao_scanner_screen.dart';
import '../peao/menu_manejo.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Cor de fundo com tema agro
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 80,
                color: Colors.green[800],
              ), // Ícone provisório
              SizedBox(height: 16),
              Text(
                "GadoControl",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              Text(
                "Gestão Agropecuária Inteligente",
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 60),

              // Botão do Administrador
              ElevatedButton.icon(
                onPressed: () {
                  // Navegação real para o Dashboard
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AdminDashboard()),
                  );
                },
                icon: Icon(Icons.admin_panel_settings),
                label: Text("Entrar como Administrador"),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 16),

              // Botão do Peão (Operação de Campo)
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MenuManejoScreen(),
                    ), // <-- Agora ele vai para o Dashboard!
                  );
                },
                icon: Icon(Icons.qr_code_scanner),
                label: Text("Operação de Campo (Peão)"),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  foregroundColor: Colors.green[800],
                  side: BorderSide(color: Colors.green[800]!),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
