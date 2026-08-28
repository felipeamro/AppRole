import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: configure o Firebase antes de rodar o app de verdade.
  //
  // 1. Rode `flutter create .` na raiz do projeto para gerar as pastas
  //    android/ios/web (elas nao vao para o repositorio por seguranca).
  // 2. Rode `flutterfire configure` para gerar `lib/firebase_options.dart`
  //    com as credenciais reais do seu projeto Firebase.
  // 3. Descomente as duas linhas de import acima e a chamada abaixo.
  //
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const IVibeApp());
}

class IVibeApp extends StatelessWidget {
  const IVibeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iVibe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OnboardingScreen(),
    );
  }
}
