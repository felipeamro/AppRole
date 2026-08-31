import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/establishment.dart';
import '../services/establishment_service.dart';
import '../widgets/establishment_map_marker.dart';
import '../widgets/trocar_bairro_action.dart';
import 'establishment_detail_screen.dart';

/// Tela inicial: mapa do bairro escolhido com pins dos estabelecimentos
/// reportados pela comunidade (baladas e restaurantes).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.bairro});

  final String bairro;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _establishmentService = EstablishmentService();

  // Posicao inicial generica; em producao, usar geolocalizacao do usuario
  // ou o centroide do bairro selecionado.
  static const _defaultCenter = LatLng(-23.5613, -46.6565);

  void _openDetail(Establishment establishment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstablishmentDetailScreen(establishmentId: establishment.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markerFactory = EstablishmentMapMarkerFactory(onTap: _openDetail);

    return Scaffold(
      appBar: AppBar(
        title: Text('iVibe · ${widget.bairro}'),
        actions: [TrocarBairroChip(bairroAtual: widget.bairro)],
      ),
      body: StreamBuilder<List<Establishment>>(
        stream: _establishmentService.watchByBairro(widget.bairro),
        builder: (context, snapshot) {
          final establishments = snapshot.data ?? const [];

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _defaultCenter,
                  zoom: 14,
                ),
                markers: markerFactory.build(establishments),
                myLocationButtonEnabled: false,
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
