import 'package:flutter/material.dart';
import 'package:kaiu/src/core/controllers/theme_controller.dart';
import 'package:kaiu/src/ui/configure.dart';
import 'package:kaiu/src/ui/pages/admin_pages/admin_page_view.dart';
import 'package:kaiu/src/ui/pages/home_components/kaiju_galery_banner.dart';
import 'package:kaiu/src/ui/pages/home_components/logo_banner.dart';
import 'package:kaiu/src/ui/pages/home_components/special_offers.dart';
import 'package:kaiu/src/ui/pages/home_components/ultrabrother_banner.dart';
import 'package:kaiu/src/ui/pages/home_components/popular_product.dart';
import 'package:kaiu/src/ui/widget/Logo/logo.dart';

class Home extends StatelessWidget {
  static String routeName = "/home";
  final theme = ThemeController.instance;
  Home({super.key});
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: theme.brightness,
        builder: (BuildContext context, value, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Página Inicio", style: TextStyle(color: theme.exTextPrimary()),),
              backgroundColor: theme.exBackground(),
              actions: [
                PopupMenuButton<String>(
                  color: Colors.white.withOpacity(0.9),
                  icon: Icon(
                    Icons.settings,
                    color: theme.exTextPrimary(),
                  ),
                  onSelected: (value) {
                    // Acción a realizar cuando se selecciona una opción
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        child: theme.brightnessValue
                            ? Text("Modo Obscuro")
                            : Text('Modo Claro'),
                        onTap: () {
                          theme.changeTheme();
                        },
                      ),
                      PopupMenuItem<String>(
                        value: 'opcion2',
                        child: Text('Cerrar Sesión'),
                        onTap: () {
                          print("Aquí va Cerrar Sesión Papi");
                        },
                      ),
                      PopupMenuItem<String>(
                        value: 'opcion3',
                        child: Text('Modo Admin'),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AdminPageView()));
                        },
                      ),
                    ];
                  },
                ),
              ],
            ),
            backgroundColor: theme.background(),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    UltraBrotherBanner(),
                    KaijuGaleryBanner(),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
