import 'dart:convert';
import 'package:correa_tours/screens/CopropiedadListScreen.dart';
import 'package:correa_tours/screens/hotel_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CiudadescopropiedadScreen extends StatelessWidget {
  const CiudadescopropiedadScreen({super.key});

  // Función que trae los items de tu API
  Future<List<Map<String, String>>> _fetchCopropiedadItems() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Image.network(
              'https://i.ibb.co/tMMk0QV3/copropiedades.jpg',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            // Empieza la sección dinámica de imágenes
            FutureBuilder<List<Map<String, String>>>(
              future: _fetchCopropiedadItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Error: ${snapshot.error}')),
                  );
                }
                final items = snapshot.data!;
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child:
                        Center(child: Text('No hay copropiedades disponibles')),
                  );
                }

                // Muestra cada imagen en scroll vertical
                return Column(
                  children: items.map((item) {
                    final link = item['link']!;
                    final ciudad = item['linkdetallado']!;

                    return GestureDetector(
                      onTap: () {
                        Widget destino;

                        // ⚡️ Aquí decides a qué screen ir según el valor de ciudad
                        switch (ciudad) {
                          case 'HotelHomeScreen':
                            destino = const HotelHomeScreen();
                            break;

                          // Caso genérico: navega a la lista de copropiedades
                          default:
                            destino = CopropiedadListScreen(ciudad: ciudad);
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => destino),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(link),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
