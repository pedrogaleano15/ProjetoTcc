class Animal {
  final int? id;
  final String identificacao;
  final String sexo;
  final String? raca;
  final String? maeIdentificacao;
  final String? observacaoMae;
  final String? dataNascimento;
  final double? pesoNascimento;
  final double? pesoAtual;
  final String? lote;
  final String? pasto;
  final String? carimbo;
  final String status;
  // Campo calculado via JOIN no listarAnimais() — não existe na tabela animais
  final String? statusReproducao;

  const Animal({
    this.id,
    required this.identificacao,
    required this.sexo,
    this.raca,
    this.maeIdentificacao,
    this.observacaoMae,
    this.dataNascimento,
    this.pesoNascimento,
    this.pesoAtual,
    this.lote,
    this.pasto,
    this.carimbo,
    this.status = 'Ativo',
    this.statusReproducao,
  });

  // Converte o Map do SQLite em um objeto Animal com tipos garantidos pelo compilador
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] as int?,
      identificacao: map['identificacao'] as String,
      sexo: map['sexo'] as String,
      raca: map['raca'] as String?,
      maeIdentificacao: map['mae_identificacao'] as String?,
      observacaoMae: map['observacao_mae'] as String?,
      dataNascimento: map['data_nascimento'] as String?,
      pesoNascimento: map['peso_nascimento'] != null
          ? (map['peso_nascimento'] as num).toDouble()
          : null,
      pesoAtual: map['peso_atual'] != null
          ? (map['peso_atual'] as num).toDouble()
          : null,
      lote: map['lote'] as String?,
      pasto: map['pasto'] as String?,
      carimbo: map['carimbo'] as String?,
      status: map['status'] as String? ?? 'Ativo',
      statusReproducao: map['status_reproducao'] as String?,
    );
  }

  // Converte o objeto Animal de volta para o formato Map que o SQLite aceita
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'identificacao': identificacao,
      'sexo': sexo,
      'raca': raca,
      'mae_identificacao': maeIdentificacao,
      'observacao_mae': observacaoMae,
      'data_nascimento': dataNascimento,
      'peso_nascimento': pesoNascimento,
      'peso_atual': pesoAtual,
      'lote': lote,
      'pasto': pasto,
      'carimbo': carimbo,
      'status': status,
      // statusReproducao NÃO vai aqui — é somente leitura (vem de JOIN)
    };
  }
}
