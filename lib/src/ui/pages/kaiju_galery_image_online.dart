// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:kaiu/src/core/models/kaiju.dart';
import 'package:kaiu/src/ui/pages/error_page.dart';
import 'package:kaiu/src/core/services/database.dart';
import 'package:kaiu/src/core/constants/functions.dart';
import 'package:kaiu/src/core/controllers/theme_controller.dart';

class KaijuGaleryImageOnline extends StatefulWidget {
  final Kaiju kaiju;

  const KaijuGaleryImageOnline({super.key, required this.kaiju});

  @override
  State<KaijuGaleryImageOnline> createState() => _KaijuGaleryImageOnlineState();
}

class _KaijuGaleryImageOnlineState extends State<KaijuGaleryImageOnline> {
  final theme = ThemeController.instance;
  final database = DatabaseMethods.instance;

  List<String> imageUrls = [];

  // Agrega más URL de imágenes según sea necesario  ];

  bool _isConnected = true;

  // Método para verificar la conexión a Internet
  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No hay conexión
      setState(() {
        _isConnected = false;
      });
    } else {
      // Hay conexión
      setState(() {
        _isConnected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkInternetConnection().then((value) {
      database
          .getStorageLinkFiles('GalleryImages/${widget.kaiju.name}/')
          .then((listLinks) {
        //Cambio de Estado.
        setState(() {
          imageUrls = listLinks;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected
        ? Scaffold(
            backgroundColor: theme.background(),
            appBar: AppBar(
              backgroundColor: colorFromHex(widget.kaiju.colorHex),
              iconTheme: IconThemeData(color: Colors.white),
              title: Text(
                "Galería Kaiju",
                style: TextStyle(color: Colors.white),
              ),
            ),
            body: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                    kaijuName: widget.kaiju.name,
                                    imageUrls: imageUrls,
                                    initialIndex: index,
                                  )));
                    },
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.all(8.0),
                      child: Image.network(
                        imageUrls[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }),
          )
        : ErrorPage();
  }
}

class FullScreenImage extends StatefulWidget {
  final String kaijuName;
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImage(
      {Key? key,
      required this.imageUrls,
      required this.initialIndex,
      required this.kaijuName})
      : super(key: key);

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PageController _pageController;
  final theme = ThemeController.instance;
  int currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    currentPageIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  // Future<void> _downloadImage(String imageUrl) async {
  //   final response = await http.get(Uri.parse(imageUrl));
  //   final bytes = response.bodyBytes;

  //   final appDir = await getExternalStorageDirectory();
  //   final fileName = imageUrl.split('/').last;
  //   final localFilePath = '${appDir!.path}/$fileName';

  //   final file = File(localFilePath);
  //   await file.writeAsBytes(bytes);

  //   // Guardar la imagen en la galería
  //   final result = await ImageGallerySaver.saveFile(localFilePath);

  //   if (result != null && result.isNotEmpty) {
  //     Fluttertoast.showToast(
  //       msg: 'Imagen descargada y guardada en la galería',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.black,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //     // print('Imagen descargada y guardada en la galería: $result');
  //   } else {
  //     Fluttertoast.showToast(
  //       msg: 'Error al guardar la imagen en la galería',
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.BOTTOM,
  //       timeInSecForIosWeb: 1,
  //       backgroundColor: Colors.black,
  //       textColor: Colors.white,
  //       fontSize: 16.0,
  //     );
  //     // print('Error al guardar la imagen en la galería');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Text(
          widget.kaijuName,
          style: TextStyle(
            color: Colors.white,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w200,
          ),
        ),
        actions: [
          // IconButton(
          //   icon: Icon(Icons.download),
          //   onPressed: () {
          //     Fluttertoast.showToast(
          //       msg: "Descargando...",
          //       toastLength: Toast.LENGTH_SHORT,
          //       gravity: ToastGravity.CENTER,
          //       backgroundColor: Colors.black,
          //       textColor: Colors.white,
          //     );
          //     _downloadImage(widget.imageUrls[currentPageIndex]);
          //   },
          // ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Deslizar hacia la derecha
            _pageController.previousPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          } else {
            // Deslizar hacia la izquierda
            _pageController.nextPage(
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          onPageChanged: (index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Center(
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
