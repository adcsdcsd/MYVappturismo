// ignore_for_file: non_constant_identifier_names

import 'package:flutter/widgets.dart';
import 'package:correa_tours/Models/usuarios.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';  // Asegúrate de importar el modelo Usuario

// Función para convertir el JSON a una lista de usuarios
List<Usuario> usuarioFromJson(String str) {
  final jsonData = json.decode(str); // Decodifica el JSON (String) en un objeto Map
  return List<Usuario>.from(jsonData.map((x) => Usuario.fromJson(x))); // Mapea cada elemento del JSON a un objeto Usuario
}

// Función para convertir una lista de usuarios a JSON (si necesitas enviar datos)
String usuarioToJson(List<Usuario> data) {
  final dyn = List<dynamic>.from(data.map((x) => x.toJson())); // Convierte cada Usuario a JSON
  return json.encode(dyn); // Convierte la lista completa a JSON
}


class LoginProvider with ChangeNotifier {

  bool _isLoading = false;
  String _errorMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  set errorMessage(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String cedula, String password) async {
    
    isLoading = true;
    errorMessage = '';

    // URL de la API de login (ajusta según tu API)
    final url = Uri.parse("http://corporationservisgroup.somee.com/api/Usuarios/Login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "cedula": cedula,  // Enviar la cédula como parámetro
          "password": password,  // Enviar la contraseña
        }),
      );
      if (response.statusCode == 200) {           
        var decodedResponse = json.decode(response.body);
        var userId = decodedResponse['user']['id'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);   
        
        isLoading = false;
        return true;
      } else {
        // Si las credenciales no son correctas
        isLoading = false;
        errorMessage = 'Cédula o contraseña incorrectos.';
        return false;
      }
    } catch (error) {
      // Si hay un error en la conexión o en la solicitud
      isLoading = false;
      errorMessage = 'Hubo un problema al intentar conectarse al servidor.';
      return false;
    }
  }
}






class UsuariosProvider {
  // Método para obtener los datos del usuario usando el ID
 Future<String?> obtenerDatosUsuario() async {
  try {
    // Primero obtenemos el ID guardado en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? usuarioId = prefs.getInt('userId');// Recupera el ID del usuario

    if (usuarioId == null) {
      return null;  // Si no hay ID guardado, no podemos hacer la solicitud
    }

    // Creamos la URL para la API con el ID insertado
    final url = Uri.parse('http://corporationservisgroup.somee.com/api/Usuarios/$usuarioId'); // Aquí insertamos el ID

    // Realizamos la solicitud HTTP GET

    final response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // Verificamos la respuesta
    if (response.statusCode == 200) {
      // Si la solicitud es exitosa, procesamos la respuesta
       var decodedResponses = json.decode(response.body);
       var Nombre = (decodedResponses['nombre']);     
      return Nombre;
    } else {
      // Si la solicitud falla, mostramos un mensaje
      return null;
    }
  } catch (e) {
    // Manejo de errores
    return null;
  }
}
}