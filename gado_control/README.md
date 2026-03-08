# 🐂 GadoControl - Sistema de Apoio à Decisão Zootécnica

O **GadoControl** é um aplicativo mobile desenvolvido como Trabalho de Conclusão de Curso (TCC) em Engenharia de Computação pela Universidade Católica Dom Bosco (UCDB). O foco principal é fornecer uma ferramenta de gestão e apoio à decisão para produtores rurais, unindo armazenamento offline e Inteligência Artificial.

## ✨ Funcionalidades

- **Gestão Offline:** Cadastro e acompanhamento de pesagens e eventos do rebanho funcionando 100% sem internet, utilizando banco de dados local.
- **Inteligência Artificial (Gemini):** Geração de relatórios zootécnicos automatizados baseados nos dados do rebanho, utilizando o modelo `gemini-2.5-flash` da Google.
- **Visualização de Dados:** Gráficos interativos para acompanhamento da evolução de peso dos animais ao longo do tempo.
- **Segurança Integrada:** Proteção de credenciais de API utilizando variáveis de ambiente.

## 🛠️ Tecnologias Utilizadas

- **Frontend/Mobile:** Flutter & Dart
- **Banco de Dados:** SQLite (Armazenamento Local)
- **Inteligência Artificial:** Google Generative AI (Gemini API)
- **Pacotes de Destaque:**
  - `fl_chart`: Renderização de gráficos de desempenho.
  - `flutter_markdown`: Formatação rica para os relatórios da IA.
  - `flutter_dotenv`: Gerenciamento seguro de variáveis de ambiente.

## 🚀 Como executar o projeto

1. **Clone o repositório:**
   ```bash
   git clone [https://github.com/SEU_USUARIO/gado_control.git](https://github.com/SEU_USUARIO/gado_control.git)
   Instale as dependências:
   ```

Bash
flutter pub get
Configure as Variáveis de Ambiente:
Crie um arquivo chamado .env na raiz do projeto e adicione sua chave da API do Google Gemini:

Snippet de código
GEMINI_API_KEY=SuaChaveAqui
Execute o aplicativo:

Bash
flutter run
