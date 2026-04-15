import 'package:flutter/material.dart';
import 'package:gado_control/screens/dashboard/dashboard_peao_screen.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatelessWidget {
  // Construtor const permite que o Flutter reutilize o widget sem rebuild desnecessário
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const: o ícone não muda nunca, então o Flutter não precisa redesenhá-lo
              Icon(Icons.pets, size: 80, color: Colors.green[800]),
              const SizedBox(height: 16),
              Text(
                'GadoControl',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[900],
                ),
              ),
              Text(
                'Gestão Agropecuária Inteligente',
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 60),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminDashboardScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Entrar como Administrador'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.green[800],
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardPeaoScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Operação de Campo (Peão)'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
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
