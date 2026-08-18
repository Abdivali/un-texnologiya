import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import 'diagnostic_screen.dart';

/// 10-bosqich: Profil — shaxsiy ma'lumotlar, sozlamalar, yutuqlar.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
    final achievements = _achievements(s);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: Text(
                      s.name.isEmpty ? '?' : s.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name.isEmpty ? 'Talaba' : s.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          s.group,
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s.startLevel == 3
                                ? 'Yuqori daraja'
                                : (s.startLevel == 2
                                    ? 'O‘rta daraja'
                                    : 'Boshlang‘ich daraja'),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => _editProfile(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Yutuqlar'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: achievements
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: a.unlocked
                                    ? const Color(0xFFFEF3C7)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                a.icon,
                                size: 20,
                                color: a.unlocked
                                    ? AppColors.warning
                                    : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: a.unlocked
                                          ? AppColors.navy
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  Text(
                                    a.description,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            if (a.unlocked)
                              const Icon(Icons.check_circle,
                                  size: 18, color: AppColors.success),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Sozlamalar'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.primary),
                  title: const Text('Diagnostikani qayta topshirish',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                    'Traektoriya yangi darajaga moslanadi',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DiagnosticScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading:
                      const Icon(Icons.delete_outline, color: AppColors.danger),
                  title: const Text('Barcha ma’lumotlarni o‘chirish',
                      style: TextStyle(fontSize: 14)),
                  subtitle: const Text(
                    'Progress, natijalar va protokollar o‘chiriladi',
                    style: TextStyle(fontSize: 12),
                  ),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Manba',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.content?.source ?? '',
                    style: const TextStyle(
                        fontSize: 12, height: 1.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ilova ma’lumotlari faqat shu qurilmada saqlanadi.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final nameCtrl = TextEditingController(text: appState.name);
    final groupCtrl = TextEditingController(text: appState.group);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Profilni tahrirlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'F.I.SH.'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: groupCtrl,
              decoration: const InputDecoration(labelText: 'Guruh'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bekor qilish'),
          ),
          FilledButton(
            onPressed: () async {
              await appState.saveProfile(
                nameCtrl.text.trim(),
                groupCtrl.text.trim(),
              );
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ma’lumotlarni o‘chirish'),
        content: const Text(
          'Barcha progress, test natijalari va protokollar o‘chiriladi. '
          'Bu amalni qaytarib bo‘lmaydi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () async {
              await appState.resetAll();
              if (!ctx.mounted) return;
              Navigator.of(ctx).pop();
            },
            child: const Text(
              'O‘chirish',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  List<_Achievement> _achievements(AppState s) {
    return [
      _Achievement(
        icon: Icons.flag_outlined,
        title: 'Boshlanish',
        description: 'Diagnostika testi topshirildi',
        unlocked: s.diagnosticDone,
      ),
      _Achievement(
        icon: Icons.menu_book_outlined,
        title: 'Birinchi modul',
        description: 'Bitta modul to‘liq bajarildi',
        unlocked: s.completedModules >= 1,
      ),
      _Achievement(
        icon: Icons.science_outlined,
        title: 'Laborant',
        description: 'Laboratoriya protokoli saqlandi',
        unlocked: s.protocols.isNotEmpty,
      ),
      _Achievement(
        icon: Icons.emoji_events_outlined,
        title: 'Yarim yo‘l',
        description: 'Umumiy o‘zlashtirish 50 % dan yuqori',
        unlocked: s.overallProgress >= 0.5,
      ),
      _Achievement(
        icon: Icons.workspace_premium_outlined,
        title: 'Fan bo‘yicha sertifikat',
        description: 'Barcha modullar bajarildi',
        unlocked: s.totalModules > 0 && s.completedModules == s.totalModules,
      ),
    ];
  }
}

class _Achievement {
  final IconData icon;
  final String title;
  final String description;
  final bool unlocked;

  _Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.unlocked,
  });
}
