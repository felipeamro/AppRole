import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../data/bairro_coordinates.dart';
import '../models/establishment.dart';
import '../services/auth_service.dart';
import '../services/establishment_service.dart';
import '../widgets/add_establishment_sheet.dart';
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
  final _authService = AuthService();

  late LatLng _cameraCenter = centerForBairro(widget.bairro);
  LatLng? _pendingLocation;

  void _openDetail(Establishment establishment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EstablishmentDetailScreen(establishmentId: establishment.id),
      ),
    );
  }

  void _handleMapTap(LatLng position) {
    setState(() => _pendingLocation = position);
  }

  Future<void> _openAddEstablishmentSheet() async {
    final location = _pendingLocation ?? _cameraCenter;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddEstablishmentSheet(
        location: location,
        onSubmit: ({
          required name,
          required type,
          required genreOrCuisine,
          required priceRange,
        }) => _createEstablishment(
          location: location,
          name: name,
          type: type,
          genreOrCuisine: genreOrCuisine,
          priceRange: priceRange,
        ),
      ),
    );
  }

  Future<void> _createEstablishment({
    required LatLng location,
    required String name,
    required EstablishmentType type,
    required String genreOrCuisine,
    required int priceRange,
  }) async {
    final user = await _authService.ensureSignedIn();
    await _establishmentService.create(
      Establishment(
        id: '',
        name: name,
        type: type,
        lat: location.latitude,
        lng: location.longitude,
        bairro: widget.bairro,
        genreOrCuisine: genreOrCuisine,
        priceRange: priceRange,
        createdBy: user.uid,
        verified: false,
      ),
    );

    if (!mounted) return;
    setState(() => _pendingLocation = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local adicionado! Aguardando confirmações da comunidade.')),
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
          final markers = markerFactory.build(establishments);
          if (_pendingLocation != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('pending-location'),
                position: _pendingLocation!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: const InfoWindow(title: 'Novo local'),
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _cameraCenter,
                  zoom: 14,
                ),
                markers: markers,
                onTap: _handleMapTap,
                onCameraMove: (position) => _cameraCenter = position.target,
                myLocationButtonEnabled: false,
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (snapshot.hasError)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Não foi possível carregar os estabelecimentos: '
                        '${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_pendingLocation == null)
                const Positioned(
                  bottom: 88,
                  left: 16,
                  right: 16,
                  child: _AddLocationHint(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddEstablishmentSheet,
        tooltip: 'Adicionar local',
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Dica exibida sobre o mapa lembrando que e possivel tocar para marcar a
/// localizacao exata do novo estabelecimento antes de usar o botao "+".
class _AddLocationHint extends StatelessWidget {
  const _AddLocationHint();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          'Toque no mapa para marcar onde fica o novo local, ou use o botão '
          '"+" para adicionar na posição atual do mapa.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
