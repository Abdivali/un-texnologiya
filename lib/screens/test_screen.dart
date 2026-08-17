import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 8-bosqich: Test — mavzu yakuniy nazorati, natija traektoriyaga ta'sir qiladi.
class TestScreen extends StatefulWidget {
  final LearningModule module;
  const TestScreen({super.key, required this.module});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _index = 0;
  final Map<int, int> _answers = {};
  bool _finished = false;
  int _score = 0;
  late final DateTime _start;

  List<TestQuestion> get _qs => widget.module.tests;

  @override
  void initState() {
    super.initState();
    _start = DateTime.now();
  }

  Future<void> _finish() async {
    var score = 0;
    for (var i = 0; i < _qs.length; i++) {
      if (_answers[i] == _qs[i].answer) score++;
    }
    final secs = DateTime.now().difference(_start).inSeconds;
    await appState.addAttempt(AttemptResult(
      moduleId: widget.module.id,
      kind: 'test',
      score: score,
      total: _qs.length,
      date: AppState.today(),
      seconds: secs,
    ));
    await appState.markStage(widget.module.id, 'test');
    if (!mounted) return;
    setState(() {
      _score = score;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_qs.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(child: Text('Bu modulda test savollari yo‘q')),
      );
    }
    if (_finished) return _buildResult();

    final q = _qs[_index];
    final selected = _answers[_index];

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.module.id}-modul testi'),
      ),
      body: Column(
        children: [
            LinearProgressIndicator(
              value: (_index + 1) / _qs.length,
              minHeight: 4,
              backgroundColor: AppColors.border,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_index + 1} / ${_qs.length}-savol',
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                        Text(
                          'Javob berilgan: ${_answers.length}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      q.question,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (var i = 0; i < q.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OptionTile(
                          label: String.fromCharCode(65 + i),
                          text: q.options[i],
                          selected: selected == i,
                          onTap: () => setState(() => _answers[_index] = i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_index > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _index--),
                          child: const Text('Orqaga'),
                        ),
                      ),
                    if (_index > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: selected == null
                            ? null
                            : () {
                                if (_index == _qs.length - 1) {
                                  _finish();
                                } else {
                                  setState(() => _index++);
                                }
                              },
                        child: Text(_index == _qs.length - 1
                            ? 'Testni yakunlash'
                            : 'Keyingisi'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResult() {
    final pct = (_score * 100 / _qs.length).round();
    final passed = pct >= 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test natijasi'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ProgressRing(value: _score / _qs.length, size: 110),
                  const SizedBox(height: 14),
                  Text(
                    '$_score / ${_qs.length} to‘g‘ri javob',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    passed
                        ? 'Mavzu o‘zlashtirildi. Traektoriyadagi keyingi modulga o‘tishingiz mumkin.'
                        : 'Natija 60 % dan past. Bu modul traektoriya boshiga ko‘chiriladi — nazariyani qayta ko‘rib chiqing.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: passed ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Javoblar tahlili'),
          for (var i = 0; i < _qs.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Review(
                index: i,
                q: _qs[i],
                given: _answers[i],
              ),
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Modulga qaytish'),
          ),
        ],
      ),
    );
  }
}

class _Review extends StatelessWidget {
  final int index;
  final TestQuestion q;
  final int? given;

  const _Review({required this.index, required this.q, required this.given});

  @override
  Widget build(BuildContext context) {
    final ok = given == q.answer;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: ok ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${q.question}',
                  style: const TextStyle(fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 4),
                Text(
                  'To‘g‘ri javob: ${q.options[q.answer]}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!ok && given != null)
                  Text(
                    'Sizning javobingiz: ${q.options[given!]}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.danger),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
