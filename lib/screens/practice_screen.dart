import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/image_view.dart';

/// Amaliy mashg'ulot — laboratoriyada qo'lda bajariladigan ish.
/// Talaba har bir bosqichni bajarib belgilaydi; progress saqlanadi.
class PracticeScreen extends StatefulWidget {
  final LearningModule module;
  const PracticeScreen({super.key, required this.module});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final Set<int> _doneSteps = <int>{};
  bool _safetyRead = false;

  PracticeSession get p => widget.module.practice!;

  double get _progress =>
      p.steps.isEmpty ? 0 : _doneSteps.length / p.steps.length;

  Future<void> _finish() async {
    await appState.addAttempt(AttemptResult(
      moduleId: widget.module.id,
      kind: 'practice',
      score: _doneSteps.length,
      total: p.steps.length,
      date: AppState.today(),
      seconds: 0,
    ));
    await appState.markStage(widget.module.id, 'practice');
    if (!mounted) return;
    showToast(context, 'Amaliy mashg‘ulot bajarildi');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.module.practice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Amaliy mashg‘ulot')),
        body: const Center(
          child: Text('Bu modul uchun amaliy mashg‘ulot mavjud emas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Amaliy mashg‘ulot')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _header(),
                const SizedBox(height: 14),
                _equipment(),
                const SizedBox(height: 14),
                _safety(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: SectionTitle('Bajarish tartibi'),
                    ),
                    Text(
                      '${_doneSteps.length} / ${p.steps.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                for (var i = 0; i < p.steps.length; i++)
                  _StepCard(
                    index: i,
                    step: p.steps[i],
                    done: _doneSteps.contains(i),
                    enabled: _safetyRead,
                    onToggle: () => setState(() {
                      if (!_doneSteps.remove(i)) _doneSteps.add(i);
                    }),
                  ),
                const SizedBox(height: 8),
                _listCard(
                  icon: Icons.edit_note,
                  title: 'Ish daftariga qayd etiladi',
                  items: p.record,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 14),
                _listCard(
                  icon: Icons.checklist_rtl,
                  title: 'Baholash mezonlari',
                  items: p.criteria,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.task_alt),
                label: Text(
                  _doneSteps.length == p.steps.length
                      ? 'Mashg‘ulotni yakunlash'
                      : 'Barcha bosqichni belgilang (${_doneSteps.length}/${p.steps.length})',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _doneSteps.length == p.steps.length
                      ? AppColors.success
                      : AppColors.primary,
                ),
                onPressed:
                    _doneSteps.length == p.steps.length ? _finish : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.biotech_outlined,
                    color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.module.id}-modul · ${widget.module.short}',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ishdan maqsad',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 3),
            Text(
              p.goal,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
            if (p.duration.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule,
                      size: 15, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    p.duration,
                    style: const TextStyle(
                        fontSize: 12.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _equipment() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.handyman_outlined,
                    size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Kerakli asbob-uskunalar',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...p.equipment.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.check_box_outline_blank,
                          size: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.module.images
                .any((im) => im.role == 'equip')) ...[
              const SizedBox(height: 6),
              ModuleGallery(
                images: widget.module.images
                    .where((im) => im.role == 'equip')
                    .toList(),
                title: 'Asbob-uskunalar',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _safety() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 19, color: Color(0xFFB45309)),
              SizedBox(width: 8),
              Text(
                'Xavfsizlik qoidalari',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...p.safety.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFF92400E))),
                  Expanded(
                    child: Text(
                      e,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: Color(0xFF78350F)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _safetyRead = !_safetyRead),
            child: Row(
              children: [
                Icon(
                  _safetyRead
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  size: 20,
                  color: const Color(0xFFB45309),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Xavfsizlik qoidalari bilan tanishdim',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _listCard({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...items.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('— ', style: TextStyle(fontSize: 13, color: color)),
                    Expanded(
                      child: Text(
                        e,
                        style: const TextStyle(fontSize: 13, height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int index;
  final PracticeStep step;
  final bool done;
  final bool enabled;
  final VoidCallback onToggle;

  const _StepCard({
    required this.index,
    required this.step,
    required this.done,
    required this.enabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done ? const Color(0xFFBBF7D0) : AppColors.border,
            width: done ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: done
                        ? const Icon(Icons.check,
                            size: 16, color: AppColors.success)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 9, 14, 0),
              child: Text(
                step.description,
                style: const TextStyle(fontSize: 13.5, height: 1.55),
              ),
            ),
            if (step.image != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: CaptionedImage(
                  src: step.image!,
                  caption: '',
                  badge: '${index + 1}-bosqich',
                  maxHeight: 210,
                ),
              ),
            if (step.tip.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          step.tip,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.45,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            InkWell(
              onTap: enabled ? onToggle : null,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: done
                      ? const Color(0xFFF0FDF4)
                      : (enabled
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF8FAFC)),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 17,
                      color: done
                          ? AppColors.success
                          : (enabled
                              ? AppColors.textMuted
                              : const Color(0xFFCBD5E1)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      done
                          ? 'Bajarildi'
                          : (enabled
                              ? 'Bajardim deb belgilash'
                              : 'Avval xavfsizlik qoidalarini o‘qing'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: done
                            ? AppColors.success
                            : (enabled
                                ? AppColors.textMuted
                                : const Color(0xFFCBD5E1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
