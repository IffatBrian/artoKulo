# artoKulo — Aplikasi Catatan Keuangan Pribadi (Flutter + Firebase)

## Setup Firebase
Konfigurasi Firebase untuk Android dan Web sudah dibuat untuk project `sgtenang-130209`.
`main.dart` memakai `firebase_options.dart` untuk memilih konfigurasi sesuai platform.

1. Pastikan **Authentication → Sign-in method → Email/Password** aktif.
2. Pastikan Cloud Firestore sudah dibuat dan terapkan security rules di bawah.
3. Jalankan `flutter pub get`, lalu `flutter run` (Android) atau `flutter run -d chrome` (Web).

Jika memakai project Firebase lain, jalankan `flutterfire configure` dari folder proyek
dan pilih platform yang digunakan. Jangan membagikan service-account key atau kredensial
server; file konfigurasi aplikasi di sini berisi konfigurasi client Firebase.

## Struktur Firestore (hirarki)
```
users (collection)
 └─ {uid} (document)            name, email, uid, createdAt
     └─ transactions (sub-collection)
         └─ {txId} (document)   title, amount, type(income|expense), note, date, createdAt
```

## Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
      match /transactions/{txId} {
        allow read, write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```

## Fitur
- Splash (logo) → Login / Register (FirebaseAuth) → profil tersimpan di `users/{uid}`
- Header menampilkan nama pemilik akun; Logout dengan dialog konfirmasi
- Dasbor: ucapan selamat datang, total saldo, total transaksi, grafik batang 7 hari (fl_chart), riwayat real-time (StreamBuilder, urut tanggal terbaru)
- CRUD transaksi: tambah, lihat detail, ubah nominal/catatan, hapus (dengan konfirmasi)
- Tampilan mengikuti DESIGN.md: Plus Jakarta Sans, Serene Blue `#1D72B8`, radius 24/16/8, bayangan ambient, hero card gradient.
