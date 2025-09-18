import 'dart:async';

import 'package:correa_tours/providers/multimedia_providers.dart';
import 'package:correa_tours/providers/usuarios_providers.dart';
import 'package:correa_tours/screens/CopropiedadDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'info_screen.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
bool _copropiedadesCargadas = false;  // al inicio en false
Widget? _dynamicContent; // Contenido dinámico de copropiedades

String? extractYouTubeVideoId(String url) {
  final RegExp regExp =
      RegExp(r'(https?://(?:www\.)?youtube\.com/shorts/)([a-zA-Z0-9_-]+)');
  final match = regExp.firstMatch(url);
  if (match != null) return match.group(2);
  return null;
}

final controller = CarouselSliderController();

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  VideoPlayerWidgetState createState() => VideoPlayerWidgetState();
}

class VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    final videoId = extractYouTubeVideoId(widget.videoUrl);
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: true, mute: true),
      );
    } else {
      throw Exception('URL inválida de YouTube');
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.amber,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final UsuariosProvider _usuariosProvider = UsuariosProvider();
  final MultimediaProvider _multimediaProvider = MultimediaProvider();

  List<Map<String, String>> heroImages = [];
  List<String> mediaItems = [];
  List<Map<String, String>> mediaItemsturismo = [];
  String usuarioNombre = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _obtenerMultimediacarrusel();
    _obtenerMediaItemsTurismo();
    _obtenerMediaItems();
  }

  Future<void> _fetchUserData() async {
    String? nombre = await _usuariosProvider.obtenerDatosUsuario();
    setState(() {
      usuarioNombre = nombre ?? 'bazz';
    });
  }

  Future<void> _obtenerMultimediacarrusel() async {
    List<Map<String, String>> items = await _multimediaProvider.obtenerCarrusel();
    setState(() {
      heroImages = items;
    });
  }

  Future<void> _obtenerMediaItems() async {
    List<String> items = await _multimediaProvider.obtenerMediaItems();
    setState(() {
      mediaItems = items;
    });
  }

  Future<void> _obtenerMediaItemsTurismo() async {
    List<Map<String, String>> items = await _multimediaProvider.obtenerMediaItemsTurismo();
    setState(() {
      mediaItemsturismo = items;
    });
  }

  Widget carrusel() {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1,
        height: 200,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 20),
        autoPlayAnimationDuration: const Duration(seconds: 3),
        enlargeCenterPage: true,
      ),
      items: heroImages.map((imageItem) {
        String imageId = imageItem['id'] ?? '';
        String imageLink = imageItem['link'] ?? '';
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(imageId: imageId),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageLink),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      children: mediaItems.map((link) {
        if (link.contains('youtube.com/shorts')) {
          final videoId = extractYouTubeVideoId(link);
          if (videoId != null) {
            return Container(
              margin: const EdgeInsets.all(8),
              height: 200,
              child: VideoPlayerWidget(videoUrl: link),
            );
          } else {
            return const SizedBox.shrink();
          }
        } else if (link.endsWith('.mp4')) {
          return Container(
            margin: const EdgeInsets.all(8),
            height: 200,
            child: VideoPlayerWidget(videoUrl: link),
          );
        } else if (link.isNotEmpty) {
          return Container(
            margin: const EdgeInsets.all(8),
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(image: NetworkImage(link), fit: BoxFit.cover),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

 Widget _buildTurismoSection() {
  // Si ya tenemos detalle cargado, lo mostramos
  if (_copropiedadesCargadas && _dynamicContent != null) {
    return _dynamicContent!;
  }

  // Mientras no haya detalle, mostramos todas las imágenes menos
  // la de copropiedades si ya fue tocada
  return Column(
    children: mediaItemsturismo
        .where((item) =>
            !(item['linkdetallado'] == 'CopropiedadScreen' &&
              _copropiedadesCargadas))
        .map((item) {
      return GestureDetector(
        onTap: () async {
  if (_copropiedadesCargadas) return; // evita doble carga
  final multimediaProvider =
      Provider.of<MultimediaProvider>(context, listen: false);
  final copropiedades = await multimediaProvider.fetchciudadescopropiedad();
 setState(() {
  _copropiedadesCargadas = true;
  _dynamicContent = Column(
    children: copropiedades.map((item) {
      return GestureDetector(
        onTap: () async {
  // 1️⃣ Llamamos a la misma API de copropiedades
  final url = Uri.parse('http://corporationservisgroup.somee.com/api/Copropiedades');

  setState(() {
    _copropiedadesCargadas = true; // Marcamos que ahora mostraremos el detalle
  });

  try {
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final List<dynamic> data = json.decode(resp.body);
      print("/////////////////////////////////////////////////////////////////");
        print(data);
      // 📌 Filtra por la ciudad que desees (puedes pasarla en el item)
      final listaFiltrada = data.where((e) => e['linkdetallado'] == item['ubicacion']).toList();
      
      // 2️⃣ Creamos el mismo GridView que usa CopropiedadListScreen
      setState(() {
        _dynamicContent = GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: listaFiltrada.length,
          itemBuilder: (context, index) {
            final prop = listaFiltrada[index];
            // armamos la lista de fotos como en CopropiedadListScreen
            final fotos = [
              prop['foto1'],
              prop['foto2'],
              prop['foto3'],
              prop['foto4'],
              prop['foto5'],
            ].where((f) => f != null && f.toString().isNotEmpty).toList();
            final fotoPrincipal = fotos.isNotEmpty ? fotos[0] : null;
            if (fotoPrincipal == null) return const SizedBox();

            return GestureDetector(
              onTap: () {
                // 👇 Navegamos a la misma pantalla de detalle si quieres
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CopropiedadDetailScreen(
                      fotos: List<String>.from(fotos),
                      descripcion: prop['descripcion'] ?? '',
                    ),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.network(
                  fotoPrincipal,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        );
      });
    } else {
      setState(() {
        _dynamicContent = const Center(child: Text('Error al cargar copropiedades'));
      });
    }
  } catch (e) {
    setState(() {
      _dynamicContent = Center(child: Text('Error: $e'));
    });
  }
},

        child: Container(
          margin: const EdgeInsets.all(5),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(item['link']!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }).toList(),
  );
});
        },
        child: Container(
          margin: const EdgeInsets.all(8),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: NetworkImage(item['link'] ?? ''),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(child: _buildMediaSection());
      case 1:
        return SingleChildScrollView(
          child: Column(
            children: [
              _buildTurismoSection(),
            ],
          ),
        );
      case 2:
        return const Center(child: Text('J.e Abogacia content goes here'));
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.29,
          backgroundColor: Colors.white,
          flexibleSpace: Stack(
            children: [
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width,
                  child: carrusel(),
                ),
              ),
              Positioned(
                top: 0,
                left: 5,
                child: Text(
                  usuarioNombre.isNotEmpty ? usuarioNombre : "bazz",
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Image.network(
                    'https://i.ibb.co/whg7KFXf/corporation-removebg-preview.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
  setState(() {
    _selectedIndex = index;
    if (_selectedIndex == 1) {
      // 👈 Cada vez que entras a Turismo, reinicia el estado
      _copropiedadesCargadas = false;
      _dynamicContent = null;
    } else {
      // Al salir de Turismo también limpia por si acaso
      _dynamicContent = null;
    }
  });
},
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Casa"),
                BottomNavigationBarItem(icon: Icon(Icons.surfing_sharp), label: "Turismo"),
                BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Formacion"),
              ],
            ),
            Expanded(child: _buildBody()),
            Container(
              color: Colors.grey[200],
              child: const Text(
                '© 2025 Mi Empresa | Todos los derechos reservados',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
