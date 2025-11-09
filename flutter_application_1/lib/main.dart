import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
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
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter/gestures.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:async';

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

  runApp(
    ShowCaseWidget(
      builder: Builder(
        builder: (context) => const MyApp(),
      ),
    ),
  );
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Espera 1 segundo y redirige automáticamente
    Future.delayed(const Duration(seconds: 1), () {
      // 👇 Verifica que el widget siga montado antes de navegar
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Profilepage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(37, 22, 21, 80),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/Logo.svg',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/vg.png',
              width: 160,
              height: 160,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedButton = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/backg.svg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              width: 320,
              height: 340,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(42, 24, 29, 77),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),
                  SvgPicture.asset(
                    width: 50,
                    height: 50,
                    'assets/images/Logo.svg',
                  ),
                  Text(
                    'TGRS',
                    style: TextStyle(
                      color: const Color.fromRGBO(255, 255, 255, 100),
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 20, // Tamaño de altura
                        width: 24,
                      ), // Tamaño de ancho
                      label: Text("Use Google"),
                      onPressed: () async {
                        final userCredential = await signInWithGoogle();
                        if (userCredential != null) {
                          print(
                              "Usuario logueado: ${userCredential.user?.displayName}");
                        } else {
                          print("Login cancelado o fallido");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 7, 60, 93),
                        foregroundColor:
                            const Color.fromARGB(255, 227, 224, 224),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                      )),
                  const SizedBox(height: 10),
                  // 👇 BOTÓN PERSONALIZADO DE APPLE

                  ElevatedButton.icon(
                    icon: Icon(
                      FontAwesomeIcons.apple,
                      color: Colors.black,
                      size: 20,
                    ),
                    label: Text(
                      "Use Apple",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    onPressed: () async {
                      await Future.delayed(Duration(seconds: 1));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sign in with Apple')),
                      );
                      print("Usuario simulado: Enrique Ortega");
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromRGBO(255, 239, 227, 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                    ),
                  ),

                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistrationScreen(),
                        ),
                      );
                    },
                    icon: Icon(Icons.email, size: 20), // Ícono de sobre
                    label: Text('Use Email', style: TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(106, 41, 45, 100),
                      foregroundColor: Color.fromRGBO(255, 239, 227, 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Botón toggle fuera del Container, ahora con una integración más ajustada
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 280, // Ancho fijo
                child: ToggleSwitch(
                  minWidth: 140,
                  cornerRadius: 20.0,
                  activeBgColors: [
                    [const Color.fromARGB(255, 0, 0, 0)!],
                    [const Color.fromARGB(255, 0, 0, 0)!]
                  ],
                  activeFgColor: Colors.white,
                  inactiveBgColor: Color.fromRGBO(54, 15, 19, 1),
                  inactiveFgColor: Colors.white,
                  initialLabelIndex: 0,
                  totalSwitches: 2,
                  labels: ['New account', 'Existing account'],
                  radiusStyle: true,
                  onToggle: (index) {
                    Widget nextPage =
                        index == 0 ? RegistrationScreen() : HomeContent();

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => nextPage,
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ], // Aquí está el final del Stack
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _hasErrors = false;

  void _validateForm() {
    setState(() {
      _hasErrors = !_formKey.currentState!.validate();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 22, 21, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/backg.svg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: 350,
                  height: 580,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(42, 24, 29, 77),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Form(
                    key: _formKey, // Detecta cambios
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/images/Logo.svg',
                          width: 70,
                          height: 50,
                        ),
                        const Text(
                          'TGRS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Campo Full Name
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Full Name',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(255, 239, 227, 100)),
                              filled: true,
                              fillColor: Color.fromRGBO(106, 41, 45, 100),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(7, 7, 7, 1)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name can not be empty';
                              }
                              if (value.length < 5) {
                                return 'At least 5 letters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _usernameController,
                            textAlign: TextAlign.center,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: '@Username',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(255, 239, 227, 100)),
                              filled: true,
                              fillColor: Color.fromRGBO(106, 41, 45, 100),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(7, 7, 7, 1)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username can not be empty';
                              }
                              if (value.length < 5) {
                                return 'At least 5 letters and no spaces';
                              }
                              return null;
                            },
                          ),
                        ),
                        // Campo Email
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _emailController,
                            textAlign: TextAlign.center,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Email',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(255, 239, 227, 100)),
                              filled: true,
                              fillColor: Color.fromRGBO(106, 41, 45, 100),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(7, 7, 7, 1)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email can not be empty';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Provide a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Campo Password
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _passwordController,
                            textAlign: TextAlign.center,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Password',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(255, 239, 227, 100)),
                              filled: true,
                              fillColor: Color.fromRGBO(106, 41, 45, 100),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(7, 7, 7, 1)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can not be empty';
                              }
                              if (value.length < 7) {
                                return 'At least 7 characters';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Campo Confirm Password
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: TextFormField(
                            controller: _confirmPasswordController,
                            textAlign: TextAlign.center,
                            obscureText: true,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide(color: Colors.black)),
                              hintText: 'Confirm Password',
                              hintStyle: const TextStyle(
                                  color: Color.fromRGBO(255, 239, 227, 100)),
                              filled: true,
                              fillColor: Color.fromRGBO(106, 41, 45, 100),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(7, 7, 7, 1)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 2),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password can not be empty';
                              }
                              if (value.length < 7) {
                                return 'At least 7 characters';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 5),

                        // Botón Register
                        ElevatedButton(
                          onPressed: () async {
                            _validateForm();
                            if (!_hasErrors) {
                              final formState = _formKey.currentState;
                              if (formState != null && formState.validate()) {
                                try {
                                  final name = _nameController.text.trim();
                                  final username =
                                      _usernameController.text.trim();
                                  final email = _emailController.text.trim();
                                  final password =
                                      _passwordController.text.trim();

                                  // Crear usuario en Firebase
                                  final userCredential = await FirebaseAuth
                                      .instance
                                      .createUserWithEmailAndPassword(
                                          email: email, password: password);

                                  final uid = userCredential.user!.uid;

                                  // Guardar datos adicionales en Firestore
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(uid)
                                      .set({
                                    'name': name,
                                    'username': username,
                                    'email': email,
                                    'created_at': FieldValue.serverTimestamp(),
                                  });

                                  // Redirigir a DateTimeScreen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DateTimeScreen()),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  String errorMessage = "Registration failed";
                                  if (e.code == 'email-already-in-use') {
                                    errorMessage =
                                        'This email is already in use.';
                                  } else if (e.code == 'weak-password') {
                                    errorMessage = 'Password is too weak.';
                                  }
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMessage)),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Unexpected error: $e")),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color.fromRGBO(255, 239, 227, 100),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Create',
                            style: TextStyle(
                                color: Color.fromARGB(255, 17, 17, 17),
                                fontSize: 14),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Sign in with Apple')),
                                  );
                                  print("Usuario simulado: Enrique Ortega");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                      255, 239, 227, 1), // Fondo claro
                                  shape: const CircleBorder(
                                    side: BorderSide(
                                        color: Colors.black, width: 1),
                                  ),
                                  padding: const EdgeInsets.all(
                                      18), // Ajusta para tamaño circular
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.apple,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                              // Botón de Google sin texto

                              const SizedBox(width: 15),

                              // BElevatedButton(
                              ElevatedButton(
                                onPressed: () async {
                                  final userCredential =
                                      await signInWithGoogle();
                                  if (userCredential != null) {
                                    print(
                                        "Usuario logueado: ${userCredential.user?.displayName}");
                                  } else {
                                    print("Login cancelado o fallido");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 7, 60, 93),
                                  shape:
                                      CircleBorder(side: BorderSide(width: 0)),
                                  padding: const EdgeInsets.all(18),
                                ),
                                child: Image.asset(
                                  'assets/images/google.png',
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Contenedor de botones
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 130),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 280, // Ancho fijo
                  child: ToggleSwitch(
                    minWidth: 140,
                    cornerRadius: 20.0,
                    activeBgColors: [
                      [const Color.fromARGB(255, 0, 0, 0)],
                      [const Color.fromARGB(255, 0, 0, 0)]
                    ],
                    activeFgColor: Colors.white,
                    inactiveBgColor: Color.fromRGBO(54, 15, 19, 1),
                    inactiveFgColor: Colors.white,
                    initialLabelIndex: 0,
                    totalSwitches: 2,
                    labels: ['New account', 'Existing account'],
                    radiusStyle: true,
                    onToggle: (index) {
                      Widget nextPage =
                          index == 0 ? HomeScreen() : HomeContent();

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => nextPage,
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginWithEmail() async {
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DateTimeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'User not found.';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 22, 21, 100),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/backg.svg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Container(
                width: 370,
                height: 480,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(42, 24, 29, 77),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/Logo.svg',
                      width: 70,
                      height: 85,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'TGRS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _emailController,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(color: Colors.black)),
                          hintText: 'Use Email',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color.fromRGBO(106, 41, 45, 100),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(7, 7, 7, 1)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide:
                                  const BorderSide(color: Colors.black)),
                          hintText: 'Use Password',
                          hintStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color.fromRGBO(106, 41, 45, 100),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: const BorderSide(
                                color: Color.fromRGBO(7, 7, 7, 1)),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _loginWithEmail,
                            style: ElevatedButton.styleFrom(
                              foregroundColor:
                                  const Color.fromRGBO(255, 239, 227, 100),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 18),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 17, 17, 17),
                                  fontSize: 16),
                            ),
                          ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await Future.delayed(const Duration(seconds: 1));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Sign in with Apple')),
                              );
                              print("Usuario simulado: Enrique Ortega");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(255, 239, 227, 1),
                              shape: const CircleBorder(
                                side: BorderSide(color: Colors.black, width: 1),
                              ),
                              padding: const EdgeInsets.all(18),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.apple,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () async {
                              final userCredential = await signInWithGoogle();
                              if (userCredential != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const DateTimeScreen()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Login cancelado o fallido")),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 7, 60, 93),
                              shape: const CircleBorder(
                                  side: BorderSide(width: 0)),
                              padding: const EdgeInsets.all(18),
                            ),
                            child: Image.asset(
                              'assets/images/google.png',
                              height: 24,
                              width: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 280, // Ancho fijo
                  child: ToggleSwitch(
                    minWidth: 140,
                    cornerRadius: 20.0,
                    activeBgColors: [
                      [const Color.fromARGB(255, 0, 0, 0)!],
                      [const Color.fromARGB(255, 0, 0, 0)!]
                    ],
                    activeFgColor: Colors.white,
                    inactiveBgColor: Color.fromRGBO(54, 15, 19, 1),
                    inactiveFgColor: Colors.white,
                    initialLabelIndex: 1,
                    totalSwitches: 2,
                    labels: ['New account', 'Existing account'],
                    radiusStyle: true,
                    onToggle: (index) {
                      Widget nextPage =
                          index == 0 ? HomeScreen() : HomeContent();

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => nextPage,
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

const Map<String, String> countryNames = {
  "AF": "Afghanistan",
  "AL": "Albania",
  "DZ": "Algeria",
  "AS": "American Samoa",
  "AD": "Andorra",
  "AO": "Angola",
  "AI": "Anguilla",
  "AQ": "Antarctica",
  "AG": "Antigua and Barbuda",
  "AR": "Argentina",
  "AM": "Armenia",
  "AW": "Aruba",
  "AU": "Australia",
  "AT": "Austria",
  "AZ": "Azerbaijan",
  "BS": "Bahamas",
  "BH": "Bahrain",
  "BD": "Bangladesh",
  "BB": "Barbados",
  "BY": "Belarus",
  "BE": "Belgium",
  "BZ": "Belize",
  "BJ": "Benin",
  "BM": "Bermuda",
  "BT": "Bhutan",
  "BO": "Bolivia",
  "BA": "Bosnia and Herzegovina",
  "BW": "Botswana",
  "BR": "Brazil",
  "BN": "Brunei",
  "BG": "Bulgaria",
  "BF": "Burkina Faso",
  "BI": "Burundi",
  "KH": "Cambodia",
  "CM": "Cameroon",
  "CA": "Canada",
  "CV": "Cape Verde",
  "KY": "Cayman Islands",
  "CF": "Central African Republic",
  "TD": "Chad",
  "CL": "Chile",
  "CN": "China",
  "CO": "Colombia",
  "KM": "Comoros",
  "CD": "Congo (Democratic Republic)",
  "CG": "Congo (Republic)",
  "CR": "Costa Rica",
  "CI": "Côte d’Ivoire",
  "HR": "Croatia",
  "CU": "Cuba",
  "CY": "Cyprus",
  "CZ": "Czech Republic",
  "DK": "Denmark",
  "DJ": "Djibouti",
  "DM": "Dominica",
  "DO": "Dominican Republic",
  "EC": "Ecuador",
  "EG": "Egypt",
  "SV": "El Salvador",
  "GQ": "Equatorial Guinea",
  "ER": "Eritrea",
  "EE": "Estonia",
  "SZ": "Eswatini",
  "ET": "Ethiopia",
  "FJ": "Fiji",
  "FI": "Finland",
  "FR": "France",
  "GA": "Gabon",
  "GM": "Gambia",
  "GE": "Georgia",
  "DE": "Germany",
  "GH": "Ghana",
  "GR": "Greece",
  "GD": "Grenada",
  "GT": "Guatemala",
  "GN": "Guinea",
  "GW": "Guinea-Bissau",
  "GY": "Guyana",
  "HT": "Haiti",
  "HN": "Honduras",
  "HU": "Hungary",
  "IS": "Iceland",
  "IN": "India",
  "ID": "Indonesia",
  "IR": "Iran",
  "IQ": "Iraq",
  "IE": "Ireland",
  "IL": "Israel",
  "IT": "Italy",
  "JM": "Jamaica",
  "JP": "Japan",
  "JO": "Jordan",
  "KZ": "Kazakhstan",
  "KE": "Kenya",
  "KI": "Kiribati",
  "KW": "Kuwait",
  "KG": "Kyrgyzstan",
  "LA": "Laos",
  "LV": "Latvia",
  "LB": "Lebanon",
  "LS": "Lesotho",
  "LR": "Liberia",
  "LY": "Libya",
  "LI": "Liechtenstein",
  "LT": "Lithuania",
  "LU": "Luxembourg",
  "MG": "Madagascar",
  "MW": "Malawi",
  "MY": "Malaysia",
  "MV": "Maldives",
  "ML": "Mali",
  "MT": "Malta",
  "MH": "Marshall Islands",
  "MR": "Mauritania",
  "MU": "Mauritius",
  "MX": "Mexico",
  "FM": "Micronesia",
  "MD": "Moldova",
  "MC": "Monaco",
  "MN": "Mongolia",
  "ME": "Montenegro",
  "MA": "Morocco",
  "MZ": "Mozambique",
  "MM": "Myanmar",
  "NA": "Namibia",
  "NR": "Nauru",
  "NP": "Nepal",
  "NL": "Netherlands",
  "NZ": "New Zealand",
  "NI": "Nicaragua",
  "NE": "Niger",
  "NG": "Nigeria",
  "KP": "North Korea",
  "MK": "North Macedonia",
  "NO": "Norway",
  "OM": "Oman",
  "PK": "Pakistan",
  "PW": "Palau",
  "PA": "Panama",
  "PG": "Papua New Guinea",
  "PY": "Paraguay",
  "PE": "Peru",
  "PH": "Philippines",
  "PL": "Poland",
  "PT": "Portugal",
  "QA": "Qatar",
  "RO": "Romania",
  "RU": "Russia",
  "RW": "Rwanda",
  "KN": "Saint Kitts and Nevis",
  "LC": "Saint Lucia",
  "VC": "Saint Vincent and the Grenadines",
  "WS": "Samoa",
  "SM": "San Marino",
  "ST": "São Tomé and Príncipe",
  "SA": "Saudi Arabia",
  "SN": "Senegal",
  "RS": "Serbia",
  "SC": "Seychelles",
  "SL": "Sierra Leone",
  "SG": "Singapore",
  "SK": "Slovakia",
  "SI": "Slovenia",
  "SB": "Solomon Islands",
  "SO": "Somalia",
  "ZA": "South Africa",
  "KR": "South Korea",
  "SS": "South Sudan",
  "ES": "Spain",
  "LK": "Sri Lanka",
  "SD": "Sudan",
  "SR": "Suriname",
  "SE": "Sweden",
  "CH": "Switzerland",
  "SY": "Syria",
  "TW": "Taiwan",
  "TJ": "Tajikistan",
  "TZ": "Tanzania",
  "TH": "Thailand",
  "TL": "Timor-Leste",
  "TG": "Togo",
  "TO": "Tonga",
  "TT": "Trinidad and Tobago",
  "TN": "Tunisia",
  "TR": "Turkey",
  "TM": "Turkmenistan",
  "TV": "Tuvalu",
  "UG": "Uganda",
  "UA": "Ukraine",
  "AE": "United Arab Emirates",
  "GB": "United Kingdom",
  "US": "United States",
  "UY": "Uruguay",
  "UZ": "Uzbekistan",
  "VU": "Vanuatu",
  "VE": "Venezuela",
  "VN": "Vietnam",
  "YE": "Yemen",
  "ZM": "Zambia",
  "ZW": "Zimbabwe",
};

class DateTimeScreen extends StatefulWidget {
  const DateTimeScreen({super.key});

  @override
  State<DateTimeScreen> createState() => _DateTimeScreenState();
}

class _DateTimeScreenState extends State<DateTimeScreen> {
  String? selectedMonth;
  int? selectedDay;
  int? selectedYear;
  String? selectedTime;
  bool isUnknownTime = false;
  bool isLoading = true;
  bool isTyping = false;
  late TextEditingController cityController = TextEditingController();
  late FocusNode _focusNode =
      FocusNode(); // 🔹 Añadido para controlar el enfoque

  List<dynamic> allCities = [];
  String? selectedCity;

  String normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[áàäâã]'), 'a')
        .replaceAll(RegExp(r'[éèëê]'), 'e')
        .replaceAll(RegExp(r'[íìïî]'), 'i')
        .replaceAll(RegExp(r'[óòöôõ]'), 'o')
        .replaceAll(RegExp(r'[úùüû]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[^a-z0-9 ]'), '');
  }

  @override
  void initState() {
    super.initState();
    cityController = TextEditingController();
    _focusNode = FocusNode();
    loadCities();
  }

  @override
  void dispose() {
    cityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> loadCities() async {
    final String response = await rootBundle.loadString('assets/cities.json');
    final data = await json.decode(response);
    setState(() {
      allCities = data;
      isLoading = false;
    });
    // Eliminado el manejo manual del foco con delays para evitar parpadeos
  }

  Widget buildCityField() {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: cityController,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          labelText: 'Birth City',
          border: OutlineInputBorder(),
          hintText: 'Type at least 2 letters...',
        ),
        onChanged: (value) {
          setState(() {
            isTyping = value.length >= 2;
          });
        },
      ),
      suggestionsCallback: (pattern) {
        if (!isTyping || isLoading || allCities.isEmpty) return [];

        final normalizedPattern = normalizeText(pattern);

        // Filtrar las ciudades que contienen el patrón
        List<dynamic> filtered = allCities.where((city) {
          final name = normalizeText(city['name'] ?? '');
          return name.contains(normalizedPattern);
        }).toList();

        // Ordenar: primero las coincidencias exactas, luego alfabéticamente
        filtered.sort((a, b) {
          final query = normalizedPattern;
          bool aExact = normalizeText(a['name']) == query;
          bool bExact = normalizeText(b['name']) == query;
          if (aExact && !bExact) return -1;
          if (!aExact && bExact) return 1;
          return a['name'].compareTo(b['name']);
        });

        // Retornar solo los primeros 5 resultados
        return filtered.take(5);
      },
      itemBuilder: (context, dynamic city) {
        return ListTile(
          title: Text(
            '${city['name']}, ${countryNames[city['country']] ?? city['country']}',
          ),
        );
      },
      onSuggestionSelected: (dynamic city) {
        cityController.text =
            '${city['name']}, ${countryNames[city['country']] ?? city['country']}';
        setState(() {
          selectedCity = city['name'];
        });
      },
      hideOnEmpty: false,
      hideOnLoading: true,
      keepSuggestionsOnLoading: false,
      getImmediateSuggestions: false,
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        elevation: 4.0,
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 22, 21, 100),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/backg.svg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Container(
                width: 370,
                height: 480,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 249, 249),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Your Date Of Birth",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "You cannot change this later",
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        buildDropdown(
                          value: selectedMonth,
                          hint: const Text("Month"),
                          items: [
                            "January",
                            "February",
                            "March",
                            "April",
                            "May",
                            "June",
                            "July",
                            "August",
                            "September",
                            "October",
                            "November",
                            "December"
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue;
                            });
                          },
                          width: 130,
                        ),
                        const SizedBox(width: 10),
                        buildDropdown(
                          value: selectedDay?.toString(),
                          hint: const Text("DD"),
                          items: List.generate(
                              31, (index) => (index + 1).toString()),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDay = newValue != null
                                  ? int.tryParse(newValue)
                                  : null;
                            });
                          },
                          width: 80,
                        ),
                        const SizedBox(width: 10),
                        buildDropdown(
                          value: selectedYear?.toString(),
                          hint: const Text("YYYY"),
                          items: List.generate(
                              100,
                              (index) =>
                                  (DateTime.now().year - index).toString()),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedYear = newValue != null
                                  ? int.tryParse(newValue)
                                  : null;
                            });
                          },
                          width: 90,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        buildTimeButton(),
                        const SizedBox(width: 15),
                        Row(
                          children: [
                            Checkbox(
                              value: isUnknownTime,
                              onChanged: (bool? value) {
                                setState(() {
                                  isUnknownTime = value ?? false;
                                  if (isUnknownTime) {
                                    selectedTime = null;
                                  }
                                });
                              },
                            ),
                            const Text("Unknown Time",
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 80),

                    /// 🔽 Campo de ciudad con autocompletado
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : buildCityField(),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (selectedCity != null &&
                                (selectedTime != null || isUnknownTime)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoUploadScreen(
                                    city: selectedCity!,
                                    time: selectedTime,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Por favor selecciona ciudad y hora'),
                                ),
                              );
                            }
                          },
                          child: const Text("Next"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double width,
    required Widget hint,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint,
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildTimeButton() {
    return InkWell(
      onTap: isUnknownTime
          ? null
          : () async {
              TimeOfDay? pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: Color.fromRGBO(42, 24, 29, 1),
                        hourMinuteTextColor: Color.fromRGBO(0, 0, 0, 1),
                        dialBackgroundColor: Colors.grey,
                        dialTextColor: Color.fromRGBO(0, 0, 0, 1),
                        dialHandColor: Color.fromRGBO(255, 239, 227, 100),
                        entryModeIconColor: Color.fromRGBO(255, 239, 227, 100),
                      ),
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.grey,
                        backgroundColor: Color.fromRGBO(251, 249, 250, 1),
                        cardColor: Color.fromRGBO(255, 239, 227, 100),
                      ),
                    ),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                      ),
                      child: child!,
                    ),
                  );
                },
              );

              if (pickedTime != null) {
                setState(() {
                  selectedTime =
                      "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
                });
              }
            },
      child: Container(
        width: 150,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isUnknownTime ? Colors.grey[300] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        alignment: Alignment.center,
        child: Text(
          selectedTime ?? "HH:MM",
          style: TextStyle(
            fontSize: 18,
            color: isUnknownTime ? Colors.grey : Colors.black,
          ),
        ),
      ),
    );
  }
}

