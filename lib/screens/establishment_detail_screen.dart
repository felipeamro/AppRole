import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/establishment.dart';
import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/establishment_service.dart';
import '../services/report_service.dart';
import '../services/user_service.dart';
import '../widgets/report_type_selector.dart';

/// Detalhe de um estabelecimento: informacoes basicas, reports recentes da
/// comunidade e o botao para enviar um novo report.
class EstablishmentDetailScreen extends StatefulWidget {
  const EstablishmentDetailScreen({super.key, required this.establishmentId});

  final String establishmentId;

  @override
  State<EstablishmentDetailScreen> createState() => _EstablishmentDetailScreenState();
}

class _EstablishmentDetailScreenState extends State<EstablishmentDetailScreen> {
  final _establishmentService = EstablishmentService();
  final _reportService = ReportService();
  final _authService = AuthService();
  final _userService = UserService();

  static const _reportTypeLabels = {
    ReportType.lotacao: 'Lotação',
    ReportType.fila: 'Fila',
    ReportType.preco: 'Preço',
    ReportType.vibe: 'Vibe',
    ReportType.promocao: 'Promoção',
  };

  Future<void> _openReportSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportTypeSelector(onSubmit: _submitReport),
    );
  }

  Future<void> _submitReport(ReportType type, String value) async {
    final user = await _authService.ensureSignedIn();
    await _reportService.create(
      establishmentId: widget.establishmentId,
      userId: user.uid,
      type: type,
      value: value,
    );
    // Recompensa simples por contribuir com a comunidade.
    await _userService.addPoints(user.uid, 5);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report enviado! +5 pontos')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<Establishment?>(
        stream: _establishmentService.watchById(widget.establishmentId),
        builder: (context, snapshot) {
          final establishment = snapshot.data;
          if (establishment == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(establishment.name),
                pinned: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _EstablishmentInfo(establishment: establishment),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _openReportSheet,
                      icon: const Icon(Icons.campaign),
                      label: const Text('Reportar'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Reports recentes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _RecentReportsList(
                      establishmentId: establishment.id,
                      reportService: _reportService,
                      labels: _reportTypeLabels,
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EstablishmentInfo extends StatelessWidget {
  const _EstablishmentInfo({required this.establishment});

  final Establishment establishment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  label: Text(
                    establishment.type == EstablishmentType.balada
                        ? 'Balada'
                        : 'Restaurante',
                  ),
                ),
                const SizedBox(width: 8),
                if (establishment.verified)
                  const Chip(
                    avatar: Icon(Icons.verified, size: 16),
                    label: Text('Verificado'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Bairro: ${establishment.bairro}'),
            Text('Gênero/Cozinha: ${establishment.genreOrCuisine}'),
            Text('Faixa de preço: ${'\$' * establishment.priceRange}'),
          ],
        ),
      ),
    );
  }
}

class _RecentReportsList extends StatelessWidget {
  const _RecentReportsList({
    required this.establishmentId,
    required this.reportService,
    required this.labels,
  });

  final String establishmentId;
  final ReportService reportService;
  final Map<ReportType, String> labels;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Report>>(
      stream: reportService.watchByEstablishment(establishmentId),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? const [];
        if (reports.isEmpty) {
          return const Text('Nenhum report ainda. Seja o primeiro!');
        }

        return Column(
          children: reports.map((report) {
            return ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: Text('${labels[report.type]}: ${report.value}'),
              subtitle: Text(DateFormat('dd/MM HH:mm').format(report.createdAt)),
              trailing: TextButton.icon(
                onPressed: () => reportService.confirm(report.id),
                icon: const Icon(Icons.thumb_up_outlined, size: 18),
                label: Text('${report.confirmations}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
