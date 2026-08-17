import 'package:flutter_test/flutter_test.dart';

import 'package:un_texnologiya/theme.dart';
import 'package:un_texnologiya/lab_formula.dart';

void main() {
  test('Namlik formulasi to‘g‘ri hisoblaydi', () {
    // m0 = 10, m1 = 15 (5 g namuna), m2 = 14,3 -> 0,7 / 5 * 100 = 14 %
    final r = computeLab('namlik', {'m0': 10, 'm1': 15, 'm2': 14.3});
    expect(r.error, isNull);
    expect(r.value, closeTo(14.0, 0.001));
  });

  test('Kuldorlik formulasi to‘g‘ri hisoblaydi', () {
    // tigel 20 g, +5 g namuna = 25, kul bilan 20,0275 -> 0,55 %
    final r = computeLab('kuldorlik', {'m1': 20, 'm2': 25, 'm3': 20.0275});
    expect(r.value, closeTo(0.55, 0.001));
  });

  test('Natura ayirma sifatida hisoblanadi', () {
    final r = computeLab('natura', {'mt': 1000, 'mb': 240});
    expect(r.value, closeTo(760, 0.001));
  });

  test('Qiyalik burchagi arctg(h/r) ga teng', () {
    final r = computeLab('burchak', {'h': 6, 'r': 8});
    expect(r.value, closeTo(36.8699, 0.001));
  });

  test('Nolga bo‘lish xatolik qaytaradi', () {
    final r = computeLab('foiz', {'ma': 5, 'mn': 0});
    expect(r.error, isNotNull);
  });

  test('Mavzu Material 3 asosida quriladi', () {
    expect(buildAppTheme().useMaterial3, isTrue);
  });
}
