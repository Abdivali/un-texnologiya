import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'stage_router.dart';

/// 2-bosqich: Individual ta'lim traektoriyasi — modul va bosqichlar zanjiri.
class TrajectoryScreen extends StatelessWidget {
  const TrajectoryScreen({super.key});

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
    final path = s.trajectory;

    return Scaffold(
      appBar: AppBar(title: const Text('Individual traektoriya')),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: path.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) return const _Legend();
          final m = path[i - 1];
          return _TrajectoryNode(
            module: m,
            order: i,
            isLast: i == path.length,
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final s = appState;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Traektoriya diagnostika natijasi (${s.startLevel == 3 ? "yuqori" : s.startLevel == 2 ? "o‘rta" : "boshlang‘ich"} daraja) '
                    'va test natijalaringizga qarab avtomatik tuziladi.',
                    style: const TextStyle(fontSize: 12.5, height: 1.45),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: stageLabels.entries
                  .map(
                    (e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(stageIcon(e.key),
                            size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          e.value,
                          style: const TextStyle(
                              fontSize: 11.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrajectoryNode extends StatelessWidget {
  final LearningModule module;
  final int order;
  final bool isLast;

  const _TrajectoryNode({
    required this.module,
    required this.order,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final s = appState;
    final progress = s.moduleProgress(module);
    final done = progress >= 1.0;
    final started = progress > 0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(top: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done
                      ? AppColors.success
                      : (started ? AppColors.primary : AppColors.border),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check, size: 17, color: Colors.white)
                    : Text(
                        '$order',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: started ? Colors.white : AppColors.textMuted,
                        ),
                      ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: done ? AppColors.success : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.block,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${module.id}-modul. ${module.short}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: module.stageKeys.map((st) {
                          final ok = s.isStageDone(module.id, st);
                          return InkWell(
                            onTap: () => openStage(context, module, st),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: ok
                                    ? const Color(0xFFDCFCE7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    ok ? Icons.check_circle : stageIcon(st),
                                    size: 14,
                                    color: ok
                                        ? AppColors.success
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    stageLabels[st] ?? st,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: ok
                                          ? AppColors.success
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
