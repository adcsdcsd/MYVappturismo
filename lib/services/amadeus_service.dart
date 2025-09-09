
import 'package:dio/dio.dart';

class AmadeusService {
  final Dio _dio = Dio();
  String? _accessToken;

  final String _clientId = 'tZzUAv4Xlz9rODgOdj7BtRUPwJPHF5kE';
  final String _clientSecret = 'ZjA0NfmRBJOjZO6G';

  // Autenticación para obtener el token de acceso
  Future<void> authenticate() async {
    final response = await _dio.post(
      'https://test.api.amadeus.com/v1/security/oauth2/token',
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
      data: {
        'grant_type': 'client_credentials',
        'client_id': _clientId,
        'client_secret': _clientSecret,
      },
    );

    if (response.statusCode == 200) {
      _accessToken = response.data['access_token'];
    
    } else {
      throw Exception('No se pudo obtener el token de acceso');
    }
  }

  // Obtener hoteles por una lista de IDs
  Future<List<dynamic>> getHotelsById(List<String> hotelIds) async {
    if (_accessToken == null) await authenticate();

    final idsParam = hotelIds.join(',');

    final response = await _dio.get(
      'https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-hotels',
      queryParameters: {'hotelIds': idsParam},
      options: Options(
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/vnd.amadeus+json',
        },
      ),
    );

    return response.data['data'];
  }

  // Obtener sugerencias de ciudades
   // Obtener sugerencias de ciudades (con nombre, país e IATA)
Future<List<Map<String, dynamic>>> getCitySuggestions(String input) async {
  if (_accessToken == null) await authenticate();

  final String apiUrl = 'https://test.api.amadeus.com/v1/reference-data/locations?keyword=$input&subType=CITY';

  try {
    final response = await _dio.get(
      apiUrl,
      options: Options(
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/vnd.amadeus+json',
        },
      ),
    );

    if (response.statusCode == 200) {
      List<Map<String, dynamic>> suggestions = [];


      // Iteramos sobre los datos de las ciudades
      for (var item in response.data['data']) {
        // Imprimimos los datos para ver si están correctos

        final address = item['address'] ?? {};
        suggestions.add({
          'name': item['name'] ?? 'Desconocido',
          'country': address['countryName'] ?? 'País desconocido',
          'iataCode': item['iataCode'] ?? 'N/A',
        });
      
      }

      // Devolvemos las sugerencias
      return suggestions;
    } else {
      throw Exception('Error en la respuesta: ${response.statusCode}');
    }
  } catch (e) {
    print('Error al obtener sugerencias: $e');
    throw Exception('No se pudieron obtener sugerencias');
  }
}

Future<List<dynamic>> getHotelsByCity(String cityCode) async {
  if (_accessToken == null) await authenticate();

  try {
    final hotelsResponse = await _dio.get(
      'https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-city',
      queryParameters: {
        'cityCode': cityCode,
        'radiusUnit': 'KM',
        'hotelSource': 'FULL',
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/vnd.amadeus+json',
        },
      ),
    );

    if (hotelsResponse.statusCode == 200 && hotelsResponse.data['data'] != null) {
      final hotels = List<Map<String, dynamic>>.from(hotelsResponse.data['data']);

      // Extraer hotelIds y asegurarse de que no haya espacios
      final hotelIds = hotels
          .map((hotel) => hotel['hotelId'])
          .whereType<String>()
          .map((id) => id.trim()) // Eliminar espacios en los hotelIds
          .toList();
      print("Total de hotelIds: ${hotelIds.length}");

      if (hotelIds.isEmpty) return hotels;

      List<Map<String, dynamic>> allImages = [];

      // Dividir la lista de hotelIds en grupos de máximo 20
      for (var i = 0; i < hotelIds.length; i += 20) {
        final batch = hotelIds.skip(i).take(20).toList();

        final imagesResponse = await _dio.get(
          'https://test.api.amadeus.com/v1/reference-data/locations/hotels/by-hotels',
          queryParameters: {  
            'hotelIds': batch.join(','),
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $_accessToken',
              'Accept': 'application/vnd.amadeus+json',
            },
          ),
        );

        if (imagesResponse.statusCode == 200 && imagesResponse.data['data'] != null) {
          final imagesData = List<Map<String, dynamic>>.from(imagesResponse.data['data']);
          allImages.addAll(imagesData);
          print("/////////////////////////// Imágenes obtenidas ///////////////////////");
          print(imagesResponse.data['data']);
        } else {
          print("Error al obtener imágenes, status code: ${imagesResponse.statusCode}");
        }
      }

      // Combinar los datos de hoteles y las imágenes
      for (int i = 0; i < hotels.length; i++) {
        final hotel = hotels[i];
        final hotelId = hotel['hotelId'];
        final hotelImages = allImages.where((image) => image['hotelId'] == hotelId).toList();

        hotel['images'] = hotelImages; // Añadir las imágenes al hotel
      }

      return hotels;
    } else {
      print("Error al obtener hoteles: ${hotelsResponse.statusCode}");
      return [];
    }
  } catch (e) {
    print("Error: $e");
    return [];
  }
}
}