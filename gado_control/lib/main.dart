import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Importa o leitor

void main() =>
    runApp(MaterialApp(home: HomePage(), debugShowCheckedModeBanner: false));

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Dados fictícios que seriam do seu banco de dados
  final List<Map<String, String>> rebanho = [
    {"id": "BOI001", "raca": "Nelore", "peso": "450kg", "status": "Vacinado"},
    {"id": "BOI002", "raca": "Angus", "peso": "380kg", "status": "Pendente"},
  ];

  // Função para abrir a câmera e ler o QR Code
  void _escanearQRCode() async {
    final String? codigoLido = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TelaScanner()),
    );

    if (codigoLido != null) {
      _mostrarFichaAnimal(codigoLido);
    }
  }

  void _mostrarFichaAnimal(String idLido) {
    // Busca o animal na lista pelo ID do QR Code
    final animal = rebanho.firstWhere(
      (a) => a['id'] == idLido,
      orElse: () => {
        "id": "Não encontrado",
        "raca": "-",
        "peso": "-",
        "status": "-",
      },
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Animal: ${animal['id']}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Raça: ${animal['raca']}"),
            Text("Peso: ${animal['peso']}"),
            Text("Saúde: ${animal['status']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GadoControl - Scanner")),
      body: Center(child: Text("Aponte para o QR Code do brinco")),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _escanearQRCode,
        label: Text("Ler Brinco"),
        icon: Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

// TELA DA CÂMERA
class TelaScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scanner de Brinco")),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue); // Retorna o ID lido
              break;
            }
          }
        },
      ),
    );
  }
}
