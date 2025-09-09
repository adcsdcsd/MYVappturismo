import 'package:correa_tours/providers/usuarios_providers.dart';
import 'package:correa_tours/screens/hotel_home.dart'; 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:correa_tours/screens/login_screen.dart';
import 'package:correa_tours/screens/home_screen.dart';

 // Asegúrate de importar tu provider

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: MaterialApp(
        title: 'Ecommers',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login', // Define aquí la ruta inicial
        routes: {
          '/login': (context) =>  const LoginScreen(),
          '/home': (context) =>  const HomeScreen(),
          '/hotel': (context) =>  const HotelHomeScreen(),
        },
      ),
    );
  }
}