class PhotoUploadScreen extends StatefulWidget {
  final String city;
  final String? time;

  const PhotoUploadScreen({
    super.key,
    required this.city,
    this.time,
  });

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  File? image1;
  File? image2;
  File? image3;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(int index) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (index == 1) image1 = File(picked.path);
      });
    }
  }

  Widget buildImageBox(File? imageFile, int index) {
    const double borderRadiusValue = 25;

    return Stack(
      children: [
        Container(
          width: 113,
          height: 157,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(42, 24, 29, 1),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(borderRadiusValue),
          ),
          child: imageFile != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              : const Center(
                  child: Text("", style: TextStyle(color: Colors.white)),
                ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => pickImage(index),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  bool allImagesUploaded() {
    return image1 != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(37, 22, 21, 1),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/backg.svg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: Container(
                width: 390,
                height: 532,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 250, 249, 249),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔙 Botón de regreso
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Center(
                      child: Column(
                        children: [
                          Text(
                            'Add Profile Picture',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This can be changed later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: buildImageBox(image1, 1),
                    ),
                    const SizedBox(height: 40),

                    /// ✅ Botón para continuar
                    Center(
                      child: ElevatedButton(
                        onPressed: allImagesUploaded()
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Profilepage(),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Color.fromRGBO(255, 239, 227,
                              1), // Asegúrate que el valor alfa sea 1 o un double válido
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromRGBO(255, 239, 227, 1),
                          ),
                        ),
                      ),
                    ),
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

class Thread {
  final String username;
  final String content;
  final DateTime timestamp;
  Map<String, int> reactions = {"❤️": 0, "🔥": 0, "👏": 0};
  List<String> comments = [];

  Thread({
    required this.username,
    required this.content,
    required this.timestamp,
  });
}

class Profilepage extends StatefulWidget {
  const Profilepage({super.key});

  @override
  State<Profilepage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Profilepage> {
  OverlayEntry? _imagesOverlay;

  void _showImagesOverlay() {
    if (_imagesOverlay != null) return;

    _imagesOverlay = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/vg1.png', width: 120, height: 120),
              const SizedBox(width: 20),
              Image.asset('assets/images/vg2.png', width: 120, height: 120),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_imagesOverlay!);
  }

  void _removeImagesOverlay() {
    _imagesOverlay?.remove();
    _imagesOverlay = null;
  }

  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();
  final List<File> _videos = [];
  List<File> _photos = [];
  int selectedTab = 0; // 0=Threads, 1=Photos, 2=Videos
  List<Thread> threads = [];

  TextEditingController threadController = TextEditingController();
  Timer? _timer;

  // Showcase keys
  final GlobalKey _pfpKey = GlobalKey();
  final GlobalKey _profileIconKey = GlobalKey();
  final GlobalKey _iconKey = GlobalKey();
  final GlobalKey _threadsKey = GlobalKey();
  final GlobalKey _photosKey = GlobalKey();
  final GlobalKey _videosKey = GlobalKey();

  bool _isShowcaseActive = false;
  bool _showFab = true;

  // Formato de tiempo relativo
  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    threadController.dispose();
    super.dispose();
  }

  // Pickers
  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickCoverImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _coverImage = File(pickedFile.path));
    }
  }

  Future<void> _pickPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _photos.insert(0, File(pickedFile.path)));
    }
  }

  Future<void> _pickVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _videos.add(File(pickedFile.path)));
    }
  }

  void _addThread() {
    if (threadController.text.isNotEmpty) {
      setState(() {
        threads.insert(
          0,
          Thread(
            username: "Edward Kenway",
            content: threadController.text,
            timestamp: DateTime.now(),
          ),
        );
        threadController.clear();
      });
    }
  }

  void _addReaction(Thread thread, String emoji) {
    setState(() {
      thread.reactions[emoji] = (thread.reactions[emoji] ?? 0) + 1;
    });
  }

  void _addComment(Thread thread, String text) {
    setState(() {
      thread.comments.add(text);
    });
  }

  Widget _buildReactions(Thread thread) {
    return Row(
      children: thread.reactions.keys.map((emoji) {
        return TextButton(
          onPressed: () => _addReaction(thread, emoji),
          child: Text(
            "$emoji ${thread.reactions[emoji]}",
            style: const TextStyle(color: Colors.white70),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThreadsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  controller: threadController,
                  decoration: const InputDecoration(
                    hintText: "Write a new thread...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _addThread,
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: threads.length,
          itemBuilder: (context, index) {
            final thread = threads[index];
            final commentController = TextEditingController();
            return Card(
              color: const Color.fromRGBO(58, 27, 45, 1),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(thread.username,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(thread.content,
                        style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text(timeAgo(thread.timestamp),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 10),
                    _buildReactions(thread),
                    const Divider(color: Colors.white24),
                    Column(
                      children: thread.comments
                          .map((c) => Align(
                                alignment: Alignment.centerLeft,
                                child: Text("- $c",
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: "Write a comment...",
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.white70),
                          onPressed: () {
                            if (commentController.text.isNotEmpty) {
                              _addComment(thread, commentController.text);
                              commentController.clear();
                            }
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPhotosTab() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickPhoto,
          label: const Text("+"),
        ),
        const SizedBox(height: 10),
        _photos.isEmpty
            ? const Text("No hay fotos aún",
                style: TextStyle(color: Colors.white70))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _photos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    height: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black26,
                      image: DecorationImage(
                        image: FileImage(_photos[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildVideosTab() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickVideo,
          label: const Text("+"),
        ),
        const SizedBox(height: 10),
        _videos.isEmpty
            ? const Text("No hay videos aún",
                style: TextStyle(color: Colors.white70))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(8),
                    height: 220,
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(Icons.play_circle_fill,
                          size: 100, color: Colors.white70),
                    ),
                  );
                },
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      builder: Builder(
        builder: (context) => Scaffold(
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BaseBackground.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  title: Text("ישוע"),
                  centerTitle: true,
                  actions: [
                    Showcase(
                      key: _profileIconKey, // GlobalKey genérica
                      description: "Tap here to view your profile 📝",
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25),
                        child: IconButton(
                          icon: Icon(Icons.account_circle_rounded,
                              color: Color.fromRGBO(255, 239, 227, 1)),
                          onPressed: () {
                            // acción opcional al tocar el icono
                          },
                        ),
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
                              ? Center(
                                  child: Showcase(
                                    key: _pfpKey,
                                    description:
                                        "Tap here to add a cover image 📸",
                                    child: Icon(Icons.photo,
                                        size: 80, color: Colors.white30),
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

                  // Tarjeta vinotinto con scroll
                  Positioned(
                    top: 250,
                    right: 0,
                    left: 0,
                    child: Container(
                      height: 290,
                      margin: const EdgeInsets.symmetric(horizontal: 25),
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(37, 21, 22, 1),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Showcase(
                              key: _iconKey,
                              description: "Change your profile picture 📝",
                              child: GestureDetector(
                                onTap:
                                    _pickProfileImage, // opcional: acción al tocar
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : null,
                                  child: _profileImage == null
                                      ? Icon(Icons.person,
                                          size: 50, color: Colors.white70)
                                      : null,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text("Edward Kenway",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18)),
                            const SizedBox(height: 5),
                            const Text("Saggitarius, Escorpios, Cancer",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 5),
                            const Text("Professional Looter",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 20),

                            // Menú manual

                            //Delayed 1- 1:30 (logo) "All set. Explore!" ()
                            //remove content//
                            //floating action button middle center, big "Tap here to start tutorial (Aprox. 30)"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Showcase(
                                  key: _threadsKey,
                                  description:
                                      "Write your thoughts and opinions 🧵", //TEMP
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedTab = 0),
                                    child: Text("Threads",
                                        style: TextStyle(
                                            color: selectedTab == 0
                                                ? Colors.white
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Showcase(
                                  key: _photosKey,
                                  description: "Share photos 📸",
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedTab = 1),
                                    child: Text("Photos",
                                        style: TextStyle(
                                            color: selectedTab == 1
                                                ? Colors.white
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                Showcase(
                                  key: _videosKey,
                                  description: "Share videos 🎥",
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedTab = 2),
                                    child: Text("Videos",
                                        style: TextStyle(
                                            color: selectedTab == 2
                                                ? Colors.white
                                                : Colors.white54,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Contenido dinámico
                            Builder(
                              builder: (context) {
                                if (selectedTab == 0) return _buildThreadsTab();
                                if (selectedTab == 1) return _buildPhotosTab();
                                return _buildVideosTab();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Floating Action Button con Showcase
                  if (_showFab)
                    Positioned(
                      top: MediaQuery.of(context).size.height / 2 -
                          40, // centra vertical (80 / 2)
                      left: MediaQuery.of(context).size.width / 2 -
                          40, // centra horizontal (80 / 2)
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: FloatingActionButton(
                          backgroundColor: const Color.fromRGBO(58, 27, 45, 1),
                          child: const Icon(Icons.play_arrow,
                              color: Colors.white, size: 40),
                          onPressed: () {
                            final showcase = ShowCaseWidget.of(context);

                            // 🔹 Muestra las imágenes del tutorial si las hay
                            _removeImagesOverlay();

                            if (showcase != null) {
                              setState(() {
                                _isShowcaseActive = true;
                                _showFab =
                                    false; // desaparece el FAB al iniciar
                              });

                              // 🔹 Inicia el recorrido del Showcase
                              showcase.startShowCase([
                                _profileIconKey,
                                _pfpKey,
                                _iconKey,
                                _threadsKey,
                                _photosKey,
                                _videosKey,
                              ]);

                              // 🔹 Oculta las imágenes después de unos segundos o al finalizar
                              Future.delayed(const Duration(seconds: 3), () {
                                if (mounted) {
                                  setState(() {
                                    _isShowcaseActive = false;
                                    // _showFab ya está false, no vuelve a aparecer
                                  });
                                  _removeImagesOverlay();
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),

                  // Imágenes del tutorial
                  if (_isShowcaseActive) ...[],
                ],
              ),
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
              const Icon(Icons.public_rounded,
                  color: Color.fromRGBO(255, 239, 227, 0.7)),
              SvgPicture.asset('assets/images/Logo.svg', height: 43, width: 43),
              const Icon(Icons.chat, color: Color.fromRGBO(255, 239, 227, 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}



