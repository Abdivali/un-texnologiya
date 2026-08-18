import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'home_shell.dart';
import 'module_detail_screen.dart';
import 'stage_router.dart';

/// Bosh sahifa (Dashboard): kunlik rejim, traektoriya holati,
/// bajarilgan modullar, ballar, eslatmalar va tavsiyalar.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
    final modules = s.content?.modules ?? const <LearningModule>[];
    final next = s.nextStep;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0x33FFFFFF),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.name.isEmpty ? 'Talaba' : s.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    s.group,
                    style: const TextStyle(
                        fontSize: 11.5, color: Color(0xFFBFD4F5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _TrajectoryCard(modules: modules),
          const SizedBox(height: 16),
          if (next != null) ...[
            const SectionTitle('Davom ettirish'),
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => openStage(context, next.key, next.value),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(stageIcon(next.value),
                            color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${next.key.id}-modul · ${stageLabels[next.value] ?? ''}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              next.key.short,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.play_circle_fill,
                          color: AppColors.primary, size: 30),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SectionTitle(
            'Yaqin vazifalar',
            trailing: TextButton(
              onPressed: () => HomeShell.goTo(context, 1),
              child: const Text('Barchasini ko‘rish'),
            ),
          ),
          ..._upcoming(s).map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TaskTile(module: e.key, stage: e.value),
            ),
          ),
          const SizedBox(height: 8),
          const SectionTitle('O‘zlashtirish dinamikasi'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 16, 14, 8),
              child: DynamicsChart(data: s.dynamics),
            ),
          ),
          const SizedBox(height: 16),
          if (s.weakModules.isNotEmpty) ...[
            const SectionTitle('Tavsiya — takrorlash zarur'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 18, color: AppColors.warning),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Quyidagi mavzularda natija 60 % dan past. Traektoriya ularni boshiga ko‘chirdi.',
                            style: TextStyle(fontSize: 12.5, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...s.weakModules.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ModuleDetailScreen(module: m),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_right,
                                  size: 18, color: AppColors.textMuted),
                              Expanded(
                                child: Text(
                                  '${m.id}-modul. ${m.short}',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Text(
                                '${(s.bestScore(m.id) ?? 0).round()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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
  }

  List<MapEntry<LearningModule, String>> _upcoming(AppState s) {
    final out = <MapEntry<LearningModule, String>>[];
    for (final m in s.trajectory) {
      for (final st in m.stageKeys) {
        if (!s.isStageDone(m.id, st)) {
          out.add(MapEntry(m, st));
          if (out.length >= 3) return out;
          break;
        }
      }
    }
    return out;
  }
}

class _TrajectoryCard extends StatelessWidget {
  final List<LearningModule> modules;
  const _TrajectoryCard({required this.modules});

  @override
  Widget build(BuildContext context) {
    final s = appState;
    final done = s.completedModules;
    final total = s.totalModules;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mening traektoriyam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ProgressRing(value: s.overallProgress),
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatTile(label: 'Modullar', value: '$total ta'),
                      StatTile(
                        label: 'Bajarilgan',
                        value: '$done ta',
                        color: AppColors.success,
                      ),
                      StatTile(
                        label: 'Qolgan',
                        value: '${total - done} ta',
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: s.overallProgress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ballar: ${s.totalPoints}',
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textMuted),
                ),
                Text(
                  s.startLevel == 3
                      ? 'Yuqori daraja'
                      : (s.startLevel == 2 ? 'O‘rta daraja' : 'Boshlang‘ich daraja'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final LearningModule module;
  final String stage;

  const _TaskTile({required this.module, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(stageIcon(stage), color: AppColors.primary),
        title: Text(
          '${module.id}-modul. ${module.short}',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          stageLabels[stage] ?? stage,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
        onTap: () => openStage(context, module, stage),
      ),
    );
  }
}
