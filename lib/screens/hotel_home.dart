import 'dart:async';
import 'dart:ui';

import 'package:correa_tours/providers/multimedia_providers.dart';
import 'package:correa_tours/services/amadeus_service.dart';
import 'package:flutter/material.dart';

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({super.key});

  @override
  _HotelHomeScreenState createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen> {
  final AmadeusService _amadeusService = AmadeusService();
  final MultimediaProvider _multimediaProvider = MultimediaProvider();

  List<String> mediaItemsciudades = [];
  List<dynamic> _hotels = [];
  bool _loading = false;
  int _currentImageIndex = 0;
  Timer? _imageTimer;
  bool _isSearching = false;
  String? _searchedCityName;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final List<String> _citySuggestions = [];

  @override   
  void initState() {
    super.initState();
    _loadMediaItemsCiudades();
    _startImageFadeTimer();
  }

  @override
  void dispose() {
    _imageTimer?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMediaItemsCiudades() async {
    List<String> items = await _multimediaProvider.obtenerMediaItemsciudades();
    if (mounted) {
      setState(() {
        mediaItemsciudades = items;
      });
    }
  }

  void _startImageFadeTimer() {
    _imageTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mediaItemsciudades.isNotEmpty) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % mediaItemsciudades.length;
        });
      }
    });
  }
Future<Iterable<Map<String, String>>> _getCitySuggestions(String input) async {
  if (input.isEmpty) return const Iterable.empty();

  try {
    final suggestions = await _amadeusService.getCitySuggestions(input);

    return suggestions.map((suggestion) {
      final name = suggestion['name'] ?? 'Ciudad desconocida';
      final country = suggestion['country'] ?? 'País desconocido';
      final iataCode = suggestion['iataCode'] ?? '';

      return {
        'name': '$name, $country',
        'iataCode': iataCode,
      };
    });
  } catch (e) {
    print("Error obteniendo sugerencias: $e");
    return const Iterable.empty();
  }
}






 Future<void> _loadHotelsByCity(String city) async {
  setState(() {
    _loading = true;
    _isSearching = true;
    _hotels = [];
  });

  try {
    final hotels = await _amadeusService.getHotelsByCity(city);
    setState(() {
      _hotels = hotels;
    });
  } catch (e) {
    print('Error al obtener hoteles por ciudad: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se encontraron hoteles en $city')),
    );
  } finally {
    setState(() {
      _loading = false;
      _isSearching = false;
    });
  }
}


  Widget _buildSearchBar() {
    
  return ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: RawAutocomplete<Map<String, dynamic>>(
          textEditingController: _searchController,
          focusNode: _searchFocusNode,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            final suggestions = await _getCitySuggestions(textEditingValue.text);
            return suggestions;
          },
          onSelected: (Map<String, dynamic> selectedCity) {
            final cityName = selectedCity['name'] ?? 'Ciudad desconocida';
            setState(() {
              _searchController.text = '$cityName';
              _searchedCityName = cityName;
            });
            final iataCode = selectedCity['iataCode'] ?? '';
            if (iataCode.isEmpty) return;
            _loadHotelsByCity(iataCode);
          },
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              style: const TextStyle(color: Colors.black),
              decoration:  InputDecoration(
                hintText: 'Buscar ciudad...',
                icon: _isSearching
                  ? const SizedBox(
                 width: 20,
                 height: 20,
                 child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search, color: Colors.black),

                border: InputBorder.none,
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ListView.separated(
                  padding: const EdgeInsets.all(8.0),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(option['name'] ?? ''),
                      subtitle: Text('Código IATA: ${option['iataCode'] ?? 'N/A'}'),
                      onTap: () => onSelected(option),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}


 Widget _buildHotelList() {
  if (_loading) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: CircularProgressIndicator(),
    );
  }
  if (_hotels.isEmpty) {
    return const SizedBox(); // No muestra nada si no hay hoteles aún
  }

  return GridView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(), // para que funcione con SingleChildScrollView
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,           // 👈 dos columnas
      crossAxisSpacing: 12,        // espacio horizontal entre tarjetas
      mainAxisSpacing: 12,         // espacio vertical entre tarjetas
      childAspectRatio: 0.8,       // relación ancho/alto (ajústalo según contenido)
    ),
    itemCount: _hotels.length,
    itemBuilder: (context, index) {
      final hotel = _hotels[index];
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.hotel, size: 28),
              const SizedBox(height: 8),
              Text(
                hotel['name'] ?? 'Nombre no disponible',
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                hotel['address']?['lines']?.join(', ') ?? 'Dirección no disponible',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
  children: [
    if (mediaItemsciudades.isNotEmpty)
      AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        child: Image.network(
          mediaItemsciudades[_currentImageIndex],
          key: ValueKey<String>(mediaItemsciudades[_currentImageIndex]),
          fit: BoxFit.cover,
          height: double.infinity,
          width: double.infinity,
        ),
      )
    else
      const Center(child: CircularProgressIndicator()),

    // 🔍 Buscador y estado de búsqueda
    Positioned(
      top: 40,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          if (_isSearching && _searchedCityName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Text(
                'Buscando hoteles en $_searchedCityName...',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
        ],
      ),
    ),

    // ✅ Texto fijo informativo
   if (!_isSearching && _searchedCityName != null)
  Positioned(
    top: 80,
    left: 0,
    right: 0,
    child: AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 500),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((255 * 0.3).round()), // Fondo negro translúcido
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hotel, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'hoteles en $_searchedCityName',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
                    ],
                  ),
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
  // Dentro de Stack en el método build
// ✅ Lista de hoteles debajo del mensaje
if (_hotels.isNotEmpty)
  Positioned(
    top: 180,
    left: 0,
    right: 0,
    bottom: 0,
    child: SingleChildScrollView(
      child: _buildHotelList(),
    ),
  ),
      
  ],
      )
    );
  }
}
  
