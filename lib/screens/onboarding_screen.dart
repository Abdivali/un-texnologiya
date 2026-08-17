import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import 'diagnostic_screen.dart';

/// Kirish / ro'yxatdan o'tish — barcha ma'lumot telefon xotirasida saqlanadi.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = appState.name;
    _groupCtrl.text = appState.group;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await appState.saveProfile(_nameCtrl.text.trim(), _groupCtrl.text.trim());
    if (!mounted) return;
    if (!appState.diagnosticDone) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const DiagnosticScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final needsDiagnostic = appState.name.isNotEmpty && !appState.diagnosticDone;

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.grain, size: 56, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Un ishlab chiqarish texnologiyasi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Individual ta’lim traektoriyasi orqali mustaqil ta’lim samaradorligini oshirish',
                style: TextStyle(color: Color(0xFFBFD4F5), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ma’lumotlaringizni kiriting',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'F.I.SH.',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => (v == null || v.trim().length < 3)
                            ? 'Ismingizni to‘liq kiriting'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _groupCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Guruh (masalan, OOT-21)',
                          prefixIcon: Icon(Icons.groups_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Guruhingizni kiriting'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _next,
                        child: Text(
                          needsDiagnostic
                              ? 'Diagnostika testini boshlash'
                              : 'Davom etish',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(Icons.lock_outline,
                              size: 15, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Ma’lumotlar faqat shu telefonda saqlanadi, internetga yuborilmaydi.',
                              style: TextStyle(
                                  fontSize: 11.5, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const _StepsPreview(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepsPreview extends StatelessWidget {
  const _StepsPreview();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Diagnostika — boshlang‘ich bilim darajasini aniqlash',
      'Traektoriya — individual o‘rganish yo‘li tuziladi',
      'O‘rganish — nazariya, interaktiv topshiriq, virtual laboratoriya',
      'Nazorat — test va laboratoriya protokoli',
      'Korreksiya — natijaga qarab traektoriya yangilanadi',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ilova qanday ishlaydi',
          style: TextStyle(
              color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    steps[i],
                    style: const TextStyle(
                        color: Color(0xFFCFE0F8), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
