import 'package:correa_tours/providers/multimedia_providers.dart';  // Importar MultimediaProvider
import 'package:correa_tours/providers/usuarios_providers.dart';
import 'package:correa_tours/screens/ciudadescopropiedad_screen.dart';
import 'hotel_home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'info_screen.dart';


final controller = CarouselSliderController();

String? extractYouTubeVideoId(String url) {
  final RegExp regExp = RegExp(r'(https?://(?:www\.)?youtube\.com/shorts/)([a-zA-Z0-9_-]+)');
  final match = regExp.firstMatch(url);

  if (match != null) {
    return match.group(2);
  }
  return null;
}

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
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: true,
        ),
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
    super.dispose();
    _controller.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  final UsuariosProvider _usuariosProvider = UsuariosProvider(); // Instancia para obtener los datos del usuario
  final MultimediaProvider _multimediaProvider = MultimediaProvider(); // Instancia para obtener los datos multimedia
  String? selectedImageId; // Variable para almacenar el ID de la imagen seleccionada
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
      heroImages = items;  // Asignamos la lista de mapas a heroImages
    });
  }

  Future<void> _obtenerMediaItems() async {
    List<String> items = await _multimediaProvider.obtenerMediaItems();
    setState(() {
      mediaItems = items;
    });
  }

  Future<void> _obtenerMediaItemsTurismo() async {
  List<Map<String, String>> itemst = await _multimediaProvider.obtenerMediaItemsTurismo();
  setState(() {
    mediaItemsturismo = itemst; // Asegúrate de que esta variable tenga el mismo tipo
  });
}

 @override
Widget build(BuildContext context) {
  return SafeArea( // 👈👈👈 Agrega SafeArea para dejar espacio en la parte superior (barra de estado)
    child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.29, // Altura del AppBar
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        flexibleSpace: Stack(
          children: [
            Positioned(
              top: -30,
              left: 0,
              right: 0,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.4, // Altura del carrusel
                width: MediaQuery.of(context).size.width,
                child: carrusel(), // Aquí está el carrusel
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
          // Barra de navegación
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;  // Cambiar el índice al seleccionar un ítem
                });
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Casa"),
                BottomNavigationBarItem(icon: Icon(Icons.surfing_sharp), label: "Turismo"),
                BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Formacion"),
              ],
            ),
          ),
          // Cuerpo con el contenido que cambia según el índice
          Expanded(child: _buildBody()),
          // Pie de página u otros widgets
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


  // Carrusel (ya no se encuentra en el body, ahora en el AppBar)
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
        String imageId = imageItem['id'] ?? '';  // Obtener el id de la imagen
        String imageLink = imageItem['link'] ?? '';  // Obtener el link detallado de la imagen

        return GestureDetector(
          onTap: () {
            // Navegar a la pantalla de detalles de la imagen y pasar el ID
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
      }).toList(),  // Convertir a lista de widgets
    );
  }

  // Sección de medios (se mantiene igual)
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
              image: DecorationImage(
                image: NetworkImage(link),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      }).toList(),
    );
  }

Widget _buildTurismoSection() {
  return Column(
    children: mediaItemsturismo.map((item) {
      final String link = item['link'] ?? '';
      final String linkdetallado = item['linkdetallado'] ?? '';

      if (link.isNotEmpty && linkdetallado.isNotEmpty) {
        return GestureDetector(
          onTap: () {
            print('Navegar a: $linkdetallado');

            // Aquí decides a qué pantalla navegar según linkdetallado
            Widget destino;
            switch (linkdetallado) {
              case 'CopropiedadScreen':
                destino = const CiudadescopropiedadScreen();
                break;
              case 'HotelHomeScreen':
                destino = const HotelHomeScreen();
                break;
              // Agrega más casos si tienes más pantallas
              default:
                destino = const Scaffold(
                  body: Center(child: Text('Pantalla no encontrada')),
                );
            }

            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destino),
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
      } else {
        return const SizedBox.shrink();
      }
    }).toList(),
  );
}



  // Este es el cuerpo de la pantalla donde cambiamos el contenido
  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Column(
          children: [
            // Carrusel (ya está en el AppBar)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMediaSection(),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1:
        return Column(
          children: [
            // Carrusel (ya está en el AppBar)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTurismoSection(),
                  ],
                ),
              ),
            ),
          ],
        );
      case 2:
        // Aquí puedes agregar la sección para "J.e Abogacia"
        return const Center(
          child: Text('J.e Abogacia content goes here'),
        );
      default:
        return Container();
    }
  }
}
