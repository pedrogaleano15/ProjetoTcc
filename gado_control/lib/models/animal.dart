/// Representa um animal do rebanho.
///
/// Imutável por design — para modificar, use [copyWith].
/// O campo [statusReproducao] é somente leitura (calculado via JOIN no banco).
class Animal {
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

  /// Campo calculado via JOIN no [listarAnimais] — não existe na tabela animais.
  final String? statusReproducao;

  // ─── Serialização ────────────────────────────────────────────────────────────

  /// Cria um [Animal] a partir de um [Map] retornado pelo SQLite.
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] as int?,
      identificacao: map['identificacao'] as String,
      sexo: map['sexo'] as String,
      raca: map['raca'] as String?,
      maeIdentificacao: map['mae_identificacao'] as String?,
      observacaoMae: map['observacao_mae'] as String?,
      dataNascimento: map['data_nascimento'] as String?,
      pesoNascimento: _toDouble(map['peso_nascimento']),
      pesoAtual: _toDouble(map['peso_atual']),
      lote: map['lote'] as String?,
      pasto: map['pasto'] as String?,
      carimbo: map['carimbo'] as String?,
      status: map['status'] as String? ?? 'Ativo',
      statusReproducao: map['status_reproducao'] as String?,
    );
  }

  /// Converte para [Map] compatível com inserção/atualização no SQLite.
  /// [statusReproducao] é omitido — é somente leitura (vem de JOIN).
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
    };
  }

  // ─── Imutabilidade ───────────────────────────────────────────────────────────

  /// Retorna uma cópia com os campos informados substituídos.
  ///
  /// Exemplo:
  /// ```dart
  /// final atualizado = animal.copyWith(pesoAtual: 320.5, pasto: 'Pasto B');
  /// ```
  Animal copyWith({
    int? id,
    String? identificacao,
    String? sexo,
    String? raca,
    String? maeIdentificacao,
    String? observacaoMae,
    String? dataNascimento,
    double? pesoNascimento,
    double? pesoAtual,
    String? lote,
    String? pasto,
    String? carimbo,
    String? status,
    String? statusReproducao,
  }) {
    return Animal(
      id: id ?? this.id,
      identificacao: identificacao ?? this.identificacao,
      sexo: sexo ?? this.sexo,
      raca: raca ?? this.raca,
      maeIdentificacao: maeIdentificacao ?? this.maeIdentificacao,
      observacaoMae: observacaoMae ?? this.observacaoMae,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      pesoNascimento: pesoNascimento ?? this.pesoNascimento,
      pesoAtual: pesoAtual ?? this.pesoAtual,
      lote: lote ?? this.lote,
      pasto: pasto ?? this.pasto,
      carimbo: carimbo ?? this.carimbo,
      status: status ?? this.status,
      statusReproducao: statusReproducao ?? this.statusReproducao,
    );
  }

  // ─── Identidade ──────────────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Animal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          identificacao == other.identificacao;

  @override
  int get hashCode => Object.hash(id, identificacao);

  @override
  String toString() =>
      'Animal(id: $id, identificacao: $identificacao, sexo: $sexo, '
      'status: $status, pasto: $pasto)';

  // ─── Helpers ─────────────────────────────────────────────────────────────────

  /// Retorna `true` se o animal está ativo no rebanho.
  bool get isAtivo => status == 'Ativo';

  /// Retorna `true` se o animal é fêmea.
  bool get isFemea => sexo == 'Fêmea';

  static double? _toDouble(dynamic value) =>
      value != null ? (value as num).toDouble() : null;
}
