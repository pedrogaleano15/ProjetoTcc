import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../repositories/gado_repository.dart';
import '../animal/perfil_animal_screen.dart';

class PeaoScannerScreen extends StatefulWidget {
  const PeaoScannerScreen({Key? key}) : super(key: key);

  @override
  _PeaoScannerScreenState createState() => _PeaoScannerScreenState();
}

class _PeaoScannerScreenState extends State<PeaoScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _processando = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _buscarAnimalNoBanco(String idBrinco) async {
    if (_processando) return;
    setState(() => _processando = true);

    _cameraController.stop();

    // A MÁGICA DA NOVA ARQUITETURA AQUI:
    final animal = await GadoRepository.instance.obterAnimal(idBrinco);

    if (animal != null) {
      _mostrarPopUpSucesso(animal.toMap());
    } else {
      _mostrarPopUpErro(idBrinco);
    }
  }

  void _mostrarPopUpSucesso(Map<String, dynamic> animal) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() => _processando = false);
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PerfilAnimalScreen(animal: animal),
                  ),
                ).then((_) {
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
        title: const Text(
          "❌ Não Encontrado",
          style: TextStyle(color: Colors.red),
        ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Tentar Novamente"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leitura de Brinco (Peão)"),
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
                  break;
                }
              }
            },
          ),
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
