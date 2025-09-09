import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CopropiedadListScreen extends StatefulWidget {
  final String ciudad;
  const CopropiedadListScreen({super.key, required this.ciudad});

  @override
  State<CopropiedadListScreen> createState() => _CopropiedadListScreenState();
}

class _CopropiedadListScreenState extends State<CopropiedadListScreen> {
  List<Map<String, dynamic>> propiedades = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchPropiedades();
  }

  Future<void> _fetchPropiedades() async {
    final url = Uri.parse(
      'http://corporationservisgroup.somee.com/api/Copropiedades'
    );
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);

        // Filtramos solo las copropiedades de la ciudad deseada
        final listaFiltrada = data.where((e) => e['ubicacion'] == widget.ciudad).toList();

        setState(() {
          propiedades = listaFiltrada.map<Map<String, dynamic>>((e) {
            final fotos = [
              e['foto1'],
              e['foto2'],
              e['foto3'],
              e['foto4'],
              e['foto5'],
            ].where((f) => f != null && f.toString().isNotEmpty).toList();
            return {
              'id': e['id'],
              'ubicacion': e['ubicacion'],
              'descripcion': e['descripcion'],
              'fotos': fotos,
              'fotoPrincipal': fotos.isNotEmpty ? fotos[0] : null, // 📌 solo la primera
            };
          }).toList();
          loading = false;
        });
      } else {
        setState(() {
          error = 'Error ${resp.statusCode} al cargar datos';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Copropiedades en ${widget.ciudad}'),
        backgroundColor: Colors.teal,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Ocurrió un error:\n$error'))
              : propiedades.isEmpty
                  ? const Center(child: Text('No hay copropiedades'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: propiedades.length,
                      itemBuilder: (context, index) {
                        final prop = propiedades[index];
                        final foto = prop['fotoPrincipal'];
                        if (foto == null) return const SizedBox();
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CopropiedadDetailScreen(
                                  fotos: List<String>.from(prop['fotos']),
                                  descripcion: prop['descripcion'] ?? '',
                                ),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              foto,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

/// Pantalla de detalle con todas las fotos
class CopropiedadDetailScreen extends StatelessWidget {
  final List<String> fotos;
  final String descripcion;

  const CopropiedadDetailScreen({
    super.key,
    required this.fotos,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de la Copropiedad"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // Carrusel de fotos
          Expanded(
            child: PageView.builder(
              controller: controller,
              itemCount: fotos.length,
              itemBuilder: (context, i) {
                return Image.network(
                  fotos[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
          // Descripción
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              descripcion,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          // Botón de reservar
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Reserva realizada ✅")),
                );
              },
              icon: const Icon(Icons.hotel),
              label: const Text("Reservar ahora"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
