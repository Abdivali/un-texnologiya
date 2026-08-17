# Un ishlab chiqarish texnologiyasi — mobil ilova

"Un ishlab chiqarish texnologiyasi" fani uchun **individual ta'lim traektoriyasiga** asoslangan
Flutter ilovasi. Butun kontent N.X.Qobilova, Sh.I.Gulboyeva, D.B.Xujamova tomonidan yozilgan
o'quv qo'llanmadan (Qarshi, 2026, 185 bet) olingan.

**Server talab qilinmaydi.** Barcha ma'lumot telefon xotirasida (`shared_preferences`) saqlanadi.

---

## Ichida nima bor

| Element | Miqdori | Manba |
|---|---|---|
| Modul (laboratoriya ishi) | 15 ta | qo'llanmaning 15 ta lab ishi |
| Nazariy matn bo‘limlari | 70 ta | qo'llanma matni |
| Test savollari (javob kaliti bilan) | 145 ta | qo'llanmadagi test savollari |
| Nazorat savollari | 139 ta | qo'llanma |
| Hisoblovchi laboratoriya protokoli | 11 ta | qo'llanmadagi formulalar |
| Virtual laboratoriya simulyatsiyasi | 3 ta | 1, 2, 3-modul |
| Interaktiv topshiriq | 30 ta | 15 modul × 2 tur |
| Diagnostika testi | 12 ta savol | modullar bo'ylab |

### Ilova ishlash zanjiri

```
Diagnostika → Traektoriya → O'rganish → Amaliy mashq → Nazorat → Monitoring → Korreksiya
```

- **Diagnostika** — 12 savollik test boshlang'ich darajani aniqlaydi (≥75 % → yuqori,
  ≥45 % → o'rta, aks holda boshlang'ich).
- **Traektoriya** — daraja modullar to'plamini belgilaydi. Test natijasi 60 % dan past bo'lgan
  modul avtomatik ravishda traektoriya boshiga ko'chiriladi (korreksiya).
