# iVibe

App Flutter de crowdsourcing de vida noturna, restaurantes, rotas seguras e
feed de notícias hyperlocal, integrado com Firebase (Firestore + Auth).

## Estrutura do projeto

```
lib/
  main.dart                 # bootstrap do app (Firebase comentado por enquanto)
  firebase_options.dart     # placeholder - substituir com `flutterfire configure`
  models/                   # classes que espelham os documentos do Firestore
  services/                 # acesso ao Firestore/Auth (uma classe por colecao)
  screens/                  # telas do app (uma por widget)
  widgets/                  # componentes reutilizaveis
```

### Telas

- `screens/onboarding_screen.dart` — escolha do bairro preferido.
- `screens/main_navigation_screen.dart` — shell com bottom navigation.
- `screens/home_screen.dart` — mapa com pins dos estabelecimentos do bairro.
- `screens/establishment_detail_screen.dart` — detalhe + botão "Reportar".
- `screens/feed_screen.dart` — feed hyperlocal em cards estilo stories.
- `screens/profile_screen.dart` — pontos e badges do usuário.

### Modelo de dados (Firestore)

| Coleção         | Campos |
|-----------------|--------|
| `users`         | displayName, photoUrl, points, badges[], bairroPreferido, createdAt |
| `establishments`| name, type (balada/restaurante), lat, lng, bairro, genreOrCuisine, priceRange, createdBy, verified |
| `reports`       | establishmentId, userId, type (lotacao/fila/preco/vibe/promocao), value, confirmations, createdAt, expiresAt |
| `routes`        | fromLat, fromLng, toLat, toLng, safetyScore, reports[] |
| `routeReports`  | routeId, userId, type (iluminacao/movimento/seguranca), value, createdAt |
| `newsFeed`      | bairro, authorId, type (evento/transito/cultura/furo), content, mediaUrl, linkedEstablishmentId, upvotes, createdAt |

Cada coleção tem um model em `lib/models/` e um service correspondente em
`lib/services/` com `fromFirestore` / `toMap` e as operações de leitura
(streams) e escrita usadas pelas telas.

## Setup (Firebase ainda não conectado)

Por segurança, nenhuma credencial real do Firebase está neste repositório.
As pastas de plataforma (`android/`, `ios/`, `web/`) também não foram
geradas ainda. Para colocar o app para rodar de verdade:

1. **Gerar as pastas de plataforma** (uma vez, não sobrescreve `lib/` nem
   `pubspec.yaml` existentes):
   ```
   flutter create .
   ```

2. **Instalar dependências:**
   ```
   flutter pub get
   ```

3. **Criar o projeto no [Firebase Console](https://console.firebase.google.com/)**
   e habilitar Firestore + Authentication (método Anônimo).

4. **Gerar as credenciais reais** com o FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Isso substitui `lib/firebase_options.dart` (hoje só com placeholders)
   pelo arquivo real do seu projeto.

5. **Descomentar a inicialização do Firebase** em `lib/main.dart` (as linhas
   de import e a chamada `Firebase.initializeApp(...)` estão comentadas de
   propósito).

6. **Configurar o Google Maps:**
   - Android: adicionar a API key em `android/app/src/main/AndroidManifest.xml`
     (`com.google.android.geo.API_KEY`).
   - iOS: adicionar a API key em `ios/Runner/AppDelegate.swift`.

7. **Rodar o app:**
   ```
   flutter run
   ```

## Segurança

- Nunca commite `google-services.json`, `GoogleService-Info.plist` ou
  `firebase_options.dart` com chaves reais em um repositório público sem
  avaliar os riscos — prefira secrets do CI/CD.
- Configure as **Firestore Security Rules** antes de expor o app: por
  padrão, todo documento em `users` só deve ser editável pelo próprio uid
  autenticado, e escritas em `reports`/`newsFeed` devem exigir
  autenticação (mesmo anônima) para evitar spam.
