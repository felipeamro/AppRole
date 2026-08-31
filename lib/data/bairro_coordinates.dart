import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Coordenadas centrais aproximadas de cada bairro suportado pelo
/// Onboarding, usadas para centralizar o mapa no bairro escolhido pelo
/// usuario (em vez de um ponto fixo).
const Map<String, LatLng> bairroCoordinates = {
  'São Bernardo do Campo': LatLng(-23.6939, -46.5650),
  'Santo André': LatLng(-23.6639, -46.5383),
  'São Caetano do Sul': LatLng(-23.6229, -46.5546),
  'Moema': LatLng(-23.6014, -46.6642),
  'Vila Olímpia': LatLng(-23.5955, -46.6890),
  'Itaim Bibi': LatLng(-23.5820, -46.6739),
  'Pinheiros': LatLng(-23.5629, -46.6822),
  'Vila Madalena': LatLng(-23.5558, -46.6913),
  'Copacabana': LatLng(-22.9711, -43.1822),
  'Ipanema': LatLng(-22.9838, -43.2096),
};

/// Fallback caso o bairro nao esteja no mapa acima (centro da cidade de
/// Sao Paulo).
const LatLng defaultMapCenter = LatLng(-23.5505, -46.6333);

LatLng centerForBairro(String bairro) => bairroCoordinates[bairro] ?? defaultMapCenter;
