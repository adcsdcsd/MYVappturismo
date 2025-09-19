import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CopropiedadDetailScreen extends StatefulWidget {
  final List<String> fotos;
  final String descripcion;
   final int copropiedadId;
  const CopropiedadDetailScreen({
    super.key,
    required this.fotos,
    required this.descripcion,
    required this.copropiedadId,
  });

  @override
  State<CopropiedadDetailScreen> createState() =>
      _CopropiedadDetailScreenState();
      
}

class _CopropiedadDetailScreenState extends State<CopropiedadDetailScreen> {
  final PageController _pageController = PageController();

  // Campos del formulario
  DateTime? _fechaEntrada;
  DateTime? _fechaSalida;
  int _habSencillas = 0;
  int _habDobles = 0;
  int _habTriples = 0;

  // Formato de fecha
  final DateFormat _formatter = DateFormat('dd/MM/yyyy');

  // ---- Modal de Reserva ----
void _mostrarFormularioReserva() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black.withOpacity(0.3),
    barrierColor: Colors.black54,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) {
          return StatefulBuilder( // 👈 Para refrescar solo el modal
            builder: (context, setModalState) {

              // 👉 Cálculo dinámico de precio
              double calcularPrecio() {
                if (_fechaEntrada == null || _fechaSalida == null) return 0;
                int noches = _fechaSalida!.difference(_fechaEntrada!).inDays;
                if (noches <= 0) return 0;

                const double precioSencilla = 50.0; // 💲 Ejemplo por noche
                const double precioDoble    = 80.0;
                const double precioTriple   = 100.0;

                return noches *
                    (_habSencillas * precioSencilla +
                     _habDobles    * precioDoble +
                     _habTriples   * precioTriple);
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Formulario de Reserva",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ------------------ Fecha de entrada ------------------
                      ListTile(
                        title: Text(
                          "Fecha de entrada: ${_fechaEntrada != null
                              ? _formatter.format(_fechaEntrada!)
                              : 'Seleccionar'}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (fecha != null) {
                            setModalState(() => _fechaEntrada = fecha);
                          }
                        },
                      ),
                      const Divider(),

                      // ------------------ Fecha de salida -------------------
                      ListTile(
                        title: Text(
                          "Fecha de salida: ${_fechaSalida != null
                              ? _formatter.format(_fechaSalida!)
                              : 'Seleccionar'}",
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final fecha = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (fecha != null) {
                            setModalState(() => _fechaSalida = fecha);
                          }
                        },
                      ),
                      const Divider(),

                      const SizedBox(height: 10),
                      const Text(
                        "Número de habitaciones",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      // ----------- Steppers de habitaciones -----------------
                      _buildStepper("Sencillas",
                          (v) => setModalState(() => _habSencillas = v),
                          _habSencillas),
                      _buildStepper("Dobles",
                          (v) => setModalState(() => _habDobles = v),
                          _habDobles),
                      _buildStepper("Triples",
                          (v) => setModalState(() => _habTriples = v),
                          _habTriples),

                      const SizedBox(height: 20),

                      // ------------------ Precio total ----------------------
                      Center(
                        child: Text(
                          "Precio total: \$${calcularPrecio().toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------- Botón de Confirmar -------------------
                    ElevatedButton.icon(
  onPressed: () {
    // 👉 Cuando el usuario toca "Confirmar Reserva", mostramos un diálogo de confirmación
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar reserva"),
          content: Text(
            "¿Desea confirmar la reserva?\n\n"
            "Total: \$${calcularPrecio().toStringAsFixed(2)}\n"
            "Entrada: ${_fechaEntrada != null ? _formatter.format(_fechaEntrada!) : '---'}\n"
            "Salida: ${_fechaSalida != null ? _formatter.format(_fechaSalida!) : '---'}\n"
            "Sencillas: $_habSencillas, Dobles: $_habDobles, Triples: $_habTriples",
          ),
          actions: [
            // Botón de cancelar
            TextButton(
              onPressed: ()  {
                Navigator.of(context).pop(); // Cierra SOLO el AlertDialog
              },
              child: const Text("Cancelar"),
            ),
            // Botón de aceptar
            ElevatedButton(
              onPressed: () async{
                Navigator.of(context).pop(); // Cierra el AlertDialog
                Navigator.of(context).pop(); // Cierra el modal principal (bottom sheet)

                 SharedPreferences prefs = await SharedPreferences.getInstance();
                int? userId = prefs.getInt('userId');
                if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No se encontró usuario logueado")),
                  );
                return;
                }
                


                final reservaData = {
      "usuarioId": userId,
      "copropiedadId": widget.copropiedadId, // id de la copropiedad actual
      "fechaEntrada": _fechaEntrada?.toIso8601String(),
      "fechaSalida": _fechaSalida?.toIso8601String(),
      "habSencillas": _habSencillas,
      "habDobles": _habDobles,
      "habTriples": _habTriples,
      "costoTotal": calcularPrecio(),
    };


    try {
      final response = await http.post(
        Uri.parse('https://tuservidor.com/api/reservas'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reservaData),
      );

      // 5️⃣ Mostrar resultado
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Reserva enviada correctamente ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al enviar reserva ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión ❌")),
      );
    }
  
 


                // ✅ Aquí pones lo que sucede cuando se confirma la reserva
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Reserva enviada ✅\n"
                      "Total: \$${calcularPrecio().toStringAsFixed(2)}\n"
                      "Entrada: ${_fechaEntrada != null ? _formatter.format(_fechaEntrada!) : '---'}\n"
                      "Salida: ${_fechaSalida != null ? _formatter.format(_fechaSalida!) : '---'}\n"
                      "Sencillas: $_habSencillas, Dobles: $_habDobles, Triples: $_habTriples",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  },
  icon: const Icon(Icons.check),
  label: const Text("Confirmar Reserva"),
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),
    backgroundColor: Colors.teal,
    textStyle: const TextStyle(fontSize: 18),
  ),
),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

  // Widget para cada tipo de habitación
  Widget _buildStepper(String titulo, ValueChanged<int> onChanged, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
            ),
            Text(value.toString(),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 1),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ✅ Imagen más pequeña (altura fija)
          Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45, // imagen más baja
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.fotos.length,
                  itemBuilder: (context, i) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.fotos[i],
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            color: Colors.black54,
                            child: Text(
                              widget.descripcion,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Puedes agregar aquí más info si quieres debajo de la imagen
              Expanded(child: Container()), // relleno
            ],
          ),

          // ✅ Botón fijo para reservar
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: ElevatedButton.icon(
              onPressed: _mostrarFormularioReserva,
              icon: const Icon(Icons.hotel),
              label: const Text("Reservar ahora"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
