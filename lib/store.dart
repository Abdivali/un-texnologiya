import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Bitta test/urinish natijasi.
class AttemptResult {
  final int moduleId;
  final String kind; // 'test' | 'vlab' | 'interactive' | 'diagnostic'
  final int score;
  final int total;
  final String date; // ISO yyyy-MM-dd
  final int seconds;

  AttemptResult({
    required this.moduleId,
    required this.kind,
    required this.score,
    required this.total,
    required this.date,
    required this.seconds,
  });

  double get percent => total == 0 ? 0 : score * 100 / total;

  Map<String, dynamic> toJson() => {
        'm': moduleId,
        'k': kind,
        's': score,
        't': total,
        'd': date,
        'sec': seconds,
      };

  factory AttemptResult.fromJson(Map<String, dynamic> j) => AttemptResult(
        moduleId: (j['m'] as num? ?? 0).toInt(),
        kind: (j['k'] ?? 'test').toString(),
        score: (j['s'] as num? ?? 0).toInt(),
        total: (j['t'] as num? ?? 0).toInt(),
        date: (j['d'] ?? '').toString(),
        seconds: (j['sec'] as num? ?? 0).toInt(),
      );
}

/// Saqlangan laboratoriya protokoli.
class SavedProtocol {
  final int moduleId;
  final Map<String, double> values;
  final double result;
  final String date;

  SavedProtocol({
    required this.moduleId,
    required this.values,
    required this.result,
    required this.date,
  });

  Map<String, dynamic> toJson() =>
      {'m': moduleId, 'v': values, 'r': result, 'd': date};

