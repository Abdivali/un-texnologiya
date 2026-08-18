import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:un_texnologiya/lab_formula.dart';
import 'package:un_texnologiya/store.dart';
import 'package:un_texnologiya/theme.dart';

void main() {
  // ---------------------------------------------------- formulalar
  test('Namlik formulasi to‘g‘ri hisoblaydi', () {
    // m0 = 10, m1 = 15 (5 g namuna), m2 = 14,3 -> 0,7 / 5 * 100 = 14 %
    final r = computeLab('namlik', {'m0': 10, 'm1': 15, 'm2': 14.3});
    expect(r.error, isNull);
    expect(r.value, closeTo(14.0, 0.001));
  });

  test('Kuldorlik formulasi to‘g‘ri hisoblaydi', () {
    final r = computeLab('kuldorlik', {'m1': 20, 'm2': 25, 'm3': 20.0275});
    expect(r.value, closeTo(0.55, 0.001));
  });

  test('Natura ayirma sifatida hisoblanadi', () {
    expect(computeLab('natura', {'mt': 1000, 'mb': 240}).value,
        closeTo(760, 0.001));
  });

  test('Qiyalik burchagi arctg(h/r) ga teng', () {
    expect(computeLab('burchak', {'h': 6, 'r': 8}).value,
        closeTo(36.8699, 0.001));
  });

  test('Nolga bo‘lish xatolik qaytaradi', () {
    expect(computeLab('foiz', {'ma': 5, 'mn': 0}).error, isNotNull);
  });

  test('Mavzu Material 3 asosida quriladi', () {
    expect(buildAppTheme().useMaterial3, isTrue);
  });

  // ---------------------------------------------------- holat va yangilanish
  group('AppState', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await appState.resetAllForTest();
      await appState.init();
    });

    test('Kontent yuklanadi va modullarda rasm hamda amaliyot bo‘ladi', () {
      final c = appState.content!;
      expect(c.modules.length, 15);
      expect(c.modules.every((m) => m.practice != null), isTrue);
      expect(c.modules.every((m) => m.images.isNotEmpty), isTrue);
      // amaliy mashg'ulot bosqichlar ro'yxatiga kirgan bo'lishi kerak
      expect(c.modules.first.stageKeys, contains('practice'));
    });

    test('markStage progressni darhol o‘zgartiradi', () async {
      final m = appState.content!.modules.first;
      expect(appState.moduleProgress(m), 0);
      await appState.markStage(m.id, 'theory');
      expect(appState.moduleProgress(m), greaterThan(0));
      expect(appState.isStageDone(m.id, 'theory'), isTrue);
    });

    // Bu test avvalgi xatolikni qaytib kelishidan saqlaydi:
    // holat o'zgarganda ekranlar qayta chizilishi shart.
    testWidgets('Bosqich belgilanganda tinglovchi vidjet darhol yangilanadi',
        (tester) async {
      var builds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              builds++;
              return Text('${(appState.overallProgress * 100).round()}%');
            },
          ),
        ),
      );
      final before = builds;
      expect(find.text('0%'), findsOneWidget);

      await appState.markStage(2, 'theory');
      await tester.pump();

      expect(builds, greaterThan(before));
      expect(find.text('0%'), findsNothing);
    });
  });
}
