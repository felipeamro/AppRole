import 'package:flutter/material.dart';

import '../models/report.dart';

/// Formulario (usado em um bottom sheet) para o usuario enviar um report
/// sobre um estabelecimento: escolhe o tipo e descreve o valor observado.
class ReportTypeSelector extends StatefulWidget {
  const ReportTypeSelector({super.key, required this.onSubmit});

  final void Function(ReportType type, String value) onSubmit;

  @override
  State<ReportTypeSelector> createState() => _ReportTypeSelectorState();
}

class _ReportTypeSelectorState extends State<ReportTypeSelector> {
  ReportType _selectedType = ReportType.vibe;
  final _valueController = TextEditingController();

  static const _labels = {
    ReportType.lotacao: 'Lotação',
    ReportType.fila: 'Fila',
    ReportType.preco: 'Preço',
    ReportType.vibe: 'Vibe',
    ReportType.promocao: 'Promoção',
  };

  static const _icons = {
    ReportType.lotacao: Icons.groups,
    ReportType.fila: Icons.timer,
    ReportType.preco: Icons.attach_money,
    ReportType.vibe: Icons.mood,
    ReportType.promocao: Icons.local_offer,
  };

  @override
  void dispose() {
    _valueController.dispose();
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
          Text('Reportar', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ReportType.values.map((type) {
              final selected = type == _selectedType;
              return ChoiceChip(
                avatar: Icon(_icons[type], size: 18),
                label: Text(_labels[type]!),
                selected: selected,
                onSelected: (_) => setState(() => _selectedType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(
              labelText: 'O que você observou?',
              hintText: 'Ex: cheio, fila de 20min, R\$ 40 a entrada...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final value = _valueController.text.trim();
                if (value.isEmpty) return;
                widget.onSubmit(_selectedType, value);
                Navigator.of(context).pop();
              },
              child: const Text('Enviar report'),
            ),
          ),
        ],
      ),
    );
  }
}
