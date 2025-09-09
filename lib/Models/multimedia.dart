class Multimedia{
  final int id;
  final String nombre;
  final String ubicacion;
  final String link;
  final String linkdetallado;

  // Constructor
  Multimedia({
    required this.id,
    required this.nombre,
    required this.ubicacion,
    required this.link,
    required this.linkdetallado,
  });

  // Método para convertir de JSON a un objeto de tipo Multimedia
  factory Multimedia.fromJson(Map<String, dynamic> json) {
    return Multimedia(
      id: json['id'],
      nombre: json['Nombre'],
      ubicacion: json['Ubicacion'],
      link: json['link'],
      linkdetallado: json['linkdetallado'],
    );
  }

  // Método para convertir de un objeto Multimedia a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Nombre': nombre,
      'Ubicacion': ubicacion,
      'link': link,
      'linkdetallado': linkdetallado,
    };
  }
}
