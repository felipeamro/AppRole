import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/establishment.dart';
import 'firestore_paths.dart';

/// Numero de confirmacoes distintas necessarias para um estabelecimento
/// cadastrado pela comunidade passar de `verified: false` para `true`.
const int kVerificationThreshold = 15;

/// Operacoes sobre a colecao `establishments`.
class EstablishmentService {
  EstablishmentService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  final FirebaseFirestore? _injectedFirestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(FirestorePaths.establishments);

  /// Estabelecimentos de um bairro, usados para popular os pins do mapa.
  Stream<List<Establishment>> watchByBairro(String bairro) {
    // TODO(temporario): remover apos diagnosticar o bug de pins que nao
    // aparecem no mapa (ver conversa sobre o Liverpool Bar).
    debugPrint(
      '[EstablishmentService.watchByBairro] filtro="[$bairro]" '
      'length=${bairro.length} codeUnits=${bairro.codeUnits}',
    );
    debugPrint(
      '[EstablishmentService.watchByBairro] projectId=${_firestore.app.options.projectId} '
      'databaseId=${_firestore.databaseId} appName=${_firestore.app.name} '
      'collectionPath="${_collection.path}"',
    );
    _debugDumpAllRaw();

    return _collection
        .where('bairro', isEqualTo: bairro)
        .snapshots()
        // Erros do Firestore (ex: "permission-denied") nao passam pelo
        // .map() abaixo. handleError() por padrao ENGOLE o erro se o
        // callback nao relancar - por isso o throwWithStackTrace explicito,
        // preservando o stack trace original, para o card de erro no Mapa
        // continuar aparecendo.
        //
        // NOTA: a tentativa anterior usava StreamTransformer.fromHandlers()
        // sem parametros de tipo explicitos, que o Dart inferia como
        // StreamTransformer<dynamic, dynamic> - isso corrompia o tipo da
        // stream de forma diferente em Web (dart2js) e nativo, causando
        // "type 'List<dynamic>' is not a subtype of type
        // 'List<Establishment>'" so na Web. handleError() nao tem esse
        // problema porque preserva o tipo original da stream (Stream<T> ->
        // Stream<T>, sem precisar inferir um tipo novo).
        .handleError((Object error, StackTrace stackTrace) {
          debugPrint('[EstablishmentService.watchByBairro] ERRO na stream do Firestore: $error');
          Error.throwWithStackTrace(error, stackTrace);
        })
        .map((s) {
          final establishments = s.docs.map(Establishment.fromFirestore).toList();
          debugPrint(
            '[EstablishmentService.watchByBairro] bairro="$bairro" -> '
            '${establishments.length} documento(s): '
            '${establishments.map((e) => '${e.name} (lat=${e.lat}, lng=${e.lng}, type=${e.type.name})').join(' | ')}',
          );
          return establishments;
        });
  }

  /// TODO(temporario): remover junto com o log acima. Le a colecao inteira
  /// sem nenhum filtro, para confirmar que os documentos sao visiveis pela
  /// conexao atual (descarta problema de regras do Firestore) e para
  /// comparar, byte a byte, o valor real salvo no campo `bairro` de cada
  /// documento com a string usada no filtro da query.
  Future<void> _debugDumpAllRaw() async {
    try {
      final snapshot = await _collection.get();
      debugPrint(
        '[EstablishmentService._debugDumpAllRaw] leitura sem filtro em '
        '"${_collection.path}": ${snapshot.docs.length} documento(s)',
      );
      for (final doc in snapshot.docs) {
        final rawBairro = doc.data()['bairro'];
        final asString = rawBairro is String ? rawBairro : null;
        debugPrint(
          '[EstablishmentService._debugDumpAllRaw] doc ${doc.id}: '
          'bairro="[$rawBairro]" runtimeType=${rawBairro.runtimeType} '
          'length=${asString?.length ?? 'N/A'} '
          'codeUnits=${asString?.codeUnits ?? 'N/A'}',
        );
      }
    } catch (e) {
      debugPrint('[EstablishmentService._debugDumpAllRaw] ERRO ao ler sem filtro: $e');
    }
  }

  Stream<Establishment?> watchById(String id) {
    return _collection.doc(id).snapshots().map(
      (doc) => doc.exists ? Establishment.fromFirestore(doc) : null,
    );
  }

  Future<String> create(Establishment establishment) async {
    final docRef = await _collection.add(establishment.toMap());
    return docRef.id;
  }

  CollectionReference<Map<String, dynamic>> _confirmations(String establishmentId) =>
      _collection.doc(establishmentId).collection('confirmations');

  /// Numero de confirmacoes distintas (1 por usuario, deduplicado pelo uid
  /// como id do documento) que um estabelecimento ja recebeu.
  Stream<int> watchConfirmationCount(String establishmentId) {
    return _confirmations(establishmentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Registra a confirmacao de um usuario de que o estabelecimento existe.
  ///
  /// Um documento por usuario (id = uid) evita que a mesma pessoa conte mais
  /// de uma vez. Ao atingir [kVerificationThreshold] confirmacoes distintas,
  /// marca o estabelecimento como `verified: true`.
  Future<void> confirmExistence({
    required String establishmentId,
    required String userId,
  }) async {
    await _confirmations(establishmentId).doc(userId).set({
      'confirmedAt': Timestamp.now(),
    });

    final countSnapshot = await _confirmations(establishmentId).count().get();
    if ((countSnapshot.count ?? 0) >= kVerificationThreshold) {
      await _collection.doc(establishmentId).update({'verified': true});
    }
  }
}
