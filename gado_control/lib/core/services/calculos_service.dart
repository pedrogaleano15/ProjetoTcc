class CalculosService {
  // Recebe uma data e devolve o carimbo formatado (Ex: 12.1 ou 12.2)
  static String gerarCarimbo(DateTime data) {
    int mes = data.month;
    int quinzena = data.day <= 15 ? 1 : 2;
    return "$mes.$quinzena";
  }

  // lib/core/services/calculos_service.dart
  static double calcularGMD(
    double pesoAtual,
    double pesoAnterior,
    DateTime dataAtual,
    DateTime dataAnterior,
  ) {
    final dias = dataAtual.difference(dataAnterior).inDays;
    if (dias <= 0) return 0.0;
    return (pesoAtual - pesoAnterior) / dias;
  }

  // Calcula a previsão de parto (Média de 285 dias para bovinos)
  static DateTime calcularPrevisaoParto(DateTime dataInseminacao) {
    return dataInseminacao.add(const Duration(days: 285));
  }

  // Opcional, mas muito útil: Calcula a data do exame de toque (ex: 60 dias)
  static DateTime calcularDataDiagnostico(DateTime dataInseminacao) {
    return dataInseminacao.add(const Duration(days: 60));
  }

  // Calcula o Peso Ajustado aos 205 dias (Padrão para seleção genética)
  static double calcularPesoAjustado205(
    double pesoDesmame,
    double pesoNascimento,
    DateTime nascimento,
    DateTime desmame,
  ) {
    final idadeDias = desmame.difference(nascimento).inDays;
    if (idadeDias <= 0) return 0.0;

    // Fórmula: ((Peso Desmame - Peso Nascimento) / Idade) * 205 + Peso Nascimento
    return ((pesoDesmame - pesoNascimento) / idadeDias * 205) + pesoNascimento;
  }
}
