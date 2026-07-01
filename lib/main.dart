import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pusher_beams/pusher_beams.dart';

import 'package:lucky/providers/auth_provider.dart';
import 'package:lucky/providers/banner_provider.dart';
import 'package:lucky/providers/categoria_provider.dart';
import 'package:lucky/providers/checkout_provider.dart';
import 'package:lucky/providers/favoritos_provider.dart';
import 'package:lucky/providers/generos_provider.dart';
import 'package:lucky/providers/carrito_provider.dart';

import 'package:lucky/services/pref_service.dart';
import 'package:lucky/utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = PrefService();
  await prefService.init();
  /*
  const instanceID = 'c5190994-49a1-4d86-ab48-70fca28a4704';

  try {
    await PusherBeams.instance.start(instanceID);
    await PusherBeams.instance.addDeviceInterest('ofertas');
    await PusherBeams.instance.addDeviceInterest('lanzamientos');

    final isLoggedIn = prefService.getLoginStatus();
    if (isLoggedIn) {
      final userId = prefService.getUserId();
      if (userId != null) {
        await PusherBeams.instance.addDeviceInterest('carrito-$userId');
      }
    }
  } catch (e) {
    // Errores controlados de Pusher
  } */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => FavoritosProvider()),
        ChangeNotifierProvider(create: (_) => GenerosProvider()),
        ChangeNotifierProvider(create: (_) => BannerProvider()),
        ChangeNotifierProvider(create: (_) => CategoriaProvider()),
        ChangeNotifierProvider(create: (_) => CheckoutProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter, // Asignamos el router externo aquí
        title: 'Lucky',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: const Color(0xFFED1C24),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
