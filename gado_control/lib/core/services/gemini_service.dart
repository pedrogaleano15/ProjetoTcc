import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  // AGORA ELE PUXA DA MEMÓRIA SEGURA EM VEZ DE FICAR EXPOSTO:
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<String> gerarRelatorio(String dadosDoGado) async {
    try {
      print("Acessando a API (Forçando v1)...");

      final model = GenerativeModel(
        model: 'gemini-2.5-flash', // <-- A MÁGICA ACONTECE AQUI
        apiKey: _apiKey,
        // Pode remover o requestOptions se quiser, a versão 2.5 já é nativa na rota nova
      );

      final prompt =
          'Atue como Zootecnista. Analise de forma resumida estes dados: $dadosDoGado';

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Sem resposta.";
    } catch (e) {
      return "Erro da API: $e";
    }
  }
}
