import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/BaseBackground.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          extendBody: true,
          body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              const SliverAppBar(
                floating: true,
                snap: true,
                title: Text("ישוע"),
                centerTitle: true,
                actions: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25),
                    child: Icon(
                      Icons.account_circle_rounded,
                      color: Color.fromRGBO(255, 239, 227, 1),
                    ),
                  ),
                ],
                backgroundColor: Color.fromRGBO(37, 21, 22, 1),
                titleTextStyle: TextStyle(
                  color: Color.fromRGBO(255, 239, 227, 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            body: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Portada
                Positioned(
                  right: 0,
                  left: 0,
                  top: 0,
                  child: Stack(
                    children: [
                      Container(
                        height: 340,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(7, 7, 7, 1),
                          image: _coverImage != null
                              ? DecorationImage(
                                  image: FileImage(_coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _coverImage == null
                            ? const Center(
                                child: Icon(
                                  Icons.photo,
                                  size: 80,
                                  color: Colors.white30,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.black45,
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Cambiar portada',
                            icon: const Icon(Icons.camera_alt,
                                color: Colors.white),
                            onPressed: _pickCoverImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tarjeta vinotinto
                Positioned(
                  top: 230,
                  right: 0,
                  left: 0,
                  bottom: 0,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(37, 21, 22, 1), // vinotinto
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Foto de perfil
                            GestureDetector(
                              onTap: _pickProfileImage,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                                backgroundImage: _profileImage != null
                                    ? FileImage(_profileImage!)
                                    : null,
                                child: _profileImage == null
                                    ? const Icon(Icons.person,
                                        size: 40, color: Colors.white70)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Info al lado de la foto (luego la movemos debajo si quieres)
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Edward Kenway",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Saggitarius, Escorpios, Cancer",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Professional Looter",
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Menú: Threads | Photos | Videos
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Threads",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text("Photos",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text("Videos",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color.fromRGBO(37, 21, 35, 0),
          bottomNavigationBar: CurvedNavigationBar(
            index: 1,
            buttonBackgroundColor: const Color.fromRGBO(58, 27, 45, 1),
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
            color: const Color.fromRGBO(0, 0, 0, 1),
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            items: [
              const Icon(
                Icons.public_rounded,
                color: Color.fromRGBO(255, 239, 227, 0.7),
              ),
              SvgPicture.asset(
                'assets/images/Logo.svg',
                height: 43,
                width: 43,
              ),
              const Icon(
                Icons.chat,
                color: Color.fromRGBO(255, 239, 227, 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
