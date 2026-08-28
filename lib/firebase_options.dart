// GENERATED PLACEHOLDER - SUBSTITUA por um arquivo real antes de rodar o app.
//
// Este arquivo NAO contem credenciais reais do Firebase. Os valores abaixo
// sao apenas placeholders para manter a estrutura de codigo compilavel.
//
// Para gerar o arquivo real e seguro, rode na raiz do projeto (depois de
// `flutter create .` para gerar as pastas de plataforma):
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Isso vai sobrescrever este arquivo com as chaves reais do seu projeto
// Firebase. NUNCA commite o arquivo gerado com credenciais reais em um
// repositorio publico sem avaliar os riscos; prefira variaveis de ambiente
// ou secrets do CI/CD para builds automatizados.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions nao configurado para esta plataforma: '
          '${Platform.operatingSystem}. Rode `flutterfire configure`.',
        );
    }
  }

  // TODO: substitua todos os valores 'YOUR_...' pelas credenciais reais
  // geradas pelo `flutterfire configure` (ou pelo console do Firebase).
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.ivibe',
  );
}
