import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 9-bosqich: Natijalar — bajarilgan ishlar, ballar, o'zlashtirish darajasi,
/// mavzular bo'yicha tahlil va saqlangan laboratoriya protokollari.
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = appState;
    final modules = s.content?.modules ?? const <LearningModule>[];
    final tested = modules.where((m) => s.bestScore(m.id) != null).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Natijalar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatTile(
                    label: 'Umumiy o‘zlashtirish',
                    value: '${(s.overallProgress * 100).round()}%',
                    color: AppColors.primary,
                  ),
                  StatTile(
                    label: 'Bajarilgan modul',
                    value: '${s.completedModules}',
                    color: AppColors.success,
                  ),
                  StatTile(
                    label: 'Jami ball',
                    value: '${s.totalPoints}',
                    color: AppColors.navy,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('O‘zlashtirish dinamikasi'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 14, 8),
              child: DynamicsChart(data: s.dynamics),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Mavzular bo‘yicha tahlil'),
          if (tested.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Hali birorta test topshirilmagan.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: tested.map((m) {
                    final best = s.bestScore(m.id)!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${m.id}. ${m.short}',
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.35),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${best.round()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: best >= 60
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: best / 100,
                              minHeight: 6,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                best >= 60
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const SectionTitle('Saqlangan laboratoriya protokollari'),
          if (s.protocols.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Hali protokol saqlanmagan.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            ...s.protocols.map((p) {
              final m = s.content?.moduleById(p.moduleId);
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    leading: const Icon(Icons.assignment_turned_in_outlined,
                        color: AppColors.primary),
                    title: Text(
                      m?.protocol?.title ?? 'Protokol',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${m?.short ?? ''} · ${p.date}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${p.result.toStringAsFixed(2)} ${m?.protocol?.resultUnit ?? ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),
          const SectionTitle('Urinishlar tarixi'),
          if (s.attempts.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Tarix bo‘sh.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
            )
          else
            Card(
              child: Column(
                children: s.attempts.reversed.take(20).map((a) {
                  final m = s.content?.moduleById(a.moduleId);
                  const kindNames = {
                    'test': 'Test',
                    'vlab': 'Virtual laboratoriya',
                    'interactive': 'Interaktiv topshiriq',
                    'diagnostic': 'Diagnostika',
                  };
                  return ListTile(
                    dense: true,
                    leading: Icon(
                      a.percent >= 60
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 20,
                      color: a.percent >= 60
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                    title: Text(
                      '${kindNames[a.kind] ?? a.kind}${m == null ? '' : ' · ${m.id}-modul'}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    subtitle: Text(
                      a.date,
                      style: const TextStyle(
                          fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    trailing: Text(
                      '${a.score}/${a.total}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
