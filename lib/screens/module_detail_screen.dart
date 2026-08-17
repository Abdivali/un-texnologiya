import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'stage_router.dart';

/// Modul tarkibi — nazariy material, interaktiv topshiriq, virtual laboratoriya,
/// laboratoriya ishi va test bosqichlari.
class ModuleDetailScreen extends StatelessWidget {
  final LearningModule module;
  const ModuleDetailScreen({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final s = appState;
        final progress = s.moduleProgress(module);
        final best = s.bestScore(module.id);

        return Scaffold(
          appBar: AppBar(title: Text('${module.id}-modul')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.block,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 7,
                                backgroundColor: AppColors.border,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1
                                      ? AppColors.success
                                      : AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(progress * 100).round()}%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      if (best != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              best >= 60
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              size: 16,
                              color: best >= 60
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Eng yaxshi test natijasi: ${best.round()}%',
                              style: const TextStyle(
                                  fontSize: 12.5, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const SectionTitle('Modul bosqichlari'),
              ...module.stageKeys.map(
                (st) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StageTile(module: module, stage: st),
                ),
              ),
              if (module.control.isNotEmpty) ...[
                const SizedBox(height: 8),
                const SectionTitle('Nazorat savollari'),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < module.control.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${i + 1}.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    module.control[i],
                                    style: const TextStyle(
                                        fontSize: 13.5, height: 1.45),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StageTile extends StatelessWidget {
  final LearningModule module;
  final String stage;

  const _StageTile({required this.module, required this.stage});

  String _subtitle() {
    switch (stage) {
      case 'theory':
        return '${module.sections.length} ta bo‘lim · qo‘llanma matni';
      case 'interactive':
        return '${module.interactive.length} ta topshiriq';
      case 'vlab':
        return '${module.vlab?.taskCount ?? 0} ta bosqich · simulyatsiya';
      case 'protocol':
        return module.protocol?.title ?? 'Protokol';
      case 'test':
        return '${module.tests.length} ta savol';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = appState.isStageDone(module.id, stage);
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            done ? Icons.check : stageIcon(stage),
            color: done ? AppColors.success : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          stageLabels[stage] ?? stage,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _subtitle(),
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => openStage(context, module, stage),
      ),
    );
  }
}
