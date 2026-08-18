import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import 'module_detail_screen.dart';

/// 3-bosqich: Modullar (fan mazmuni) — qo'llanma asosidagi 15 ta laboratoriya ishi.
class ModulesScreen extends StatefulWidget {
  const ModulesScreen({super.key});

  @override
  State<ModulesScreen> createState() => _ModulesScreenState();
}

class _ModulesScreenState extends State<ModulesScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    // Holat o'zgarganda ekran darhol qayta chiziladi (real-time yangilanish).
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final s = appState;
    final all = s.content?.modules ?? const <LearningModule>[];
    final filtered = _query.trim().isEmpty
        ? all
        : all
            .where((m) =>
                m.title.toLowerCase().contains(_query.toLowerCase()) ||
                m.short.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    // Bloklar bo'yicha guruhlash
    final blocks = <String, List<LearningModule>>{};
    for (final m in filtered) {
      blocks.putIfAbsent(m.block, () => <LearningModule>[]).add(m);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fan modullari')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Mavzu bo‘yicha qidirish...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: blocks.entries.expand((entry) {
                return [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                    child: Text(
                      entry.key.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  ...entry.value.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ModuleCard(module: m),
                    ),
                  ),
                ];
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final LearningModule module;
  const _ModuleCard({required this.module});

  @override
  Widget build(BuildContext context) {
    final s = appState;
    final progress = s.moduleProgress(module);
    final best = s.bestScore(module.id);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ModuleDetailScreen(module: module),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: progress >= 1
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: progress >= 1
                    ? const Icon(Icons.check, color: AppColors.success)
                    : Text(
                        '${module.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.short,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1 ? AppColors.success : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _Chip(
                          icon: Icons.menu_book_outlined,
                          text: '${module.sections.length} bo‘lim',
                        ),
                        const SizedBox(width: 8),
                        _Chip(
                          icon: Icons.quiz_outlined,
                          text: '${module.tests.length} test',
                        ),
                        if (module.images.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _Chip(
                            icon: Icons.image_outlined,
                            text: '${module.images.length}',
                          ),
                        ],
                        if (best != null) ...[
                          const SizedBox(width: 8),
                          _Chip(
                            icon: Icons.star_outline,
                            text: '${best.round()}%',
                            color: best >= 60
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Chip({
    required this.icon,
    required this.text,
    this.color = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(text, style: TextStyle(fontSize: 11.5, color: color)),
      ],
    );
  }
}
