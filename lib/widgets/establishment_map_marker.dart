import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/establishment.dart';

/// Constroi os [Marker]s do Google Maps a partir de uma lista de
/// estabelecimentos, coloridos por tipo (balada x restaurante).
class EstablishmentMapMarkerFactory {
  const EstablishmentMapMarkerFactory({required this.onTap});

  final void Function(Establishment establishment) onTap;

  Set<Marker> build(List<Establishment> establishments) {
    return establishments.map((e) {
      // Switch exaustivo: ao adicionar um novo EstablishmentType, o
      // analisador aponta este `case` como faltando em vez de a cor cair
      // silenciosamente em "restaurante".
      final hue = switch (e.type) {
        EstablishmentType.balada => BitmapDescriptor.hueViolet,
        EstablishmentType.restaurante => BitmapDescriptor.hueOrange,
      };
      return Marker(
        markerId: MarkerId(e.id),
        position: LatLng(e.lat, e.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(title: e.name, snippet: e.genreOrCuisine),
        onTap: () => onTap(e),
      );
    }).toSet();
  }
}
