import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Enum que define os tipos de análise disponíveis para o gestor.
enum TipoRelatorio { geral, reproducao, sanidade, peso, descarte }

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  /// Gera um relatório zootécnico completo com base nos dados do rebanho e no tipo solicitado.
  static Future<String> gerarRelatorio(
    String dadosDoGado, {
    TipoRelatorio tipo = TipoRelatorio.geral,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature:
              0.4, // Mais preciso e menos criativo — adequado para laudos técnicos
          maxOutputTokens: 2048,
        ),
      );

      final prompt = _montarPrompt(dadosDoGado, tipo);
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sem resposta da IA.';
    } catch (e) {
      return '## ⚠️ Erro ao gerar análise\n\nNão foi possível conectar à IA. Verifique sua conexão e tente novamente.\n\n**Detalhe técnico:** $e';
    }
  }

  static String _montarPrompt(String dados, TipoRelatorio tipo) {
    const persona = '''
Você é um Zootecnista Sênior com 20 anos de experiência em bovinocultura de corte e leite no Brasil.
Você analisa dados de fazendas e emite laudos técnicos objetivos, práticos e acionáveis para gestores rurais.
Escreva de forma clara, use linguagem técnica mas acessível, e sempre termine com recomendações concretas.
Formate a resposta em Markdown com títulos (##), listas e **destaques em negrito** nos pontos críticos.
''';

    switch (tipo) {
      case TipoRelatorio.geral:
        return '''
$persona

## DADOS DO REBANHO
$dados

## TAREFA
Elabore um **Relatório Geral do Rebanho** com as seguintes seções obrigatórias:

1. **📊 Resumo Executivo** — síntese dos principais indicadores em 3 a 5 frases.
2. **🐄 Composição do Rebanho** — análise da distribuição por sexo, categoria e lotação por pasto.
3. **🔬 Situação Reprodutiva** — eficiência reprodutiva, taxa de prenhez estimada e gargalos.
4. **⚖️ Desempenho Ponderal** — análise dos pesos e GMD (Ganho Médio Diário) se disponível.
5. **🚨 Alertas Críticos** — animais ou situações que exigem ação imediata.
6. **✅ Plano de Ação (próximos 30 dias)** — liste de 3 a 5 ações prioritárias e concretas.
''';

      case TipoRelatorio.reproducao:
        return '''
$persona

## DADOS DO REBANHO
$dados

## TAREFA
Elabore um **Laudo Reprodutivo Detalhado** com as seguintes seções:

1. **📋 Panorama Reprodutivo** — status atual das fêmeas (prenhes, vazias, aguardando diagnóstico, abortos).
2. **🎯 Eficiência de Inseminação** — taxa de sucesso estimada e comparação com média ideal (60–70%).
3. **📅 Previsão de Partos** — estime o volume de partos esperados com base nas inseminações.
4. **⚠️ Vacas Problema** — identifique perfil de animais com falhas repetidas e recomende ação.
5. **🔄 Lote de Repasse** — animais aptas para nova inseminação e critérios de seleção.
6. **✅ Recomendações Reprodutivas** — protocolo sugerido para os próximos 60 dias.
''';

      case TipoRelatorio.sanidade:
        return '''
$persona

## DADOS DO REBANHO
$dados

## TAREFA
Elabore um **Relatório Sanitário do Rebanho** com as seguintes seções:

1. **🏥 Situação Sanitária Atual** — resumo dos registros de doenças e tratamentos ativos.
2. **💉 Cobertura Vacinal** — análise do calendário de vacinação e lacunas identificadas.
3. **🦠 Doenças Prevalentes** — análise dos diagnósticos mais frequentes no período.
4. **📉 Impacto Econômico** — estimativa de perda de peso e reprodução por causas sanitárias.
5. **🚨 Alertas** — animais em tratamento ativo ou com histórico crítico.
6. **✅ Calendário Sanitário Recomendado** — vacinações e vermifugações prioritárias.
''';

      case TipoRelatorio.peso:
        return '''
$persona

## DADOS DO REBANHO
$dados

## TAREFA
Elabore um **Relatório de Desempenho Ponderal** com as seguintes seções:

1. **⚖️ Distribuição de Pesos** — análise do perfil de pesos por categoria (bezerros, garrotes, vacas, touros).
2. **📈 GMD (Ganho Médio Diário)** — calcule ou estime o GMD por categoria e compare com referências (Nelore: 0,8–1,0 kg/dia em confinamento; 0,4–0,6 kg/dia a pasto).
3. **🏆 Destaque e Alerta** — animais com melhor e pior desempenho ponderal.
4. **🥩 Potencial de Abate** — animais que atendem critérios de peso para abate (>450 kg machos / >380 kg fêmeas descarte).
5. **🌾 Relação Peso × Pasto** — analise se a lotação está impactando o ganho de peso.
6. **✅ Estratégia Nutricional Recomendada** — ajustes de suplementação ou manejo de pastagem.
''';

      case TipoRelatorio.descarte:
        return '''
$persona

## DADOS DO REBANHO
$dados

## TAREFA
Elabore um **Relatório de Seleção e Descarte** com as seguintes seções:

1. **📋 Critérios de Descarte Aplicados** — explique os critérios zootécnicos usados (idade, falhas reprodutivas, saúde, peso).
2. **🔴 Lista de Descarte Prioritário** — animais com maior indicação de saída (vacas com 2+ falhas, animais doentes crônicos, etc.).
3. **🟡 Zona de Atenção** — animais que merecem uma última chance com protocolo específico.
4. **🟢 Fêmeas de Reposição** — novilhas aptas para entrar no lote reprodutivo.
5. **💰 Análise Econômica** — impacto financeiro estimado do descarte e renovação.
6. **✅ Plano de Descarte** — cronograma e ordem sugerida para venda ou abate.
''';
    }
  }
}
