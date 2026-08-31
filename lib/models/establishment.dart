import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipo de estabelecimento.
///
/// NOTA: hoje so existem `balada` e `restaurante`, mas ha planos de
/// adicionar um terceiro tipo para locais hibridos (ex: bar com musica ao
/// vivo). Por isso, todo lugar que precisa de um rotulo/cor por tipo usa um
/// `switch` exaustivo sobre este enum (aqui e em establishment_map_marker.dart)
/// em vez de comparacoes booleanas com `== EstablishmentType.balada` - assim,
/// adicionar um novo valor faz o analisador apontar exatamente onde
/// atualizar, em vez de cair silenciosamente no caso "restaurante".
enum EstablishmentType {
  balada,
  restaurante;

  static EstablishmentType fromValue(String? value) {
    return EstablishmentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EstablishmentType.restaurante,
    );
  }

  String get label => switch (this) {
    EstablishmentType.balada => 'Balada',
    EstablishmentType.restaurante => 'Restaurante',
  };
}

/// Documento da colecao `establishments`.
class Establishment {
  final String id;
  final String name;
  final EstablishmentType type;
  final double lat;
  final double lng;
  final String bairro;
  final String genreOrCuisine;
  final int priceRange;
  final String createdBy;
  final bool verified;

  const Establishment({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lng,
    required this.bairro,
    required this.genreOrCuisine,
    required this.priceRange,
    required this.createdBy,
    this.verified = false,
  });

  factory Establishment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    return Establishment(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: EstablishmentType.fromValue(data['type'] as String?),
      lat: (data['lat'] as num?)?.toDouble() ?? 0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0,
      bairro: data['bairro'] as String? ?? '',
      genreOrCuisine: data['genreOrCuisine'] as String? ?? '',
      priceRange: (data['priceRange'] as num?)?.toInt() ?? 1,
      createdBy: data['createdBy'] as String? ?? '',
      verified: data['verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type.name,
      'lat': lat,
      'lng': lng,
      'bairro': bairro,
      'genreOrCuisine': genreOrCuisine,
      'priceRange': priceRange,
      'createdBy': createdBy,
      'verified': verified,
    };
  }
}
