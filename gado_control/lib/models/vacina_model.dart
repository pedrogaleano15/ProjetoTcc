class Vacina {
  int? id;
  int animalId;
  String nomeVacina;
  String dataAplicacao;
  String proximaDose;

  Vacina({
    this.id,
    required this.animalId,
    required this.nomeVacina,
    required this.dataAplicacao,
    required this.proximaDose,
  });

  // Converte a Vacina para um Map (para guardar no SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'nome_vacina': nomeVacina,
      'data_aplicacao': dataAplicacao,
      'proxima_dose': proximaDose,
    };
  }

  // Cria uma Vacina a partir de um Map (quando lemos do SQLite)
  factory Vacina.fromMap(Map<String, dynamic> map) {
    return Vacina(
      id: map['id'],
      animalId: map['animal_id'],
      nomeVacina: map['nome_vacina'],
      dataAplicacao: map['data_aplicacao'],
      proximaDose: map['proxima_dose'],
    );
  }
}
