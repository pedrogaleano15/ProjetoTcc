import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/database/db_helper.dart';
import 'menu_manejo.dart';

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
      barrierDismissible: false, // Obriga o peão a clicar em um botão
      builder: (context) => AlertDialog(
        title: Text(
          "✅ Animal Encontrado",
          style: TextStyle(color: Colors.green[800]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Brinco: ${animal['identificacao']}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text("Raça: ${animal['raca']}"),
            Text("Sexo: ${animal['sexo']}"),
            Text("Peso Nasc.: ${animal['peso_nascimento']} kg"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o Pop-Up
              _cameraController.start(); // Liga a câmera de novo
              setState(() => _processando = false);
            },
            child: Text("Ler Outro", style: TextStyle(color: Colors.grey[700])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o Pop-up

              // Navega para a tela de Menu de Manejo passando os dados do animal
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuManejoScreen(animal: animal),
                ),
              ).then((_) {
                // Quando voltar do menu, liga a câmera de novo
                _cameraController.start();
                setState(() => _processando = false);
              });
            },
            child: Text("Registrar Manejo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
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
