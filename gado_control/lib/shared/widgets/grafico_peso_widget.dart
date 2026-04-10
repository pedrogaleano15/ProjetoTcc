import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraficoPesoWidget extends StatelessWidget {
  const GraficoPesoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Evolução de Peso (kg)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  // Configuração da barra inferior (Meses/Dias)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        Widget text;
                        switch (value.toInt()) {
                          case 1:
                            text = const Text('Jan', style: style);
                            break;
                          case 2:
                            text = const Text('Fev', style: style);
                            break;
                          case 3:
                            text = const Text('Mar', style: style);
                            break;
                          default:
                            text = const Text('', style: style);
                            break;
                        }
                        // AQUI ESTAVA O ERRO! Atualizado para a versão 1.1.1 do fl_chart
                        return SideTitleWidget(meta: meta, child: text);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 200), // Mês 1 (Jan), 200kg
                      FlSpot(2, 215), // Mês 2 (Fev), 215kg
                      FlSpot(3, 230), // Mês 3 (Mar), 230kg
                    ],
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.deepPurple.withOpacity(0.2),
                    ),
                  ),
                ],
                minY: 180, // Valor mínimo para o gráfico não achatar
              ),
            ),
          ),
        ],
      ),
    );
  }
}