- **Har bir modul** 5 bosqichdan iborat: nazariya → interaktiv topshiriq → virtual laboratoriya
  → laboratoriya protokoli → test. (Bosqichlar modulda mavjud bo'lganiga qarab.)

---

## Ishga tushirish

### 1. Flutter o'rnatish (bir marta)

```bash
# https://docs.flutter.dev/get-started/install
flutter --version    # 3.24 yoki undan yuqori bo'lsin
flutter doctor
```

Android APK yig'ish uchun **Android Studio** ham kerak (Android SDK + build-tools uchun).

### 2. Platforma papkalarini yaratish

Bu repoda faqat `lib/`, `assets/`, `test/` va `pubspec.yaml` bor.
`android/`, `ios/`, `web/` papkalarini Flutter o'zi yaratadi:

```bash
cd un_app
flutter create . --platforms=android,ios,web --org uz.qarshidtu
flutter pub get
```

> `flutter create .` mavjud `lib/`, `pubspec.yaml` va `assets/` ni **o'chirmaydi** —
> faqat yetishmayotgan platforma papkalarini qo'shadi.

### 3. Ishga tushirish

```bash
flutter run                      # ulangan telefon yoki emulyatorda
flutter run -d chrome            # brauzerda tez tekshirish uchun
flutter test                     # formulalar uchun unit testlar
flutter analyze                  # statik tahlil
```

### 4. APK yig'ish (Play Market'siz tarqatish uchun)

```bash
flutter build apk --release
# natija: build/app/outputs/flutter-apk/app-release.apk  (~20–25 MB)
```

Hajmni kamaytirish kerak bo'lsa, arxitektura bo'yicha bo'lish:

```bash
flutter build apk --split-per-abi
# app-arm64-v8a-release.apk  ~8–10 MB — zamonaviy telefonlarning 95 % i uchun shu yetadi
```

APK ni Telegram, Google Drive yoki USB orqali talabalarga bering. Telefonda
**"Noma'lum manbalardan o'rnatish"** ruxsatini yoqish kerak bo'ladi.

### 5. Web versiya (ixtiyoriy)

```bash
flutter build web --release
# build/web/ papkasini Netlify, Vercel yoki GitHub Pages ga tashlang — bepul
```

Web versiyasi telefon brauzerida ochiladi va "Bosh ekranga qo'shish" orqali ilovadek ishlaydi —
APK o'rnatish shart emas.

---

## Loyiha tuzilishi

```
un_app/
├── pubspec.yaml
├── assets/
│   └── content.json          # butun o'quv kontenti (192 KB)
├── lib/
│   ├── main.dart             # kirish nuqtasi, splash, marshrutlash
│   ├── theme.dart            # ranglar va uslub
│   ├── models.dart           # JSON → Dart modellar
│   ├── store.dart            # holat + shared_preferences (progress, natijalar)
│   ├── lab_formula.dart      # laboratoriya hisob-kitob formulalari
│   ├── widgets/common.dart   # ProgressRing, grafik, OptionTile
│   └── screens/
│       ├── onboarding_screen.dart    # kirish
│       ├── diagnostic_screen.dart    # 1-bosqich: diagnostika
│       ├── home_shell.dart           # pastki navigatsiya
│       ├── dashboard_screen.dart     # bosh sahifa
│       ├── trajectory_screen.dart    # 2-bosqich: traektoriya
│       ├── modules_screen.dart       # 3-bosqich: modullar
│       ├── module_detail_screen.dart # modul tarkibi
│       ├── theory_screen.dart        # 4-bosqich: nazariya
│       ├── interactive_screen.dart   # 5-bosqich: interaktiv topshiriq
│       ├── virtual_lab_screen.dart   # 6-bosqich: virtual laboratoriya
│       ├── lab_protocol_screen.dart  # 7-bosqich: laboratoriya ishi
│       ├── test_screen.dart          # 8-bosqich: test
│       ├── results_screen.dart       # 9-bosqich: natijalar
│       └── profile_screen.dart       # 10-bosqich: profil
└── test/widget_test.dart     # formulalar uchun unit testlar
```

---

## Kontentni tahrirlash

Hech qanday Dart kodiga tegmasdan `assets/content.json` faylini tahrirlash yetarli.

**Test savoli qo'shish** (`a` — to'g'ri javob indeksi, 0 = A):

```json
{"q": "Savol matni?", "o": ["A varianti","B varianti","C varianti","D varianti"], "a": 1}
```

**Yangi laboratoriya protokoli qo'shish** — `lib/lab_formula.dart` faylidagi `computeLab`
funksiyasiga yangi `case` qo'shing va JSON da `formulaId` ni o'sha nom bilan ko'rsating.

O'zgartirishdan keyin `flutter run` ni qayta ishga tushiring (hot reload assetlarni
har doim ham yangilamaydi).

---

## Keyingi bosqich uchun g'oyalar

- **O'qituvchi paneli** — hozir natija faqat telefonda. Agar o'qituvchi ko'rishi kerak bo'lsa,
  Supabase (bepul plan) qo'shish kifoya: `store.dart` da saqlash funksiyalariga API chaqiruvi
  qo'shiladi, qolgan kod o'zgarmaydi.
- **Rasm va videolar** — qo'llanmadagi rasmlar (shuplar, purka, mufel pechi) hozir ilovada yo'q.
  `assets/images/` papkasiga qo'shib, `content.json` da bo'limga `img` maydonini qo'shish mumkin.
- **PDF eksport** — talaba laboratoriya protokolini PDF qilib o'qituvchiga yuborishi
  (`pdf` va `printing` paketlari).
- **Qolgan 12 modul uchun virtual laboratoriya** — hozir 1, 2, 3-modulda bor;
  format `content.json` da tayyor, faqat ssenariy yozish kerak.

---

## Manba

N.X.Qobilova, Sh.I.Gulboyeva, D.B.Xujamova. **Un ishlab chiqarish texnologiyasi.**
O'quv qo'llanma. Qarshi, 2026-yil. 60720100 — Oziq-ovqat texnologiyasi (don mahsulotlari)
bakalavriat yo'nalishi uchun.
