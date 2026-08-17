# Ilovani ishlatish uchun nima kerak va qancha pul ketadi

**Qisqa javob: 0 so'm.** Play Market / App Store kerak bo'lmagani va ilova serversiz
ishlagani uchun majburiy to'lov yo'q. Quyida batafsil.

---

## 1-qism. Nima kerak

### Majburiy (hammasi bepul)

| Nima | Nima uchun | Narxi | Qayerdan |
|---|---|---|---|
| Kompyuter (Windows / macOS / Linux) | kod yig'ish uchun | bor | — |
| **Flutter SDK** 3.24+ | ilovani kompilyatsiya qilish | **bepul** | docs.flutter.dev |
| **Android Studio** | Android SDK, build-tools, emulyator | **bepul** | developer.android.com |
| Android telefon | sinash va ishlatish | bor | — |

Talab qilinadigan disk: Flutter ~3 GB + Android Studio ~10 GB + Android SDK ~5 GB ≈ **18 GB**.
Internet: birinchi o'rnatishda ~5 GB yuklab olinadi, keyin kerak emas.

### Kerak emas

- ❌ Server / VPS — ilova serversiz, ma'lumot telefonda
- ❌ Ma'lumotlar bazasi — `shared_preferences` (telefon xotirasi)
- ❌ Domen nomi — internet manzili kerak emas
- ❌ Google Play Console ($25) va Apple Developer ($99/yil) — do'kon kerak emas
- ❌ Mac kompyuter — faqat iPhone uchun kerak bo'lardi

---

## 2-qism. Qadamlar (birinchi marta ~1–2 soat, asosan yuklab olish)

```bash
# 1) Flutter o'rnatilganini tekshirish
flutter doctor

# 2) Loyihaga kirish va platforma papkalarini yaratish
cd un_app
flutter create . --platforms=android,ios,web --org uz.qarshidtu
flutter pub get

# 3) Telefonni USB orqali ulab, darhol ishga tushirish
flutter run

# 4) Tarqatish uchun APK yig'ish
flutter build apk --split-per-abi
# natija: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (~9 MB)
```

APK ni talabalarga **Telegram guruhiga tashlash** yoki Google Drive havolasini berish yetarli.
Talaba telefonida bir marta "Noma'lum manbadan o'rnatish" ruxsatini yoqadi — tamom.

### Muqobil yo'l: umuman APK'siz

```bash
flutter build web --release
```

`build/web/` papkasini **Netlify** yoki **Vercel** ga sudrab tashlaysiz (bepul, ro'yxatdan
o'tish 2 daqiqa). `https://un-texnologiya.netlify.app` kabi havola olasiz. Talaba shu havolani
telefon brauzerida ochadi va **"Bosh ekranga qo'shish"** tugmasini bosadi — ilova ikonkasi
paydo bo'ladi, oddiy ilovadek ishlaydi, hech narsa o'rnatilmaydi.

Frontend developer sifatida sizga bu yo'l ancha qulayroq bo'lishi mumkin: har safar
o'zgartirish qilganingizda talabalarga yangi APK tarqatish shart emas — havola o'zi yangilanadi.

---

## 3-qism. Xarajatlar jadvali

### Hozirgi variant (siz tanlagan: serversiz, do'konsiz)

| Element | Narxi |
|---|---|
| Flutter, Android Studio, Dart | 0 |
| APK yig'ish va tarqatish | 0 |
| Ma'lumot saqlash (telefon xotirasi) | 0 |
| Netlify/Vercel'da web versiya (ixtiyoriy) | 0 |
| **JAMI** | **0 so'm/oy, 0 so'm/yil** |

### Agar keyinchalik kengaytirmoqchi bo'lsangiz

| Qo'shimcha | Nima beradi | Narxi |
|---|---|---|
| **Supabase** (bepul plan) | O'qituvchi talabalar natijasini ko'radi, ma'lumot bulutda | **0** (500 MB baza, 50 000 foydalanuvchi/oy — 300–500 talaba uchun yetarli) |
| Supabase Pro | 8 GB baza, avtomatik zaxira | ~$25/oy (~310 000 so'm) |
| O'z VPS'ingiz (Node.js + PostgreSQL) | To'liq nazorat | $5–10/oy (~60–125 000 so'm) |
| Domen (`.uz` yoki `.com`) | Chiroyli havola | ~$10–15/yil (~125–190 000 so'm) |
| **Google Play** | Play Market'da chiqish | **$25 bir marta** (umrbod) |
| **App Store** | iPhone'ga App Store orqali | **$99/yil** |
| Firebase Push xabarnoma | "Topshiriq muddati yaqinlashdi" bildirishnomasi | 0 (Spark bepul plan) |

> Ta'lim muassasasi Apple Developer Program'ga bepul kirish uchun ariza bera oladi
> (Apple's fee waiver for educational institutions) — universitet nomidan murojaat qilinsa.

### Vaqt xarajati (agar o'zingiz qilsangiz)

| Ish | Taxminiy vaqt |
|---|---|
| Muhitni sozlash, birinchi APK | 1–2 soat |
| Qo'llanmadagi rasmlarni ilovaga qo'shish | 3–5 soat |
| Qolgan 12 modul uchun virtual laboratoriya ssenariylari | 10–15 soat |
| O'qituvchi paneli (Supabase bilan) | 15–25 soat |

---

## 4-qism. Tavsiya etiladigan yo'l xaritasi

1. **Bugun** — `flutter run` qilib telefoningizda ko'ring, kontentni tekshiring.
2. **Shu hafta** — test javoblari kalitini fan o'qituvchisi bilan bir marta tekshirib chiqing.
   Javoblar qo'llanma matni asosida qo'yilgan, lekin qo'llanmaning o'zida rasmiy kalit yo'q edi.
3. **Keyin** — qo'llanmadagi rasmlarni (shuplar, purka, mufel pechi, diafanoskop) qo'shing —
   bu ilovaning o'quv qiymatini eng ko'p oshiradigan qadam.
4. **Sinovdan keyin** — agar o'qituvchi natijalarni ko'rishni xohlasa, Supabase bepul planini
   ulang. Kod tuzilishi buni hisobga olib yozilgan: faqat `store.dart` o'zgaradi.

---

## Diqqat qilinadigan bir narsa

Test savollarining **to'g'ri javoblari qo'llanma matni va soha standartlari asosida
belgilangan** — asl PDF da javoblar kaliti berilmagan. 145 ta savolning aksariyati aniq
(masalan, "namlik 130 °C da 40 daqiqa quritiladi" — matnda to'g'ridan-to'g'ri yozilgan),
lekin ishlatishdan oldin fan o'qituvchisi bilan bir marta ko'zdan kechirib chiqish tavsiya
etiladi. Javoblarni o'zgartirish oson: `assets/content.json` faylida `"a"` qiymatini
almashtirish yetarli (0 = A, 1 = B, 2 = C, 3 = D).

---

**Manbalar (do'kon narxlari):**

- [Google Play Developer Fee 2026: $25 one-time](https://www.iconikai.com/blog/google-play-developer-account-fee-2026)
- [Apple Developer Program Fee 2026: $99/Year](https://ambsandigital.com/apple-developer-program-fee-2026/)
