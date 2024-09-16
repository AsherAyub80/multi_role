import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit/media_kit.dart';
import 'package:multi_role/GoogleMap/google_map.dart';
import 'package:multi_role/auth/bio_metric.dart';
import 'package:multi_role/firebase_options.dart';
import 'package:multi_role/theme/theme_controller.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  MediaKit.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final fcmToken = await FirebaseMessaging.instance.getToken();
  print(fcmToken);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          theme: ThemeData(
            brightness:
                themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
          ),

          home: GoogleMaps(), // Replace with your actual home screen
        );
      },
    );
  }
}
