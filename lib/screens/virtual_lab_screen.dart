import 'package:flutter/material.dart';

import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 6-bosqich: Virtual laboratoriya — asbob-uskuna bilan ishlash simulyatsiyasi.
class VirtualLabScreen extends StatefulWidget {
  final LearningModule module;
  const VirtualLabScreen({super.key, required this.module});

  @override
  State<VirtualLabScreen> createState() => _VirtualLabScreenState();
}

class _VirtualLabScreenState extends State<VirtualLabScreen> {
  int _score = 0;
  bool _finished = false;

  // choice_chain
  int _step = 0;
  int? _selected;
  bool _revealed = false;

  // organoleptik
  final Map<int, int> _sampleAnswers = {};
  bool _samplesChecked = false;

  // sort
  final Map<int, int> _placed = {};
  bool _sortChecked = false;

  VirtualLab get lab => widget.module.vlab!;

  Future<void> _save(int score, int total) async {
    await appState.addAttempt(AttemptResult(
      moduleId: widget.module.id,
      kind: 'vlab',
      score: score,
      total: total,
      date: AppState.today(),
      seconds: 0,
    ));
    await appState.markStage(widget.module.id, 'vlab');
    if (!mounted) return;
    setState(() {
      _score = score;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.module.vlab == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Virtual laboratoriya')),
        body: const Center(
          child: Text('Bu modul uchun simulyatsiya mavjud emas'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(lab.title)),
      body: _finished
          ? _buildFinished()
          : switch (lab.type) {
              'choice_chain' => _buildChain(),
              'organoleptik' => _buildOrganoleptik(),
              'sort' => _buildSort(),
              _ => const Center(child: Text('Noma’lum simulyatsiya turi')),
            },
    );
  }

  Widget _buildFinished() {
    final total = lab.taskCount;
    final pct = total == 0 ? 0 : (_score * 100 / total).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              pct >= 60 ? Icons.verified : Icons.replay_circle_filled_outlined,
              size: 60,
              color: pct >= 60 ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: 16),
            Text(
              '$_score / $total  ($pct%)',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Simulyatsiya yakunlandi va natija saqlandi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Modulga qaytish'),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ choice_chain

  Widget _buildChain() {
    final s = lab.steps[_step];
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_step + 1) / lab.steps.length,
          minHeight: 4,
          backgroundColor: AppColors.border,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (_step == 0) _IntroBox(text: lab.intro),
              Text(
                '${_step + 1} / ${lab.steps.length}-bosqich',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                s.question,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 18),
              for (var i = 0; i < s.options.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: OptionTile(
                    label: String.fromCharCode(65 + i),
                    text: s.options[i],
                    selected: _selected == i,
                    borderColor: _revealed
                        ? (i == s.answer
                            ? AppColors.success
                            : (_selected == i ? AppColors.danger : null))
                        : null,
                    fillColor: _revealed && i == s.answer
                        ? const Color(0xFFDCFCE7)
                        : null,
                    onTap: _revealed ? null : () => setState(() => _selected = i),
                  ),
                ),
              if (_revealed) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 17, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.explanation,
                          style: const TextStyle(fontSize: 12.5, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _selected == null
                  ? null
                  : () {
                      if (!_revealed) {
                        setState(() {
                          if (_selected == s.answer) _score++;
                          _revealed = true;
                        });
                      } else if (_step == lab.steps.length - 1) {
                        _save(_score, lab.steps.length);
                      } else {
                        setState(() {
                          _step++;
                          _selected = null;
                          _revealed = false;
                        });
                      }
                    },
              child: Text(
                !_revealed
                    ? 'Tekshirish'
                    : (_step == lab.steps.length - 1
                        ? 'Yakunlash'
                        : 'Keyingi bosqich'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------- organoleptik

  Widget _buildOrganoleptik() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _IntroBox(text: lab.intro),
              for (var i = 0; i < lab.samples.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SampleCard(
                    sample: lab.samples[i],
                    options: lab.sampleOptions,
                    selected: _sampleAnswers[i],
                    checked: _samplesChecked,
                    onSelect: (v) => setState(() => _sampleAnswers[i] = v),
                  ),
                ),
            ],
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _sampleAnswers.length != lab.samples.length
                  ? null
                  : () {
                      if (!_samplesChecked) {
                        var sc = 0;
                        for (var i = 0; i < lab.samples.length; i++) {
                          if (_sampleAnswers[i] == lab.samples[i].answer) sc++;
                        }
                        setState(() {
                          _score = sc;
                          _samplesChecked = true;
                        });
                      } else {
                        _save(_score, lab.samples.length);
                      }
                    },
              child: Text(_samplesChecked ? 'Yakunlash' : 'Baholarni tekshirish'),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------------- sort

  Widget _buildSort() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _IntroBox(text: lab.intro),
              for (var i = 0; i < lab.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (_sortChecked)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    _placed[i] == lab.items[i].group
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 17,
                                    color: _placed[i] == lab.items[i].group
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                              Expanded(
                                child: Text(
                                  lab.items[i].text,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var g = 0; g < lab.groups.length; g++)
                                ChoiceChip(
                                  label: Text(
                                    lab.groups[g],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  selected: _placed[i] == g,
                                  onSelected: _sortChecked
                                      ? null
                                      : (_) => setState(() => _placed[i] = g),
                                ),
                            ],
                          ),
                          if (_sortChecked && _placed[i] != lab.items[i].group)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'To‘g‘ri guruh: ${lab.groups[lab.items[i].group]}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _placed.length != lab.items.length
                  ? null
                  : () {
                      if (!_sortChecked) {
                        var sc = 0;
                        for (var i = 0; i < lab.items.length; i++) {
                          if (_placed[i] == lab.items[i].group) sc++;
                        }
                        setState(() {
                          _score = sc;
                          _sortChecked = true;
                        });
                      } else {
                        _save(_score, lab.items.length);
                      }
                    },
              child: Text(_sortChecked ? 'Yakunlash' : 'Tekshirish'),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroBox extends StatelessWidget {
  final String text;
  const _IntroBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined,
              size: 19, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  final VLabSample sample;
  final List<String> options;
  final int? selected;
  final bool checked;
  final ValueChanged<int> onSelect;

  const _SampleCard({
    required this.sample,
    required this.options,
    required this.selected,
    required this.checked,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final correct = checked && selected == sample.answer;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (checked)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      correct ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: correct ? AppColors.success : AppColors.danger,
                    ),
                  ),
                Text(
                  sample.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _Row(icon: Icons.palette_outlined, label: 'Rang', value: sample.rang),
            _Row(icon: Icons.air, label: 'Hid', value: sample.hid),
            _Row(
                icon: Icons.emoji_food_beverage_outlined,
                label: 'Ta’m',
                value: sample.tam),
            const SizedBox(height: 12),
            const Text(
              'Xulosangiz:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OptionTile(
                  label: String.fromCharCode(65 + i),
                  text: options[i],
                  selected: selected == i,
                  borderColor: checked && i == sample.answer
                      ? AppColors.success
                      : null,
                  fillColor: checked && i == sample.answer
                      ? const Color(0xFFDCFCE7)
                      : null,
                  onTap: checked ? null : () => onSelect(i),
                ),
              ),
            if (checked) ...[
              const SizedBox(height: 4),
              Text(
                sample.explanation,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.textMuted, height: 1.45),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
