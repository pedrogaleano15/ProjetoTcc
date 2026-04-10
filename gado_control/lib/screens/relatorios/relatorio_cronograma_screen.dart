import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RelatorioCronogramaScreen extends StatelessWidget {
  // Agora o PDF recebe os dados dinâmicos da tela anterior!
  final List<List<String>> dadosConfigurados;

  const RelatorioCronogramaScreen({Key? key, required this.dadosConfigurados})
    : super(key: key);

  Future<Uint8List> _gerarCronogramaPdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape, // Folha deitada
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Cronograma Sanitário e Reprodutivo',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Calendário de atividades planeadas.',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 15),

            // Desenha a tabela com as escolhas que você fez na tela anterior
            pw.TableHelper.fromTextArray(
              headers: [
                'ATIVIDADE',
                'JUL',
                'AGO',
                'SET',
                'OUT',
                'NOV',
                'DEZ',
                'JAN',
                'FEV',
                'MAR',
                'ABR',
                'MAI',
                'JUN',
                'OBSERVAÇÕES',
              ],
              data: dadosConfigurados,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 8,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey800,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                13: pw.Alignment.centerLeft,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(3.5),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
                6: const pw.FlexColumnWidth(1),
                7: const pw.FlexColumnWidth(1),
                8: const pw.FlexColumnWidth(1),
                9: const pw.FlexColumnWidth(1),
                10: const pw.FlexColumnWidth(1),
                11: const pw.FlexColumnWidth(1),
                12: const pw.FlexColumnWidth(1),
                13: const pw.FlexColumnWidth(4.5),
              },
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cronograma Gerado'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _gerarCronogramaPdf(PdfPageFormat.a4),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: false,
        pdfFileName: 'meu_cronograma_personalizado.pdf',
      ),
    );
  }
}
