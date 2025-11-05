import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';
import 'package:provider/provider.dart';
import 'app_data.dart';

// 🔹 Plugins
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';

// Instancia global de notificaciones
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 Inicializar notificaciones
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // 🔹 Solicitar permisos de notificación (Android 13+)
  final status = await Permission.notification.status;
  if (status.isDenied || status.isRestricted) {
    bool granted = await Permission.notification.request().isGranted;
    print('Permiso de notificación: $granted');
  }

  // 🔹 Inicializar Flutter Background
  final androidConfig = FlutterBackgroundAndroidConfig(
    notificationTitle: "Pomodoro activo 🍅",
    notificationText: "Tu temporizador sigue corriendo...",
    notificationImportance: AndroidNotificationImportance.high,
    notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
  );

  bool backgroundInitialized =
      await FlutterBackground.initialize(androidConfig: androidConfig);
  if (backgroundInitialized) {
    await FlutterBackground.enableBackgroundExecution();
  }

  // 🔹 Ejecutar app con Provider
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppData(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CASAMO',
      theme: ThemeData(primarySwatch: Colors.purple),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) return const HomeScreen();
          return const LoginScreen();
        },
      ),
    );
  }
}









