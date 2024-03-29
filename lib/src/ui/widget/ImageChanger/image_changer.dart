import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kaiu/src/core/constants/functions.dart';
import 'package:kaiu/src/core/models/kaiju.dart';
import 'package:kaiu/src/core/services/database.dart';
import 'package:kaiu/src/ui/configure.dart';

class ImageChanger extends StatefulWidget {
  //Pasamos la referencia del enemigo actual
  final Kaiju kaiju;
  const ImageChanger({super.key, required this.kaiju});

  @override
  State<ImageChanger> createState() => _ImageChangerState();
}

class _ImageChangerState extends State<ImageChanger> {
  late Kaiju kaiju;
  List<dynamic>? kaijuImages = [];
  int currentImageIndex = 0;
  bool isLiked = false;
  final database = DatabaseMethods.instance;

  @override
  void initState() {
    super.initState();
    kaiju = widget.kaiju;
    kaijuImages = kaiju.img;
    database.hasUserLikedPost(kaiju.id).then((value) {
      setState(() {
        isLiked = value;
      });
    });
  }

  void changeImageNext() {
    setState(() {
      // Cambia la imagen actual al siguiente índice en forma circular.
      currentImageIndex = (currentImageIndex + 1) % kaijuImages!.length;
    });
  }

  void changeImagePrevious() {
    setState(() {
      // Cambia la imagen actual al índice anterior en forma circular.
      currentImageIndex =
          (currentImageIndex - 1 + kaijuImages!.length) % kaijuImages!.length;
    }); // 0 - 1 - 2 - 3
  }

  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      changeImageNext();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
          _startTimer();
        },
        onLongPressEnd: (details) {
          _stopTimer();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Contenedor principal que envuelve la imagen y el icono de corazón
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  // Imagen dentro del ClipRRect
                  Image.network(
                    kaijuImages![currentImageIndex],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                  // Icono de corazón dentro del ClipRRect
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                        // padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white70,
                        ),
                        child: IconButton(
                          onPressed: () async {
                            // Actualiza el estado local de isLiked
                            setState(() {
                              isLiked = !isLiked;
                              // Actualiza el número de votos localmente
                              kaiju.vote += isLiked ? 1 : -1;
                            });

                            // Actualiza la base de datos Firebase
                            Map<String, dynamic> updateInfo = {
                              "vote": kaiju.vote
                            };
                            //Lógica del Booleano invertido
                            if (isLiked) {
                              await database.likePost(kaiju.id);
                            } else {
                              await database.unlikePost(kaiju.id);
                            }
                            await database.updateKaijuDetail(
                                kaiju.id, updateInfo);
                          },
                          icon: isLiked
                              ? Icon(
                                  Icons.favorite,
                                  color: Color.fromARGB(255, 211, 12, 12),
                                  size: 25,
                                )
                              : Icon(
                                  Icons.favorite,
                                  color: Colors.black54,
                                  size: 25,
                                ),
                        )),
                  ),
                  widget.kaiju.yLink != "-" ? Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white70,
                      ),
                      child: IconButton(
                        onPressed: () {
                          applaunchUrl(widget.kaiju.yLink);
                        },
                        icon: Icon(
                          Icons
                              .smart_display, // Reemplaza "new_icon" con el icono que desees usar
                          color: Color.fromARGB(255, 221, 13, 13), // Color del icono
                          size: 25, // Tamaño del icono
                        ),
                      ),
                    ),
                  )
                  : Container(),
                ],
              ),
            ),

            // Par de Botones que Generan la Acción de Cambio de Imagen.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Material(
                    color: colorFromHex(kaiju.colorHex).withOpacity(0.5),
                    child: InkWell(
                      onTap: changeImagePrevious,
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.arrow_left,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child:
                        Container()), // Este widget ocupa el espacio restante,
                ClipOval(
                  child: Material(
                    color: colorFromHex(kaiju.colorHex).withOpacity(0.5),
                    child: InkWell(
                      onTap: changeImageNext,
                      child: const SizedBox(
                        width: 50,
                        height: 50,
                        child: Icon(
                          Icons.arrow_right,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
