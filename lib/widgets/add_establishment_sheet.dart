import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/establishment.dart';

/// Formulario (usado em um bottom sheet) para cadastrar um novo
/// estabelecimento na localizacao ja escolhida no mapa.
class AddEstablishmentSheet extends StatefulWidget {
  const AddEstablishmentSheet({
    super.key,
    required this.location,
    required this.onSubmit,
  });

  final LatLng location;
  final void Function({
    required String name,
    required EstablishmentType type,
    required String genreOrCuisine,
    required int priceRange,
  })
  onSubmit;

  @override
  State<AddEstablishmentSheet> createState() => _AddEstablishmentSheetState();
}

class _AddEstablishmentSheetState extends State<AddEstablishmentSheet> {
  final _nameController = TextEditingController();
  final _genreController = TextEditingController();
  EstablishmentType _type = EstablishmentType.restaurante;
  int _priceRange = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adicionar local', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Localização: ${widget.location.latitude.toStringAsFixed(5)}, '
            '${widget.location.longitude.toStringAsFixed(5)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            // Gerado a partir de EstablishmentType.values: um novo tipo no
            // enum aparece aqui automaticamente, sem editar este arquivo.
            children: [
              for (final type in EstablishmentType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _type == type,
                  onSelected: (_) => setState(() => _type = type),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _genreController,
            decoration: const InputDecoration(
              labelText: 'Gênero/Culinária',
              hintText: 'Ex: japonesa, eletrônica, hamburgueria...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('Faixa de preço', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (var price = 1; price <= 4; price++)
                ChoiceChip(
                  label: Text('\$' * price),
                  selected: _priceRange == price,
                  onSelected: (_) => setState(() => _priceRange = price),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                widget.onSubmit(
                  name: name,
                  type: _type,
                  genreOrCuisine: _genreController.text.trim(),
                  priceRange: _priceRange,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Salvar local'),
            ),
          ),
        ],
      ),
    );
  }
}
