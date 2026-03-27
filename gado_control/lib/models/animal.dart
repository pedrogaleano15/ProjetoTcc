class Animal {
  final int? id;
  final String identificacao; // Ex: BOI001 (Lido pelo QR Code)
  final String sexo;
  final String raca;
  final String? maeIdentificacao;
  final String dataNascimento;
  final double pesoNascimento;

  Animal({
    this.id,
    required this.identificacao,
    required this.sexo,
    required this.raca,
    this.maeIdentificacao,
    required this.dataNascimento,
    required this.pesoNascimento,
  });

  // Transforma o Objeto Dart em um formato que o SQLite entende (Map)
  Map<String, dynamic> toMap() {
    return {
      'identificacao': identificacao,
      'sexo': sexo,
      'raca': raca,
      'mae_identificacao': maeIdentificacao,
      'data_nascimento': dataNascimento,
      'peso_nascimento': pesoNascimento,
    };
  }

  // Pega os dados do SQLite e transforma de volta em um Objeto Dart
  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'],
      identificacao: map['identificacao'],
      sexo: map['sexo'],
      raca: map['raca'],
      maeIdentificacao: map['mae_identificacao'],
      dataNascimento: map['data_nascimento'],
      pesoNascimento: map['peso_nascimento'],
    );
  }
}