  factory SavedProtocol.fromJson(Map<String, dynamic> j) => SavedProtocol(
        moduleId: (j['m'] as num? ?? 0).toInt(),
        values: (j['v'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        result: (j['r'] as num? ?? 0).toDouble(),
        date: (j['d'] ?? '').toString(),
      );
}

/// Ilovaning butun holati. Ma'lumotlar telefon xotirasida (SharedPreferences)
/// saqlanadi — server talab qilinmaydi.
class AppState extends ChangeNotifier {
  static const _kProfile = 'profile_v1';
  static const _kProgress = 'progress_v1';
  static const _kAttempts = 'attempts_v1';
  static const _kProtocols = 'protocols_v1';

  late SharedPreferences _prefs;
  AppContent? content;
  bool ready = false;

  // Profil
  String name = '';
  String group = '';
  int startLevel = 0; // 0 = diagnostika o'tilmagan
  bool diagnosticDone = false;

  // Bosqichlar: "moduleId:stage" -> bajarilgan
  final Set<String> _doneStages = <String>{};
  final List<AttemptResult> attempts = <AttemptResult>[];
  final List<SavedProtocol> protocols = <SavedProtocol>[];

  Future<void> init() async {
    final raw = await rootBundle.loadString('assets/content.json');
    content = AppContent.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    _prefs = await SharedPreferences.getInstance();
    _load();
    ready = true;
    notifyListeners();
  }

  void _load() {
    final p = _prefs.getString(_kProfile);
    if (p != null) {
      final j = jsonDecode(p) as Map<String, dynamic>;
      name = (j['name'] ?? '').toString();
      group = (j['group'] ?? '').toString();
      startLevel = (j['level'] as num? ?? 0).toInt();
      diagnosticDone = j['diag'] == true;
    }
    final pr = _prefs.getStringList(_kProgress);
    if (pr != null) _doneStages.addAll(pr);

    final at = _prefs.getString(_kAttempts);
    if (at != null) {
      for (final e in jsonDecode(at) as List<dynamic>) {
        attempts.add(AttemptResult.fromJson(e as Map<String, dynamic>));
      }
    }
    final pt = _prefs.getString(_kProtocols);
    if (pt != null) {
      for (final e in jsonDecode(pt) as List<dynamic>) {
        protocols.add(SavedProtocol.fromJson(e as Map<String, dynamic>));
      }
    }
  }

  Future<void> _saveProfile() async {
    await _prefs.setString(
      _kProfile,
      jsonEncode({
        'name': name,
        'group': group,
        'level': startLevel,
        'diag': diagnosticDone,
      }),
    );
  }

  Future<void> saveProfile(String newName, String newGroup) async {
    name = newName;
    group = newGroup;
    await _saveProfile();
    notifyListeners();
  }

  // ---------------------------------------------------------------- traektoriya

  /// Diagnostika natijasiga qarab boshlang'ich daraja aniqlanadi.
  Future<void> completeDiagnostic(int score, int total) async {
    final pct = total == 0 ? 0 : score * 100 / total;
    startLevel = pct >= 75 ? 3 : (pct >= 45 ? 2 : 1);
    diagnosticDone = true;
    await _saveProfile();
    await addAttempt(AttemptResult(
      moduleId: 0,
      kind: 'diagnostic',
      score: score,
      total: total,
      date: today(),
      seconds: 0,
    ));
  }

  /// Individual ta'lim traektoriyasi — daraja va natijalarga qarab
  /// modullar tartibi shakllantiriladi.
  List<LearningModule> get trajectory {
    final all = content?.modules ?? const <LearningModule>[];
    if (all.isEmpty) return const [];
    final lvl = startLevel == 0 ? 1 : startLevel;

    final core = all.where((m) => m.level <= lvl).toList();
    final rest = all.where((m) => m.level > lvl).toList();

    // Past natija olingan modullar traektoriya boshiga ko'chiriladi (korreksiya).
    final weak = <LearningModule>[];
    final normal = <LearningModule>[];
    for (final m in core) {
      final best = bestScore(m.id);
      if (best != null && best < 60) {
        weak.add(m);
      } else {
        normal.add(m);
      }
    }
    return [...weak, ...normal, ...rest];
  }

  /// Traektoriyadagi navbatdagi bajarilmagan bosqich.
  MapEntry<LearningModule, String>? get nextStep {
    for (final m in trajectory) {
      for (final s in m.stageKeys) {
        if (!isStageDone(m.id, s)) return MapEntry(m, s);
      }
    }
    return null;
  }

  // ---------------------------------------------------------------- progress

  bool isStageDone(int moduleId, String stage) =>
      _doneStages.contains('$moduleId:$stage');

  Future<void> markStage(int moduleId, String stage) async {
    if (_doneStages.add('$moduleId:$stage')) {
      await _prefs.setStringList(_kProgress, _doneStages.toList());
      notifyListeners();
    }
  }

  double moduleProgress(LearningModule m) {
    final keys = m.stageKeys;
    if (keys.isEmpty) return 0;
    var done = 0;
    for (final k in keys) {
      if (isStageDone(m.id, k)) done++;
    }
    return done / keys.length;
  }

  bool isModuleDone(LearningModule m) => moduleProgress(m) >= 1.0;

  int get completedModules {
    final all = content?.modules ?? const <LearningModule>[];
    return all.where(isModuleDone).length;
  }

  int get totalModules => content?.modules.length ?? 0;

  /// Umumiy o'zlashtirish foizi — barcha bosqichlar bo'yicha.
  double get overallProgress {
    final all = content?.modules ?? const <LearningModule>[];
    if (all.isEmpty) return 0;
    var total = 0, done = 0;
    for (final m in all) {
      for (final k in m.stageKeys) {
        total++;
        if (isStageDone(m.id, k)) done++;
      }
    }
    return total == 0 ? 0 : done / total;
  }

  // ---------------------------------------------------------------- natijalar

  Future<void> addAttempt(AttemptResult r) async {
    attempts.add(r);
    await _prefs.setString(
      _kAttempts,
      jsonEncode(attempts.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  Future<void> addProtocol(SavedProtocol p) async {
    protocols.removeWhere((e) => e.moduleId == p.moduleId);
    protocols.add(p);
    await _prefs.setString(
      _kProtocols,
      jsonEncode(protocols.map((e) => e.toJson()).toList()),
    );
    notifyListeners();
  }

  SavedProtocol? protocolFor(int moduleId) {
    for (final p in protocols) {
      if (p.moduleId == moduleId) return p;
    }
    return null;
  }

  /// Modul bo'yicha eng yaxshi test natijasi (foizda).
  double? bestScore(int moduleId) {
    double? best;
    for (final a in attempts) {
      if (a.moduleId == moduleId && a.kind == 'test') {
        if (best == null || a.percent > best) best = a.percent;
      }
    }
    return best;
  }

  int get totalPoints {
    var p = 0;
    for (final a in attempts) {
      p += a.score * 10;
    }
    return p;
  }

  /// Oxirgi 7 kun bo'yicha o'zlashtirish dinamikasi (grafik uchun).
  List<MapEntry<String, double>> get dynamics {
    final byDate = <String, List<double>>{};
    for (final a in attempts) {
      if (a.total == 0) continue;
      byDate.putIfAbsent(a.date, () => <double>[]).add(a.percent);
    }
    final keys = byDate.keys.toList()..sort();
    final tail = keys.length > 7 ? keys.sublist(keys.length - 7) : keys;
    return tail.map((k) {
      final list = byDate[k]!;
      final avg = list.reduce((a, b) => a + b) / list.length;
      return MapEntry(k.substring(5), avg);
    }).toList();
  }

  /// Zaif mavzular — tavsiya blokida ishlatiladi.
  List<LearningModule> get weakModules {
    final all = content?.modules ?? const <LearningModule>[];
    final out = <LearningModule>[];
    for (final m in all) {
      final b = bestScore(m.id);
      if (b != null && b < 60) out.add(m);
    }
    return out;
  }

  Future<void> resetAll() async {
    await _prefs.clear();
    _doneStages.clear();
    attempts.clear();
    protocols.clear();
    name = '';
    group = '';
    startLevel = 0;
    diagnosticDone = false;
    notifyListeners();
  }

  static String today() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }
}

/// Ilova bo'ylab yagona holat obyekti.
final appState = AppState();

const stageLabels = <String, String>{
  'theory': 'Nazariy material',
  'interactive': 'Interaktiv topshiriq',
  'vlab': 'Virtual laboratoriya',
  'protocol': 'Laboratoriya ishi',
  'test': 'Test',
};
