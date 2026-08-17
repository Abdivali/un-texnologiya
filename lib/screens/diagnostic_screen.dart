import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 1-bosqich: Diagnostika — boshlang'ich bilim darajasini aniqlash.
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key});

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  int _index = 0;
  final Map<int, int> _answers = {};
  bool _finished = false;
  int _score = 0;

  List<TestQuestion> get _questions => appState.content?.diagnostic ?? const [];

  Future<void> _finish() async {
    var score = 0;
    for (var i = 0; i < _questions.length; i++) {
      if (_answers[i] == _questions[i].answer) score++;
    }
    await appState.completeDiagnostic(score, _questions.length);
    if (!mounted) return;
    setState(() {
      _score = score;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final qs = _questions;
    if (qs.isEmpty) {
      return const Scaffold(body: Center(child: Text('Savollar topilmadi')));
    }
    if (_finished) return _buildResult(context);

    final q = qs[_index];
    final selected = _answers[_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostika testi'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_index + 1) / qs.length,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_index + 1} / ${qs.length}-savol',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13),
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
                              if (_index == qs.length - 1) {
                                _finish();
                              } else {
                                setState(() => _index++);
                              }
                            },
                      child: Text(
                          _index == qs.length - 1 ? 'Yakunlash' : 'Keyingisi'),
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

  Widget _buildResult(BuildContext context) {
    final total = _questions.length;
    final pct = total == 0 ? 0 : (_score * 100 / total).round();
    final level = appState.startLevel;
    const levelNames = {
      1: 'Boshlang‘ich daraja',
      2: 'O‘rta daraja',
      3: 'Yuqori daraja',
    };
    const levelDesc = {
      1: 'Traektoriya barcha modullardan, asosiy tushunchalardan boshlanadi.',
      2: 'Asosiy mavzular qisqartirilib, fizik-kimyoviy tahlillarga urg‘u beriladi.',
      3: 'Murakkab modullar — kleykovina, tushish soni, kislotalik — birinchi o‘rinda.',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostika natijasi'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      pct >= 60 ? Icons.emoji_events_outlined : Icons.school_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_score / $total  ($pct%)',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      levelNames[level] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      levelDesc[level] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Javoblar tahlili',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppColors.navy),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < _questions.length; i++)
              _AnswerReview(
                index: i,
                question: _questions[i],
                given: _answers[i],
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Traektoriyaga o‘tish'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerReview extends StatelessWidget {
  final int index;
  final TestQuestion question;
  final int? given;

  const _AnswerReview({
    required this.index,
    required this.question,
    required this.given,
  });

  @override
  Widget build(BuildContext context) {
    final correct = given == question.answer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: correct ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              size: 18,
              color: correct ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${question.question}',
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                  if (!correct) ...[
                    const SizedBox(height: 4),
                    Text(
                      'To‘g‘ri javob: ${question.options[question.answer]}',
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
          ],
        ),
      ),
    );
  }
}
