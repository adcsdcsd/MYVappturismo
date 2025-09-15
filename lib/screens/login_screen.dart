import 'package:correa_tours/providers/usuarios_providers.dart';
import 'package:flutter/material.dart';
import 'package:correa_tours/providers/multimedia_providers.dart';

import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController txtCedula = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
 
 
  @override
  Widget build(BuildContext context) {
    // Aquí obtenemos el LoginProvider desde el context
    final loginProvider = Provider.of<LoginProvider>(context);
    final Provider1 = Provider.of<MultimediaProvider>(context);


    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Usar FutureBuilder para cargar la imagen de fondo
            FutureBuilder<String>(
                future: Provider1.obtenerImagenLogin(), // Llamamos al método para obtener la imagen
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // Esperando la imagen
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar la imagen')); // Error al cargar
                } else if (snapshot.hasData) {
                  return Positioned.fill(
                    child: Image.network(
                      snapshot.data!,  // Aquí ponemos la URL de la imagen
                      fit: BoxFit.cover, // Ajustamos la imagen para que cubra toda la pantalla
                    ),
                  );
                } else {
                  return const Center(child: Text('No se encontró la imagen'));
                }
              },
            ),
            // El formulario de login estará por encima de la imagen de fondo
            loginForm(context, loginProvider), // Pasamos loginProvider aquí
          ],
        ),
      ),
    );
  }

  // Aquí va el formulario de login
  SingleChildScrollView loginForm(BuildContext context, LoginProvider loginProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 320),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "Login",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: txtCedula,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Cedula",
                          labelText: "Cédula",
                          icon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingrese su cédula";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: txtPassword,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: "*********",
                          labelText: "Contraseña",
                          icon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Por favor ingrese su contraseña";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 250,
                        height: 35,
                        child: MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.deepPurple,
                          child: loginProvider.isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  "Ingresar",
                                  style: TextStyle(color: Colors.white),
                                ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final cedula = txtCedula.text;
                              final password = txtPassword.text;

                              // Llamamos al método login del provider
                              bool success = await loginProvider.login(cedula, password);

                              // Usamos un setState para que el contexto se utilice después de la espera
                              if (success) {
                                if (mounted) {
                                 // Usar un `WidgetsBinding.instance.addPostFrameCallback` para navegar después de que el build se haya completado
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  });
                                }
                              } else {
                                if (mounted) {
                                  // Usar un `WidgetsBinding.instance.addPostFrameCallback` para mostrar el SnackBar después de que el build se haya completado
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loginProvider.errorMessage),
                                      ),
                                    );
                                  });
                                }
                              }
                           }
                          }
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
