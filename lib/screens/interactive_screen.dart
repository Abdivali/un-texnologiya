import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 5-bosqich: Interaktiv topshiriqlar — ketma-ketlikni tiklash va
/// to'g'ri/noto'g'ri tasdiqlar.
class InteractiveScreen extends StatefulWidget {
  final LearningModule module;
  const InteractiveScreen({super.key, required this.module});

  @override
  State<InteractiveScreen> createState() => _InteractiveScreenState();
}

class _InteractiveScreenState extends State<InteractiveScreen> {
  late List<String> _order;
  late List<String> _correctOrder;
  bool _orderChecked = false;

  final Map<int, bool> _tfAnswers = {};
  bool _tfChecked = false;

  InteractiveTask? get _orderTask {
    for (final t in widget.module.interactive) {
      if (t.type == 'order') return t;
    }
    return null;
  }

  InteractiveTask? get _tfTask {
    for (final t in widget.module.interactive) {
      if (t.type == 'tf') return t;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _correctOrder = List<String>.from(_orderTask?.orderItems ?? const []);
    _order = List<String>.from(_correctOrder);
    // Har bir modul uchun barqaror aralashtirish
    _order.shuffle(math.Random(widget.module.id * 7919));
    if (_order.length > 1 && _order[0] == _correctOrder[0]) {
      final tmp = _order[0];
      _order[0] = _order[_order.length - 1];
      _order[_order.length - 1] = tmp;
    }
  }

  int get _orderScore {
    var c = 0;
    for (var i = 0; i < _order.length; i++) {
      if (_order[i] == _correctOrder[i]) c++;
    }
    return c;
  }

  int get _tfScore {
    final items = _tfTask?.tfItems ?? const <TfItem>[];
    var c = 0;
    for (var i = 0; i < items.length; i++) {
      if (_tfAnswers[i] == items[i].answer) c++;
    }
    return c;
  }

  Future<void> _finish() async {
    final total = _correctOrder.length + (_tfTask?.tfItems.length ?? 0);
    final score = _orderScore + _tfScore;
    await appState.addAttempt(AttemptResult(
      moduleId: widget.module.id,
      kind: 'interactive',
      score: score,
      total: total,
      date: AppState.today(),
      seconds: 0,
    ));
    await appState.markStage(widget.module.id, 'interactive');
    if (!mounted) return;
    showToast(context, 'Topshiriq bajarildi: $score / $total');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tf = _tfTask;
    final allAnswered = tf == null ||
        _tfAnswers.length == tf.tfItems.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Interaktiv topshiriq')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_orderTask != null) ...[
            _TaskHeader(
              icon: Icons.reorder,
              title: _orderTask!.title,
              prompt: _orderTask!.prompt,
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ReorderableListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  buildDefaultDragHandles: !_orderChecked,
                  onReorder: (oldIndex, newIndex) {
                    if (_orderChecked) return;
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final item = _order.removeAt(oldIndex);
                      _order.insert(newIndex, item);
                    });
                  },
                  children: [
                    for (var i = 0; i < _order.length; i++)
                      _OrderTile(
                        key: ValueKey(_order[i]),
                        index: i,
                        text: _order[i],
                        checked: _orderChecked,
                        correct: _orderChecked && _order[i] == _correctOrder[i],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (!_orderChecked)
              OutlinedButton.icon(
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Tartibni tekshirish'),
                onPressed: () => setState(() => _orderChecked = true),
              )
            else
              _ResultBanner(
                text:
                    'Ketma-ketlik: $_orderScore / ${_correctOrder.length} to‘g‘ri',
                ok: _orderScore == _correctOrder.length,
              ),
            const SizedBox(height: 22),
          ],
          if (tf != null) ...[
            _TaskHeader(
              icon: Icons.rule,
              title: tf.title,
              prompt: tf.prompt,
            ),
            const SizedBox(height: 10),
            ...List.generate(tf.tfItems.length, (i) {
              final item = tf.tfItems[i];
              final given = _tfAnswers[i];
              final isCorrect = _tfChecked && given == item.answer;
              final isWrong = _tfChecked && given != null && given != item.answer;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_tfChecked)
                              Padding(
                                padding: const EdgeInsets.only(right: 8, top: 2),
                                child: Icon(
                                  isCorrect ? Icons.check_circle : Icons.cancel,
                                  size: 17,
                                  color: isCorrect
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                              ),
                            Expanded(
                              child: Text(
                                item.text,
                                style: const TextStyle(
                                    fontSize: 13.5, height: 1.45),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _TfButton(
                                label: 'To‘g‘ri',
                                selected: given == true,
                                enabled: !_tfChecked,
                                onTap: () =>
                                    setState(() => _tfAnswers[i] = true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _TfButton(
                                label: 'Noto‘g‘ri',
                                selected: given == false,
                                enabled: !_tfChecked,
                                onTap: () =>
                                    setState(() => _tfAnswers[i] = false),
                              ),
                            ),
                          ],
                        ),
                        if (isWrong) ...[
                          const SizedBox(height: 8),
                          Text(
                            'To‘g‘ri javob: ${item.answer ? "To‘g‘ri" : "Noto‘g‘ri"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (!_tfChecked)
              OutlinedButton.icon(
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Javoblarni tekshirish'),
                onPressed: allAnswered
                    ? () => setState(() => _tfChecked = true)
                    : null,
              )
            else
              _ResultBanner(
                text: 'Tasdiqlar: $_tfScore / ${tf.tfItems.length} to‘g‘ri',
                ok: _tfScore == tf.tfItems.length,
              ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: (_orderChecked && (tf == null || _tfChecked))
                ? _finish
                : null,
            child: const Text('Yakunlash va saqlash'),
          ),
        ),
      ),
    );
  }
}

class _TaskHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String prompt;

  const _TaskHeader({
    required this.icon,
    required this.title,
    required this.prompt,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                prompt,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderTile extends StatelessWidget {
  final int index;
  final String text;
  final bool checked;
  final bool correct;

  const _OrderTile({
    super.key,
    required this.index,
    required this.text,
    required this.checked,
    required this.correct,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: checked
              ? (correct ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2))
              : const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(9),
        ),
        child: checked
            ? Icon(
                correct ? Icons.check : Icons.close,
                size: 16,
                color: correct ? AppColors.success : AppColors.danger,
              )
            : Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
      ),
      title: Text(
        text,
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
      trailing: checked
          ? null
          : const Icon(Icons.drag_handle, color: AppColors.textMuted, size: 20),
    );
  }
}

class _TfButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _TfButton({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final String text;
  final bool ok;

  const _ResultBanner({required this.text, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.verified : Icons.info_outline,
            size: 18,
            color: ok ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
