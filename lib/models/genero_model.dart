class GeneroModel {
  final int idGenero;
  final String nombreGenero;

  GeneroModel({required this.idGenero, required this.nombreGenero});

  factory GeneroModel.fromJson(Map<String, dynamic> json) {
    return GeneroModel(
      idGenero: json['id_genero'],
      nombreGenero: json['nombre_genero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id_genero': idGenero, 'nombre_genero': nombreGenero};
  }
}
