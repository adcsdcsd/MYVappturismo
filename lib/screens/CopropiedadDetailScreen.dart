import 'package:flutter/material.dart';

class CopropiedadDetailScreen extends StatelessWidget {
  final List<String> fotos;
  final String descripcion;

  const CopropiedadDetailScreen({
    Key? key,
    required this.fotos,
    required this.descripcion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Copropiedad'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Carrusel de fotos
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: fotos.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    fotos[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.broken_image));
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 🔢 Indicador de cantidad de fotos
            Center(
              child: Text(
                '${fotos.length} foto${fotos.length == 1 ? '' : 's'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),

            // 📝 Descripción
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Descripción',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                descripcion.isNotEmpty ? descripcion : 'Sin descripción',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
