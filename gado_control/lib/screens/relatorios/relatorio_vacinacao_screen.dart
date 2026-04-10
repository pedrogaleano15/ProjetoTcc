import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/database/db_helper.dart';

class RelatorioVacinacaoScreen extends StatelessWidget {
  final String
  observacoesGerais; // Variável para receber o texto que você digitou

  const RelatorioVacinacaoScreen({Key? key, this.observacoesGerais = ''})
    : super(key: key);

  Future<Uint8List> _gerarRelatorioPdf(PdfPageFormat format) async {
    final pdf = pw.Document();
    final animais = await DatabaseHelper.instance.listarAnimais();
    List<List<String>> dadosTabela = [];

    for (var animal in animais) {
      final vacinas = await DatabaseHelper.instance.listarVacinasPorAnimal(
        animal['identificacao'].toString(),
      );
      final vStr = vacinas
          .map(
            (v) =>
                (v['nomeVacina'] ?? v['nome_vacina']).toString().toLowerCase(),
          )
          .toList();

      bool temAftosa = vStr.any((v) => v.contains('aftosa'));
      bool temBrucelose = vStr.any((v) => v.contains('brucelose'));
      bool temCarbunculo = vStr.any(
        (v) => v.contains('carbúnculo') || v.contains('carbunculo'),
      );
      bool temBotulismo = vStr.any((v) => v.contains('botulismo'));
      bool temParatifo = vStr.any((v) => v.contains('paratifo'));

      String statusBrucelose = animal['sexo'] == 'Macho'
          ? '--'
          : (temBrucelose ? 'OK' : 'Pend.');

      String obs = '';
      if (animal['sexo'] == 'Fêmea' && !temBrucelose) {
        obs = 'Fêmeas 3-8m. Marcar "V" esq. rosto';
      } else if (!temCarbunculo) {
        obs = '1ª dose 4-6m. 2ª dose após 6m';
      } else if (!temBotulismo) {
        obs = '1ª dose 4º mês + ref. 40 dias';
      } else if (!temParatifo) {
        obs = '15-20 dias ou Vacas prenha 8º mês';
      } else if (!temAftosa) {
        obs = 'A partir do 4º mês';
      } else {
        obs = 'Sanidade em dia';
      }

      dadosTabela.add([
        animal['identificacao'] ?? animal['brinco'] ?? '-',
        animal['sexo'] != null ? animal['sexo'][0] : '-',
        temAftosa ? 'OK' : 'Pend.',
        statusBrucelose,
        temCarbunculo ? 'OK' : 'Pend.',
        temBotulismo ? 'OK' : 'Pend.',
        temParatifo ? 'OK' : 'Pend.',
        obs,
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Relatório Sanitário e Reprodutivo',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Emitido em: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // CAIXA DE OBSERVAÇÕES (Aparece se você digitou algo)
            if (observacoesGerais.isNotEmpty)
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.yellow50, // Fundo amarelinho de atenção
                  border: pw.Border.all(color: PdfColors.orange),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Observações do Responsável:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      observacoesGerais,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),

            // TABELA
            pw.TableHelper.fromTextArray(
              headers: [
                'Brinco',
                'Sex',
                'Aftosa',
                'Brucel.',
                'Carbún.',
                'Botul.',
                'Paratifo',
                'Regras de Manejo Faltantes',
              ],
              data: dadosTabela,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.green800,
              ),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(color: PdfColors.grey300),
                ),
              ),
              cellAlignment: pw.Alignment.center,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                7: pw.Alignment.centerLeft,
              },
              columnWidths: {7: const pw.FlexColumnWidth(3)},
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
        title: const Text('Relatório Completo'),
        backgroundColor: Colors.green[800],
      ),
      body: PdfPreview(
        build: (format) => _gerarRelatorioPdf(PdfPageFormat.a4),
        allowPrinting: true,
        allowSharing: true,
        canChangeOrientation: true,
        pdfFileName: 'relatorio_gado.pdf',
      ),
    );
  }
}
