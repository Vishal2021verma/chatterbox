import 'package:chatterbox/firebase_options.dart';
import 'package:chatterbox/provider/loading_provider.dart';
import 'package:chatterbox/screen/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoadingProvider>(
            create: (context) => LoadingProvider())
      ],
      child: Consumer<LoadingProvider>(builder: (context, provider, _) {
        return MaterialApp(
          builder: (context, child) => Scaffold(
            body: Stack(
              children: [
                child!,
                provider.isLoading
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(50),
                          color: const Color.fromARGB(36, 0, 0, 0),
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2)),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator()),
                                SizedBox(
                                  width: 18,
                                ),
                                Text(
                                  'Connecting...',
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                        ))
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          debugShowCheckedModeBanner: false,
          title: 'ChatterBox',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          navigatorKey: navigatorKey,
          home: const SplashScreen(),
        );
      }),
    );
  }
}
