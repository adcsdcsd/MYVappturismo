import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'package:correa_tours/providers/usuarios_providers.dart';   // LoginProvider
import 'package:correa_tours/providers/multimedia_providers.dart'; // MultimediaProvider

// Screens
import 'package:correa_tours/screens/login_screen.dart';
import 'package:correa_tours/screens/home_screen.dart';
import 'package:correa_tours/screens/hotel_home.dart';

void main() async {
  // ✅ Necesario para usar SharedPreferences antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Creamos una instancia de LoginProvider y cargamos el userId guardado
  final loginProvider = LoginProvider();
  await loginProvider.loadUserId(); // <-- Aquí verifica en SharedPreferences si hay userId

  // ✅ Pasamos esa instancia ya cargada a la app
  runApp(MyApp(loginProvider: loginProvider));
}

class MyApp extends StatelessWidget {
  final LoginProvider loginProvider;
  const MyApp({super.key, required this.loginProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Usamos la misma instancia que ya tiene el userId cargado
        ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
        Provider(create: (_) => MultimediaProvider()),
      ],

      // ✅ Consumer escucha si cambia el estado de LoginProvider
      child: Consumer<LoginProvider>(
        builder: (context, loginProv, _) {
          return MaterialApp(
            title: 'Ecommers',
            theme: ThemeData(primarySwatch: Colors.blue),

            // 🔑 Aquí se decide:
            // Si hay userId en SharedPreferences → ir a Home
            // Si NO hay userId → ir a Login
            initialRoute: loginProv.isLoggedIn ? '/home' : '/login',

            routes: {
              '/login': (_) => const LoginScreen(),
              '/home': (_) => const HomeScreen(),
              '/hotel': (_) => const HotelHomeScreen(),
            },
          );
        },
      ),
    );
  }
}
