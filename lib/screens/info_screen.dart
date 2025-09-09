import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

String imageIdNumber = '';

String extractNumber(String input) {
  RegExp regExp = RegExp(r'\d+'); // Expresión regular para encontrar solo los números
  var match = regExp.firstMatch(input); // Extrae la primera coincidencia
  return match?.group(0) ?? ''; // Retorna el número o una cadena vacía si no encuentra nada
}

class ImageDetailScreen extends StatefulWidget {
  final String imageId;  // Identificador único de la imagen
  
  const ImageDetailScreen({super.key, required this.imageId});  // Hacer obligatorio el ID de la imagen

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  late Future<Map<String, dynamic>> _imageData;

  // Hacemos la solicitud HTTP con base en el identificador
  Future<Map<String, dynamic>> fetchImageData() async {
    final response = await http.get(
      Uri.parse('http://corporationservisgroup.somee.com/api/MUltimedias/$imageIdNumber'),
    );
    if (response.statusCode == 200) {
      // Decodificamos el cuerpo de la respuesta JSON
      return json.decode(response.body); // Esto debería devolver un Map<String, dynamic>
    } else {
      throw Exception('Error al cargar los datos de la imagen');
    }
  }

  @override
  void initState() {
    super.initState();
    imageIdNumber = extractNumber(widget.imageId);  // Extraemos el número del ID de la imagen
    _imageData = fetchImageData();  // Inicializamos _imageData con la llamada HTTP
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: FutureBuilder<Map<String, dynamic>>(
      future: _imageData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // Mostrar los datos de la imagen
          var data = snapshot.data!;
          String imageUrl = data['linkdetallado'] ?? '';  // Cambié 'imageUrl' a 'link', y proporcioné un valor por defecto en caso de que sea null

          if (imageUrl.isEmpty) {
            return const Center(child: Text('No se ha encontrado la imagen'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height, // Hace que el AppBar ocupe todo el alto de la pantalla
                backgroundColor: Colors.transparent, // Hacemos el AppBar transparente
                elevation: 0, // Quitamos la sombra del AppBar
                flexibleSpace: Stack(
                  children: [
                    // Imagen de fondo
                    Positioned.fill(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover, // Asegura que la imagen cubra todo el espacio
                      ),
                    ),
                    // Botón de WhatsApp en la parte inferior
                    Positioned(
                      bottom: 20, // Distancia desde la parte inferior
                      left: MediaQuery.of(context).size.width * 0.5 - 30, // Centrado horizontal

                      
                      child: GestureDetector(
                        onTap: () {
                          const String phone = "960922421";
                          const String prefpais = "+593";
                          const String message ="hola soy luis con contrato 1212 pido una reserva para el tour para quito";
                         sendwh(phone: "$prefpais$phone", text: message);
                        },
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green, // Color de fondo del logo
                          ),
                          child: const Icon(
                            Icons.message, // Usamos un icono de mensaje para representar WhatsApp
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                leading: const BackButton(), // Botón de atrás visible
              ),
            ],
          );
        } else {
          return const Center(child: Text('No hay datos disponibles.'));
        }
      },
    ),
  );
}
}




Future<void> sendwh({
  required String phone, 
  required String text,
}) async {
  final Uri uri = Uri.parse(
    "https://wa.me/$phone?text=${Uri.encodeComponent(text)}",
  );

  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}
