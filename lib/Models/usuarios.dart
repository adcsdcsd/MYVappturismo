class Usuario {
  final String id;       // Campo id agregado
  final String email;
  final String password;

  // Constructor
  Usuario({
    required this.id,    // Necesitamos el id también al crear un objeto
    required this.email,
    required this.password,
  });

  // Factory constructor para crear un objeto Usuario desde un mapa de JSON
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],        // Asignamos el id del JSON
      email: json['email'],  // Asignamos el valor de 'email'
      password: json['password'],  // Asignamos el valor de 'password'
    );
  }

  // Método para convertir un objeto Usuario en un mapa de JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,              // Convertimos el id en el JSON
      'email': email,
      'password': password,
    };
  }
}
