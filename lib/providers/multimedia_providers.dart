import 'dart:convert';
import 'package:http/http.dart' as http;

class MultimediaProvider {
  ////////////////////////////////////// Función para obtener las imágenes del carrusel///////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////
  


Future<String> obtenerImagenLogin() async {
    final url = Uri.parse('http://corporationservisgroup.somee.com/api/multimedias/1');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Aquí asumimos que el API devuelve una URL en el campo 'urlImagen'
        return data['link']; // Asegúrate de que este campo sea correcto
      } else {
        throw Exception('Error al cargar la imagen');
      }
    } catch (e) {
      throw Exception('Error al cargar la imagen');
    }
  }




  
  Future<List<Map<String, String>>> obtenerCarrusel() async {
    final url = Uri.parse('http://corporationservisgroup.somee.com/api/Multimedias/carrusel');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data
            .map<Map<String, String>>((item) {
              // Extraer el ID y el link
              String id = item['id'].toString(); // Asegúrate de convertirlo a String
              String link = item['link'] ?? '';  // Si 'link' es null, asigna una cadena vacía
              
              // Retornar un mapa con el id y el link
              return {'id': id, 'link': link};
            })
            .where((item) => item['link']!.isNotEmpty) // Filtrar los elementos donde el link no esté vacío
            .toList();

      } else {
        throw Exception('Error al cargar las imágenes');
      }
    } catch (e) {
      return [];
    }
  }



////////////////////////////////////////////////////////////////////////obtenerMediaItems///////////////////////////
 Future<List<String>> obtenerMediaItems() async {
  final url = Uri.parse('http://corporationservisgroup.somee.com/api/Multimedias/home');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<String>((item) => item['link'] ?? '')  // Extraer los links.
          .where((link) => link.isNotEmpty)  // Filtrar links vacíos.
          .toList();
    } else {
      throw Exception('Error al cargar los elementos de multimedia');
    }
  } catch (e) {
    return [];
  }
}

Future<List<Map<String, String>>> obtenerMediaItemsTurismo() async {
  final url = Uri.parse('http://corporationservisgroup.somee.com/api/Multimedias/turismo');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((item) {
        return {
          'link': item['link'] ?? '',
          'linkdetallado': item['linkdetallado'] ?? '',
        };
      }).where((item) => item['link']!.isNotEmpty && item['linkdetallado']!.isNotEmpty).toList();
    } else {
      throw Exception('Error al cargar los elementos de multimedia');
    }
  } catch (e) {
    return [];
  }
}

////////////////////////////////////obtenerMediaItemsciudades//////////////////////////////////////////////77
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
 Future<List<String>> obtenerMediaItemsciudades() async {
  final url = Uri.parse('http://corporationservisgroup.somee.com/api/Multimedias/ciudades');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<String>((item) => item['link'] ?? '')  // Extraer los links.
          .where((link) => link.isNotEmpty)  // Filtrar links vacíos.
          .toList();
    } else {
      throw Exception('Error al cargar los elementos de multimedia');
    }
  } catch (e) {
    return [];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////
Future<List<Map<String, dynamic>>> obtenerMediaItemsCopropiedad() async {
  final url = Uri.parse('http://corporationservisgroup.somee.com/api/Multimedias/ciudadescopropiedades');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map<Map<String, dynamic>>((item) => {
                'link': item['link'] ?? '',
                'linkdetallado': item['linkdetallado'] ?? ''
              })
          .toList();
    } else {
      throw Exception('Error al cargar elementos de copropiedad');
    }
  } catch (e) {
    return [];
  }
}




  // Función que trae los items de tu API
  Future<List<Map<String, String>>> fetchciudadescopropiedad() async {
    final url = Uri.parse(
        'http://corporationservisgroup.somee.com/api/Multimedias/ciudadescopropiedades');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((e) {
        return {
          'link': e['link'] ?? '',
          'linkdetallado': e['linkdetallado'] ?? '',
        };
      }).where((m) => m['link']!.isNotEmpty).toList();
    } else {
      throw Exception('Error al cargar copropiedades');
    }
  }



}







