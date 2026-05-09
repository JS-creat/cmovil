class BannerModel {
  final int id;
  final String? titulo;
  final String? subtitulo;
  final String? descripcion;
  final String? etiqueta;
  final String? textoBoton;
  final String? urlBoton;
  final String imagen;
  final int orden;

  BannerModel({
    required this.id,
    this.titulo,
    this.subtitulo,
    this.descripcion,
    this.etiqueta,
    this.textoBoton,
    this.urlBoton,
    required this.imagen,
    required this.orden,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      titulo: json['titulo'],
      subtitulo: json['subtitulo'],
      descripcion: json['descripcion'],
      etiqueta: json['etiqueta'],
      textoBoton: json['texto_boton'],
      urlBoton: json['url_boton'],
      imagen: json['imagen'] ?? '',
      orden: json['orden'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'subtitulo': subtitulo,
      'descripcion': descripcion,
      'etiqueta': etiqueta,
      'texto_boton': textoBoton,
      'url_boton': urlBoton,
      'imagen': imagen,
      'orden': orden,
    };
  }
}
