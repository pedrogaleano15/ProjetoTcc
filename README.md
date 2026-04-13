# GadoControl — Sistema Inteligente de Gestão de Rebanho Bovino

Aplicativo mobile/desktop desenvolvido como **Trabalho de Conclusão de Curso** em Engenharia da Computação (UCDB). O GadoControl digitaliza e automatiza o manejo de propriedades rurais, integrando banco de dados local, inteligência artificial e regras zootécnicas reais.

---

## Visão geral

Produtores rurais ainda dependem de planilhas e cadernos para controlar seu rebanho. O GadoControl resolve isso com um app multiplataforma que centraliza todo o histórico dos animais e usa IA para gerar análises e recomendações de manejo.

---

## Funcionalidades

### Gestão de animais
- Cadastro completo por brinco (identificação, raça, sexo, lote, pasto, peso)
- Suporte às raças Nelore, Angus e Cruzado
- Perfil individual de cada animal com histórico completo
- Scanner de brinco via câmera do celular

### Saúde e reprodução
- Registro de pesagens com cálculo automático de **GMD** (Ganho Médio Diário)
- Controle de vacinação com alerta de próxima dose
- Histórico de doenças e tratamentos
- Inseminação artificial com cálculo automático de **previsão de parto** (285 dias)
- Registro de desmame com cálculo do **Peso Ajustado aos 205 dias** (PA205 — padrão de seleção genética)

### Inteligência Artificial
- Integração com **Google Gemini AI** (gemini-2.5-flash)
- Relatórios gerados automaticamente com análise zootécnica do rebanho
- O modelo atua como zootecnista virtual, interpretando os dados e sugerindo ações

### Regras veterinárias automatizadas
- Lista automática de fêmeas aptas para inseminação (≥ 14 meses, não prenhes)
- Lista de animais candidatos a descarte (≥ 2 falhas reprodutivas)
- Lista de bezerros aptos para desmame (entre 3 e 12 meses, sem registro de desmame)

### Dashboards e relatórios
- Dashboard do Administrador com resumo do rebanho por sexo, lote e pasto
- Gráficos de evolução de peso por animal
- Cronograma de vacinação
- Histórico de movimentações de lote
- Geração e impressão de relatórios em **PDF**
- Reconhecimento de voz para entrada de dados

### Perfis de acesso
| Perfil | Acesso |
|---|---|
| Administrador | Dashboard completo, relatórios de IA, gestão do rebanho |
| Peão | Scanner de brinco, consulta e registro de ações de campo |

---

## Arquitetura

```
lib/
├── main.dart
├── core/
│   ├── database/
│   │   └── db_helper.dart        # SQLite — 8 tabelas, Singleton, migrações
│   └── services/
│       ├── gemini_service.dart   # Integração Google Gemini AI
│       └── calculos_service.dart # GMD, PA205, previsão de parto
├── screens/
│   ├── auth/                     # Login
│   ├── admin/                    # Dashboard admin + tela de IA
│   ├── dashboard/                # Dashboard peão + movimentações
│   ├── animal/                   # Cadastro, perfil, desmame, morte
│   ├── saude_reproducao/         # Pesagem, vacinação, inseminação, doença
│   ├── relatorios/               # Cronograma, vacinação, histórico
│   └── scanner/                  # Scanner de brinco (câmera)
└── shared/
    └── widgets/                  # Componentes reutilizáveis
```

### Banco de dados (SQLite local)

| Tabela | Descrição |
|---|---|
| `animais` | Cadastro principal do rebanho |
| `pesagens` | Histórico de peso com GMD calculado |
| `vacinas` | Registro de vacinação por animal |
| `historico_saude` | Doenças e tratamentos |
| `reproducao` | Inseminações com status e previsão de parto |
| `desmame` | Registro de desmame com PA205 |
| `baixas` | Mortes e descartes |
| `movimentacoes` | Transferências de lote e pasto |

---

## Tecnologias

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat&logo=sqlite&logoColor=white)
![Gemini](https://img.shields.io/badge/Google%20Gemini-4285F4?style=flat&logo=google&logoColor=white)

**Principais dependências:**

| Pacote | Uso |
|---|---|
| `sqflite` | Banco de dados SQLite local |
| `google_generative_ai` | Integração com Google Gemini AI |
| `mobile_scanner` | Scanner de brincos via câmera |
| `fl_chart` | Gráficos de peso e dashboard |
| `pdf` + `printing` | Geração e impressão de relatórios |
| `speech_to_text` | Entrada de dados por voz |
| `flutter_dotenv` | Gerenciamento seguro da chave de API |
| `flutter_markdown` | Renderização dos relatórios da IA |

**Plataformas suportadas:** Android · iOS · Web · Windows · Linux · macOS

---

## Como rodar

### Pré-requisitos
- Flutter SDK 3.x instalado
- Android Studio ou VS Code com extensão Flutter
- Chave de API do Google Gemini (gratuita em [aistudio.google.com](https://aistudio.google.com))

### Instalação

```bash
git clone https://github.com/pedrogaleano15/ProjetoTcc.git
cd ProjetoTcc/gado_control
flutter pub get
```

### Configurar a chave da IA

Crie um arquivo `.env` na raiz do projeto `gado_control/`:

```
GEMINI_API_KEY=sua_chave_aqui
```

### Executar

```bash
flutter run
```

---

## O que aprendi

- Desenvolvimento multiplataforma com Flutter e Dart
- Modelagem de banco de dados relacional com SQLite para uso offline
- Integração de LLMs (Large Language Models) em aplicações móveis via Gemini API
- Aplicação de regras de domínio real (zootecnia) em código
- Geração de PDF e reconhecimento de voz em Flutter
- Gerenciamento seguro de variáveis de ambiente em apps móveis

---

## Autors

**Pedro Henrique Morais Galeano**  
**Alexandre Raul**

Engenharia da Computação · UCDB · Campo Grande/MS  
TCC — 2026  
[GitHub](https://github.com/pedrogaleano15) · [LinkedIn](https://linkedin.com/in/pedro-henrique-morais-galeano)
