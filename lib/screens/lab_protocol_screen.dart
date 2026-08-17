import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lab_formula.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 7-bosqich: Laboratoriya ishi — protokol blankasi, hisoblash formulasi,
/// natijani me'yor bilan taqqoslash.
class LabProtocolScreen extends StatefulWidget {
  final LearningModule module;
  const LabProtocolScreen({super.key, required this.module});

  @override
  State<LabProtocolScreen> createState() => _LabProtocolScreenState();
}

class _LabProtocolScreenState extends State<LabProtocolScreen> {
  final Map<String, TextEditingController> _ctrls = {};
  double? _result;
  String? _error;

  LabProtocol get p => widget.module.protocol!;

  @override
  void initState() {
    super.initState();
    if (widget.module.protocol == null) return;
    final saved = appState.protocolFor(widget.module.id);
    for (final f in p.fields) {
      final v = saved?.values[f.key];
      _ctrls[f.key] = TextEditingController(
        text: v == null ? '' : _fmt(v),
      );
    }
    if (saved != null) _result = saved.result;
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(2);
  }

  Map<String, double>? _readValues() {
    final out = <String, double>{};
    for (final f in p.fields) {
      final raw = _ctrls[f.key]!.text.trim().replaceAll(',', '.');
      final v = double.tryParse(raw);
      if (v == null) {
        setState(() => _error = '«${f.label}» maydonini to‘g‘ri to‘ldiring');
        return null;
      }
      out[f.key] = v;
    }
    return out;
  }

  void _calculate() {
    final values = _readValues();
    if (values == null) return;
    final r = computeLab(p.formulaId, values);
    setState(() {
      _error = r.error;
      _result = r.error == null ? r.value : null;
    });
  }

  Future<void> _save() async {
    final values = _readValues();
    if (values == null || _result == null) return;
    await appState.addProtocol(SavedProtocol(
      moduleId: widget.module.id,
      values: values,
      result: _result!,
      date: AppState.today(),
    ));
    await appState.markStage(widget.module.id, 'protocol');
    if (!mounted) return;
    showToast(context, 'Protokol saqlandi');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.module.protocol == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Laboratoriya ishi')),
        body: const Center(child: Text('Bu modul uchun protokol mavjud emas')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Laboratoriya ishi')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      p.description,
                      style: const TextStyle(fontSize: 13.5, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('O‘lchov natijalari'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (final f in p.fields)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: TextField(
                        controller: _ctrls[f.key],
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]')),
                        ],
                        decoration: InputDecoration(
                          labelText: f.label,
                          suffixText: f.unit.isEmpty ? null : f.unit,
                        ),
                      ),
                    ),
                  const SizedBox(height: 2),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calculate_outlined),
                    label: const Text('Hisoblash'),
                    onPressed: _calculate,
                  ),
                ],
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 18, color: AppColors.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.resultLabel,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _result!.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.resultUnit,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            verdictFor(p.formulaId, _result!),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.norm,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.45,
                              color: AppColors.textMuted,
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _result == null ? null : _save,
            child: const Text('Protokolni saqlash'),
          ),
        ),
      ),
    );
  }
}
