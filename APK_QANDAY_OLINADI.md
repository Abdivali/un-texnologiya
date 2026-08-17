# APK ni qayerdan olaman va talabalarga qanday yuboraman

**Muhim:** men APK faylini o'zim yig'ib bera olmayman — APK yig'ish uchun Android SDK kerak,
bu esa men ishlayotgan muhitda yo'q. Lekin sizga **kompyuteringizga hech narsa o'rnatmasdan**
APK olish yo'lini tayyorlab qo'ydim.

Uchta yo'l bor. Tavsiyam: **A yo'lini bugun ishlating, B ni parallel qo'yib qo'ying.**

---

## A yo'li — Web havola (eng oson, 10 daqiqa, APK umuman kerak emas)

`ilova_web.html` faylini bepul hostingga tashlaysiz va talabalarga bitta havola berasiz.
Ular havolani ochib "Bosh ekranga qo'shish" bosishadi — telefonda ilova ikonkasi paydo
bo'ladi, oddiy ilovadek to'liq ekranda ochiladi. Natijalar telefonda saqlanadi.

### Qadamlar (Netlify Drop)

1. https://app.netlify.com/drop sahifasini oching (ro'yxatdan o'tish shart emas).
2. `ilova_web.html` faylini `index.html` deb qayta nomlang.
3. Uni sahifaga sudrab tashlang.
4. 10 soniyada `https://random-nom-123.netlify.app` kabi havola chiqadi.
5. Shu havolani Telegram guruhiga tashlang.

### Talaba nima qiladi

1. Havolani telefonda ochadi (Chrome).
2. O'ng yuqoridagi ⋮ menyu → **"Ilovani o'rnatish"** yoki **"Bosh ekranga qo'shish"**.
3. Tamom. Ikonka bosh ekranda, offline ham ochiladi.

### Afzalligi

- ✅ Android va iPhone'da bir xil ishlaydi
- ✅ "Noma'lum manbadan o'rnatish" ogohlantirishi yo'q
- ✅ Kontentni o'zgartirsangiz — faylni qayta tashlaysiz, talabalar avtomatik yangi versiyani ko'radi
- ⚠️ Bu HTML prototip: kontent, testlar, formulalar Flutter versiyasi bilan **bir xil**,
  lekin bu Flutter ilova emas

---

## B yo'li — APK ni GitHub bulutida yig'ish (kompyuterga hech narsa o'rnatilmaydi)

Loyihada `.github/workflows/build-apk.yml` fayli bor. GitHub sizning o'rningizga Flutter
o'rnatadi, APK yig'adi va ommaviy yuklab olish havolasini beradi.

### Qadamlar (bir marta, ~20 daqiqa)

1. **GitHub akkaunt** oching (bepul) — github.com
2. **Yangi repository** yarating: `un-texnologiya`, **Public** (Private ham bo'ladi,
   lekin unda Release havolasi faqat sizga ko'rinadi).
3. `un_texnologiya_app.zip` ni oching. **`un_app` papkasining ICHIDAGI hamma narsani**
   repo'ga yuklang — ya'ni repo ildizida `pubspec.yaml`, `lib/`, `assets/`, `.github/`
   turishi kerak (`un_app/pubspec.yaml` emas!).

   Saytdan yuklash: repo sahifasida **Add file → Upload files** → papkalarni sudrab tashlang →
   **Commit changes**.

   > `.github` papkasi nuqta bilan boshlanadi — ba'zi fayl menejerlarida yashirin bo'ladi.
   > Ko'rinmasa: `Ctrl+H` (Windows'da Explorer → View → Hidden items).

4. Repo'dagi **Actions** bo'limiga o'ting. "APK yig'ish" workflow avtomatik ishga tushadi.
   Yashil ✓ chiqishini kuting — **birinchi safar ~8–12 daqiqa**.
5. Repo'ning o'ng tomonidagi **Releases** bo'limiga o'ting → oxirgi release → **`app-release.apk`**.

### Talabalarga yuborish

Release sahifasidagi APK havolasi ommaviy — uni to'g'ridan-to'g'ri berish mumkin:

```
https://github.com/FOYDALANUVCHI/un-texnologiya/releases/latest
```

Yoki APK ni yuklab olib, **Telegram guruhiga fayl sifatida tashlang** (Telegram 2 GB gacha
faylni qabul qiladi, APK ~20 MB).

### Talaba nima qiladi

1. APK ni yuklab oladi → ochadi
2. Android: *"Xavfsizlik uchun bu manbadan ilova o'rnatish bloklangan"* → **Sozlamalar** →
   **"Chrome/Telegram uchun ruxsat berish"** → orqaga → **O'rnatish**
3. Ikonka paydo bo'ladi

### Keyingi yangilanishlar

Fayl o'zgartirib repo'ga commit qilsangiz — yangi APK **avtomatik** yig'iladi va
yangi Release chiqadi. Boshqa hech narsa qilmaysiz.

### Bonus: Web versiya ham avtomatik

Workflow'da GitHub Pages jobi ham bor. Repo → **Settings → Pages → Source: GitHub Actions**
ni tanlasangiz, Flutter web versiyasi ham avtomatik chiqadi:
`https://FOYDALANUVCHI.github.io/un-texnologiya/`

---

## C yo'li — O'z kompyuteringizda yig'ish

Agar kodni o'zgartirib, natijani darhol ko'rmoqchi bo'lsangiz — bu eng qulay yo'l.

```bash
# Bir marta: Flutter + Android Studio o'rnatish (~18 GB, 1–2 soat)
flutter doctor

# Har safar:
cd un_app
flutter create . --platforms=android,ios,web --org uz.qarshidtu
flutter pub get
flutter run                       # telefonda darhol ko'rish (hot reload bilan)

flutter build apk --split-per-abi  # tarqatish uchun
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk   (~9 MB)
```

`--split-per-abi` APK ni 25 MB dan 9 MB gacha kichraytiradi — `arm64-v8a` versiyasi
zamonaviy telefonlarning deyarli hammasiga to'g'ri keladi.

---

## Qaysi yo'lni tanlash

| Vaziyat | Yo'l |
|---|---|
| Talabalarga **bugun** kerak | **A** — Netlify havola |
| Haqiqiy APK kerak, lekin kompyuterga hech narsa o'rnatgim yo'q | **B** — GitHub Actions |
| Kodni o'zim o'zgartirib, ishlab chiqmoqchiman | **C** — lokal Flutter |
| iPhone'li talabalar ham bor | **A** (APK iPhone'da ishlamaydi) |

Xarajat: uchala yo'l ham **0 so'm**.

---

## Tez-tez uchraydigan muammolar

**"App not installed" xatosi** — telefonda eski versiya bor. Avval uni o'chiring,
keyin yangisini o'rnating.

**Play Protect ogohlantiradi** — imzolanmagan APK uchun normal holat.
"Baribir o'rnatish" (Install anyway) ni bosish kifoya.

**GitHub Actions qizil ✗ chiqdi** — Actions → oxirgi run → qaysi qadam qizil bo'lganini
ochib, xato matnini menga yuboring.

**Netlify havolasi chiroyli emas** — Netlify'da ro'yxatdan o'ting (bepul), keyin
Site settings → Change site name → `un-texnologiya` → `https://un-texnologiya.netlify.app`
