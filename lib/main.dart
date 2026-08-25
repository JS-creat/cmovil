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
import 'package:lucky/providers/cupon_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = PrefService();
  await prefService.init();
  
  const instanceID = '11dd7a01-62c2-4ab0-942e-37a4be40cbda';

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
  } catch (e, s) {
    debugPrint("ERROR: $e");
    debugPrint("$s");
  }

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
        ChangeNotifierProvider(create: (_) => CuponProvider()),//nuevo
      ],
      child: MaterialApp.router(
        routerConfig: appRouter, // Asignamos el router externo aquí
        title: 'B-EDEN',
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
