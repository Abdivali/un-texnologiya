import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 4-bosqich: Nazariy material — qo'llanma matni bo'limlar ko'rinishida.
class TheoryScreen extends StatefulWidget {
  final LearningModule module;
  const TheoryScreen({super.key, required this.module});

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  final _scroll = ScrollController();
  double _fontSize = 15;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final done = appState.isStageDone(m.id, 'theory');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nazariy material'),
        actions: [
          IconButton(
            tooltip: 'Shriftni kichraytirish',
            icon: const Icon(Icons.text_decrease),
            onPressed: () => setState(
                () => _fontSize = (_fontSize - 1).clamp(12.0, 22.0)),
          ),
          IconButton(
            tooltip: 'Shriftni kattalashtirish',
            icon: const Icon(Icons.text_increase),
            onPressed: () => setState(
                () => _fontSize = (_fontSize + 1).clamp(12.0, 22.0)),
          ),
        ],
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            '${m.id}-modul',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            m.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 18),
          ...m.sections.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SectionCard(section: s, fontSize: _fontSize),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manba: ${appState.content?.source ?? ''}',
            style: const TextStyle(
                fontSize: 11.5, color: AppColors.textMuted, height: 1.4),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            icon: Icon(done ? Icons.check : Icons.done_all),
            label: Text(done ? 'O‘qildi deb belgilangan' : 'O‘qib bo‘ldim'),
            style: done
                ? FilledButton.styleFrom(backgroundColor: AppColors.success)
                : null,
            onPressed: done
                ? null
                : () async {
                    await appState.markStage(m.id, 'theory');
                    if (!context.mounted) return;
                    showToast(context, 'Nazariy material bajarildi');
                    Navigator.of(context).pop();
                  },
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final ContentSection section;
  final double fontSize;

  const _SectionCard({required this.section, required this.fontSize});

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final body = widget.section.body;
    final paragraphs = body
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.section.heading,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: paragraphs
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          p,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: widget.fontSize,
                            height: 1.6,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
