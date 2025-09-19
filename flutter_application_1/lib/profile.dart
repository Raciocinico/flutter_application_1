import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/gestures.dart';

Future<UserCredential?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    // El usuario canceló el login
    return null;
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  return await FirebaseAuth.instance.signInWithCredential(credential);
}

extension NormalizeString on String {
  String normalize() {
    return toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ñ]'), 'n');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

class EditableProfileScreen extends StatefulWidget {
  const EditableProfileScreen({super.key});

  @override
  State<EditableProfileScreen> createState() => _EditableProfileScreenState();
}

class _EditableProfileScreenState extends State<EditableProfileScreen>
    with SingleTickerProviderStateMixin {
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController(viewportFraction: 0.75);
  List<File> selectedImages = [];

  // Controllers (vertical for NestedScrollView, horizontal for gallery)
  final ScrollController _verticalController = ScrollController();
  final ScrollController _scrollController = ScrollController();

  final nameController = TextEditingController(text: 'Henryk Ortega');
  final signsController =
      TextEditingController(text: '🌞 Aries | 🌝 Libra | ⬆️ Acuario');
  final jobController = TextEditingController(text: 'Logistics Coordinator');
  final studyController =
      TextEditingController(text: 'Estudiante de Ciencia de Datos');

  @override
  void initState() {
    super.initState();

    // Note: selectedImages starts empty; UI shows 3 slots (max) when rendering.
  }

  @override
  void dispose() {
    nameController.dispose();
    signsController.dispose();
    jobController.dispose();
    studyController.dispose();
    _pageController.dispose();
    _verticalController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ==== Tus métodos originales ====
  Future<void> pickImage(bool isProfile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(pickedFile.path);
        } else {
          _coverImage = File(pickedFile.path);
        }
      });
    }
  }

  // Nota: la lógica de agregar/reemplazar en la galería se mantiene exactamente como la tenías.
  // Aquí usamos _horizontalController (no inventé un método nuevo para la galería).

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBody: true,
        backgroundColor: const Color.fromRGBO(37, 21, 22, 1),

        drawer: Drawer(
          child: Container(
            color: const Color.fromRGBO(21, 37, 25, 1),
          ),
        ),

        // ❌ appBar eliminado —> lo movemos a SliverAppBar

        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
          color: const Color.fromRGBO(0, 0, 0, 1),
          buttonBackgroundColor: const Color.fromRGBO(58, 27, 45, 1),
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          items: [
            const Icon(Icons.public_rounded,
                color: Color.fromRGBO(255, 239, 227, 0.7)),
            SvgPicture.asset('assets/images/Logo.svg', height: 43, width: 43),
            const Icon(Icons.chat_rounded,
                color: Color.fromRGBO(255, 239, 227, 0.7)),
          ],
        ),

        body: Stack(
          children: [
            // 🎨 Tu fondo original
            Positioned.fill(
              child: Image.asset(
                'assets/images/BaseBackground.png',
                fit: BoxFit.cover,
              ),
            ),

            // 🔽 SliverAppBar que desaparece + tu TabBar/TabBarView originales
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  backgroundColor: const Color.fromRGBO(37, 21, 22, 1),
                  centerTitle: true,
                  elevation: 0,
                  // 👇 hace que desaparezca/reaparezca con scroll
                  floating: true,
                  snap: true,
                  pinned: false,

                  title: const Text(
                    "ישוע",
                    style: TextStyle(
                      color: Color.fromRGBO(255, 239, 227, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  leading: Builder(
                    builder: (context) {
                      return IconButton(
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        icon: const Icon(Icons.menu),
                        color: Color.fromRGBO(255, 239, 227, 0.7),
                      );
                    },
                  ),

                  actions: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Icon(Icons.search,
                          color: Color.fromRGBO(255, 239, 227, 0.7)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Icon(Icons.account_circle_rounded,
                          color: Color.fromRGBO(255, 239, 227, 0.7)),
                    ),
                  ],

                  bottom: const TabBar(
                    unselectedLabelColor: Color.fromRGBO(255, 239, 227, 0.5),
                    labelColor: Color.fromRGBO(255, 239, 227, 0.9),
                    dividerColor: Color.fromRGBO(0, 0, 0, 0),
                    indicatorColor: Color.fromRGBO(255, 239, 227, 0.9),
                    tabs: [
                      Tab(text: "Communities"),
                      Tab(text: "People"),
                    ],
                  ),
                ),
              ],
              body: SafeArea(
                top: false, // deja que el Sliver use el área superior
                child: TabBarView(
                  children: [
                    // 📌 Communities Tab (TAL CUAL lo tenías)
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // 🔹 Stack combinado portada + foto de perfil
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // 📌 Portada
                              Container(
                                height: 250,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: _coverImage != null
                                        ? FileImage(_coverImage!)
                                        : const NetworkImage(
                                                "https://via.placeholder.com/600x200")
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // 📌 Botón para cambiar portada
                              Positioned(
                                top: 10,
                                right: 10,
                                child: GestureDetector(
                                  onTap: () => pickImage(false),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),

                              // 📌 Contenedor superpuesto con foto e info
                              Positioned(
                                top: 180,
                                left: 16,
                                right: 16,
                                child: Container(
                                  height: 800,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(30, 18, 18, 1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 📌 Foto de perfil
                                      InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () => pickImage(true),
                                        child: _profileImage != null
                                            ? Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.white,
                                                      width: 3),
                                                  image: DecorationImage(
                                                    image: FileImage(
                                                        _profileImage!),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            : Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  const CircleAvatar(
                                                    radius: 60,
                                                    backgroundColor:
                                                        Colors.grey,
                                                  ),
                                                  Container(
                                                    width: 25,
                                                    height: 25,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 20),
                                                  ),
                                                ],
                                              ),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Dexter',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        '🌞 Cancer | 🌝 Libra | ⬆️ Acuario',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Logistics Coordinator',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Estudiante de Ciencia de Datos',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 250),

                          // 🔹 Carrusel (tu código original)
                          SizedBox(
                            height: 300,
                            child: ScrollConfiguration(
                              behavior: MaterialScrollBehavior().copyWith(
                                dragDevices: {
                                  PointerDeviceKind.touch,
                                  PointerDeviceKind.mouse,
                                  PointerDeviceKind.stylus,
                                  PointerDeviceKind.unknown,
                                },
                              ),
                              child: Listener(
                                onPointerSignal: (pointerSignal) {
                                  if (pointerSignal is PointerScrollEvent) {
                                    if (!_scrollController.hasClients) return;
                                    final newOffset =
                                        (_scrollController.offset +
                                                pointerSignal.scrollDelta.dy)
                                            .clamp(
                                      0.0,
                                      _scrollController
                                          .position.maxScrollExtent,
                                    );
                                    _scrollController.jumpTo(newOffset);
                                  }
                                },
                                child: Scrollbar(
                                  controller: _scrollController,
                                  thumbVisibility: true,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: Row(
                                      children: List.generate(3, (index) {
                                        final bool hasImage =
                                            selectedImages.length > index;
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(right: 16),
                                          width: 250,
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  final picked =
                                                      await _picker.pickImage(
                                                    source: ImageSource.gallery,
                                                  );
                                                  if (picked != null) {
                                                    setState(() {
                                                      if (hasImage) {
                                                        selectedImages[index] =
                                                            File(picked.path);
                                                      } else {
                                                        selectedImages.add(
                                                            File(picked.path));
                                                      }
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  height: 300,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border: Border.all(
                                                        color: Colors.white30),
                                                    image: hasImage
                                                        ? DecorationImage(
                                                            image: FileImage(
                                                                selectedImages[
                                                                    index]),
                                                            fit: BoxFit.cover,
                                                          )
                                                        : null,
                                                    color: const Color.fromRGBO(
                                                        56, 34, 32, 1),
                                                  ),
                                                  child: !hasImage
                                                      ? const Center(
                                                          child: Text(
                                                            "Tap to add image",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white54),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                              ),
                                              if (hasImage)
                                                Positioned(
                                                  top: 4,
                                                  right: 4,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedImages
                                                            .removeAt(index);
                                                      });
                                                    },
                                                    child: Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.black54,
                                                      ),
                                                      child: const Icon(
                                                          Icons.close,
                                                          size: 20,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              print("Nombre: ${nameController.text}");
                              print("Signos: ${signsController.text}");
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ),

                    // 📌 People Tab (igual)
                    const Center(child: Text('People Tab Content')),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
