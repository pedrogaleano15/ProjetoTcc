import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // Chave carregada do arquivo .env — nunca exposta no código-fonte
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<String> gerarRelatorio(String dadosDoGado) async {
    try {
      final model = GenerativeModel(
        // gemini-2.5-flash: contexto longo (1M tokens) — ideal para rebanhos grandes
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final prompt =
          'Atue como Zootecnista. Analise de forma resumida estes dados: $dadosDoGado';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Sem resposta.';
    } catch (e) {
      return 'Erro da API: $e';
    }
  }
}
