import 'dart:math' as math;

/// Laboratoriya protokollari uchun hisob-kitob.
/// Har bir formulaId qo'llanmadagi tegishli ifodaga mos keladi.
class FormulaResult {
  final double value;
  final String? error;
  const FormulaResult(this.value, {this.error});
}

FormulaResult computeLab(String formulaId, Map<String, double> v) {
  double g(String k) => v[k] ?? 0;

  switch (formulaId) {
    // Dastlabki namuna massasi, kg
    case 'namuna':
      return FormulaResult(g('n') * g('m') / 1000.0);

    // Oddiy foiz: (ma / mn) * 100
    case 'foiz':
      if (g('mn') <= 0) {
        return const FormulaResult(0, error: 'Namuna massasi 0 dan katta bo‘lsin');
      }
      return FormulaResult(g('ma') / g('mn') * 100);

    // Natura: idish + don − bo'sh idish
    case 'natura':
      return FormulaResult(g('mt') - g('mb'));

    // Namlik: (m1 − m2) / (m1 − m0) * 100
    case 'namlik':
      final den = g('m1') - g('m0');
      if (den <= 0) {
        return const FormulaResult(0, error: 'm₁ qiymati m₀ dan katta bo‘lsin');
      }
      return FormulaResult((g('m1') - g('m2')) / den * 100);

    // Kuldorlik: (m3 − m1) / (m2 − m1) * 100
    case 'kuldorlik':
      final den = g('m2') - g('m1');
      if (den <= 0) {
        return const FormulaResult(0, error: 'm₂ qiymati m₁ dan katta bo‘lsin');
      }
      return FormulaResult((g('m3') - g('m1')) / den * 100);

    // Qiyalik burchagi: arctg(h / r), gradusda
    case 'burchak':
      if (g('r') <= 0) {
        return const FormulaResult(0, error: 'Radius 0 dan katta bo‘lsin');
      }
      return FormulaResult(math.atan(g('h') / g('r')) * 180 / math.pi);

    // Umumiy shishasimonlik: nt + nq / 2
    case 'shaffoflik':
      return FormulaResult(g('nt') + g('nq') / 2);

    // Metallomagnit qo'shimcha, mg/kg
    case 'mgkg':
      if (g('mn') <= 0) {
        return const FormulaResult(0, error: 'Namuna massasi 0 dan katta bo‘lsin');
      }
      return FormulaResult(g('ma') / g('mn'));

    // Kislotalik, gradus: (V * K * 100) / (m * 10)
    case 'kislota':
      if (g('m') <= 0) {
        return const FormulaResult(0, error: 'Namuna massasi 0 dan katta bo‘lsin');
      }
      final k = g('k') == 0 ? 1.0 : g('k');
      return FormulaResult(g('v') * k * 100 / (g('m') * 10));

    default:
      return const FormulaResult(0, error: 'Formula topilmadi');
  }
}

/// Natijani me'yor bilan solishtirish uchun oddiy baho.
String verdictFor(String formulaId, double value) {
  switch (formulaId) {
    case 'namlik':
      if (value <= 14) return 'Quruq — saqlashga yaroqli';
      if (value <= 15.5) return 'O‘rtacha quruq — nazorat talab etiladi';
      return 'Nam — quritish zarur';
    case 'natura':
      if (value >= 750) return 'Yuqori natura — sifatli don';
      if (value >= 730) return 'O‘rtacha natura';
      return 'Past natura — sifat past';
    case 'kuldorlik':
      if (value <= 0.55) return 'Oliy nav talabiga mos';
      if (value <= 0.75) return '1-nav talabiga mos';
      if (value <= 1.25) return '2-nav talabiga mos';
      return 'Nav talabidan yuqori';
    case 'kislota':
      if (value <= 3.5) return 'Yangi un — me’yorda';
      if (value <= 5) return 'Chegaraviy holat';
      return 'Kislotalik yuqori — un eskirgan';
    default:
      return 'Natija me’yoriy hujjat bilan taqqoslansin';
  }
}
