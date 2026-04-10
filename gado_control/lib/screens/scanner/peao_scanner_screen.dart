import 'package:flutter/material.dart';
import 'package:gado_control/screens/animal/perfil_animal_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/database/db_helper.dart';

class PeaoScannerScreen extends StatefulWidget {
  @override
  _PeaoScannerScreenState createState() => _PeaoScannerScreenState();
}

class _PeaoScannerScreenState extends State<PeaoScannerScreen> {
  // Controlador para podermos pausar e voltar a câmera
  MobileScannerController _cameraController = MobileScannerController();
  bool _processando =
      false; // Evita que ele leia o mesmo QR Code repetidas vezes

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  // Função central: Pega o texto do QR Code e vai no SQLite
  void _buscarAnimalNoBanco(String idBrinco) async {
    if (_processando) return;
    setState(() => _processando = true);

    _cameraController.stop(); // Pausa a câmera imediatamente

    final db = await DatabaseHelper.instance.database;
    // Faz a busca (SELECT) onde a identificação for igual ao lido no QR Code
    final resultado = await db.query(
      'animais',
      where: 'identificacao = ?',
      whereArgs: [idBrinco],
    );

    if (resultado.isNotEmpty) {
      _mostrarPopUpSucesso(resultado.first);
    } else {
      _mostrarPopUpErro(idBrinco);
    }
  }

  void _mostrarPopUpSucesso(Map<String, dynamic> animal) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que o utilizador feche ao clicar fora
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700], size: 30),
              const SizedBox(width: 10),
              const Text(
                'Animal Encontrado!',
                style: TextStyle(color: Colors.black87, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Brinco: ${animal['identificacao'] ?? animal['brinco']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Raça: ${animal['raca'] ?? '-'} | Sexo: ${animal['sexo'] ?? '-'}',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            // BOTÃO 1: CANCELAR (Volta para a câmara)
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o pop-up

                // Nota: Descomente a linha abaixo se usar _cameraController
                // _cameraController.start();
                setState(() => _processando = false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),

            // BOTÃO 2: ABRIR FICHA E MANEJO (A Solução!)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Abrir Ficha Completa',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                // 1. Fecha o pop-up primeiro para não dar erro de contexto!
                Navigator.pop(context);

                // 2. Navega para o Perfil do Boi (onde está a gaveta de manejo)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilAnimalScreen(animal: animal),
                  ),
                ).then((_) {
                  // 3. Quando o utilizador clicar na seta de voltar no perfil, a câmara acorda

                  // Nota: Descomente a linha abaixo se usar _cameraController
                  // _cameraController.start();
                  setState(() => _processando = false);
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _mostrarPopUpErro(String idBrinco) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("❌ Não Encontrado", style: TextStyle(color: Colors.red)),
        content: Text(
          "O brinco '$idBrinco' não está cadastrado no banco de dados do sistema.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cameraController.start();
              setState(() => _processando = false);
            },
            child: Text("Tentar Novamente"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Leitura de Brinco (Peão)"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _buscarAnimalNoBanco(barcode.rawValue!);
                  break; // Pega só o primeiro código que aparecer na tela e para
                }
              }
            },
          ),
          // Desenha uma "Mira" na tela
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
