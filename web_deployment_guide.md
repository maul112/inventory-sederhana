# Panduan Deployment Flutter Web ke Firebase Hosting (Untuk Windows)

Panduan ini akan membantu Anda mengubah kode Flutter Anda menjadi aplikasi Web (Progressive Web App / PWA) dan mengunggahnya ke internet menggunakan Firebase Hosting agar bisa diakses dan di-install di iPhone.

---

## TAHAP 1: Build Flutter ke Web

Langkah pertama adalah menerjemahkan kode Dart Anda menjadi HTML, CSS, dan Javascript.

1. Buka terminal di dalam VS Code (pastikan Anda berada di dalam folder project `listing`).
2. Jalankan perintah berikut untuk memastikan dukungan Web sudah aktif di Flutter Anda:
   ```bash
   flutter config --enable-web
   ```
3. Lakukan proses *build* dengan menjalankan perintah ini:
   ```bash
   flutter build web --web-renderer canvaskit
   ```
   *(Catatan: `canvaskit` membuat performa animasi dan *rendering* web hampir sama mulusnya dengan aplikasi Android).*
4. Tunggu hingga proses selesai. Jika berhasil, akan muncul folder baru di dalam project Anda: `build/web/`. Di dalam folder inilah letak aplikasi Web Anda yang siap di-hosting.

---

## TAHAP 2: Persiapan Firebase CLI

Untuk mengunggah (hosting) file ke Firebase, kita membutuhkan *tool* bawaan Firebase.

1. Jika Anda belum menginstal **Node.js**, silakan download dan instal terlebih dahulu dari [nodejs.org](https://nodejs.org/).
2. Setelah Node.js terinstal, buka Terminal / Command Prompt baru.
3. Install Firebase CLI dengan perintah ini:
   ```bash
   npm install -g firebase-tools
   ```
4. Setelah instalasi selesai, hubungkan terminal dengan akun Google Anda:
   ```bash
   firebase login
   ```
   *Akan muncul pop-up di browser yang meminta Anda login ke akun Google. Pastikan login dengan akun Google yang memiliki project "listing-inventaris" tersebut.*

---

## TAHAP 3: Inisialisasi Firebase Hosting

Sekarang, kita harus memberi tahu Firebase bahwa folder project ini akan menggunakan fitur Hosting.

1. Kembali ke terminal VS Code di dalam folder project `listing`.
2. Jalankan perintah:
   ```bash
   firebase init hosting
   ```
3. Anda akan diberikan beberapa pertanyaan oleh Firebase (gunakan tombol panah atas/bawah untuk memilih dan Enter untuk OK):
   - **Please select an option**: Pilih `Use an existing project`
   - **Select a default Firebase project**: Pilih project Anda (contoh: `listing-inventaris`)
   - **What do you want to use as your public directory?**: Ketik `build/web` (LALU ENTER. Ini **sangat penting!**)
   - **Configure as a single-page app (rewrite all urls to /index.html)?**: Ketik `y` (LALU ENTER)
   - **Set up automatic builds and deploys with GitHub?**: Ketik `N` (LALU ENTER)
   - Jika ditanya *File build/web/index.html already exists. Overwrite?*: Ketik `N` (LALU ENTER)

Jika berhasil, akan ada pesan *Firebase initialization complete!*

---

## TAHAP 4: Mengunggah (Deploy) ke Internet

Tahap terakhir, mari kita unggah aplikasinya agar *live* di internet!

1. Jalankan perintah ini di terminal VS Code:
   ```bash
   firebase deploy --only hosting
   ```
2. Tunggu proses *upload* selesai.
3. Jika berhasil, Firebase akan memberikan sebuah URL. Biasanya bentuknya seperti ini:
   `https://listing-inventaris.web.app` atau `https://listing-inventaris.firebaseapp.com`

**Selesai! Aplikasi Anda sudah online!**

---

## TAHAP 5: Cara Install di iPhone Pengguna

Sekarang, aplikasi siap diinstal oleh teman/rekan Anda di iPhone-nya. Instruksikan langkah berikut kepadanya:

1. Copy link URL Firebase Hosting tadi dan kirimkan ke orang tersebut (via WhatsApp/Line).
2. Minta dia membuka link tersebut menggunakan aplikasi **Safari** di iPhone-nya.
3. Setelah website terbuka, minta dia menekan tombol **Share** (ikon kotak dengan panah ke atas yang letaknya di tengah bawah layar Safari).
4. Gulir menu ke bawah, lalu pilih **"Add to Home Screen"** atau **"Tambahkan ke Layar Utama"**.
5. Klik **Add (Tambah)** di sudut kanan atas.

Seketika aplikasi Inventaris Anda akan muncul di layar utama iPhone-nya dengan logo (ikon) aplikasi layaknya aplikasi yang di-download dari App Store. Ketika dia membukanya, aplikasi akan tampil *full-screen* (tidak terlihat seperti sedang membuka browser web).

> [!TIP]
> **Cara Update Aplikasi**
> Jika suatu saat Anda mengubah kode (misal menambah fitur baru), Anda cukup menjalankan 2 perintah ini saja secara berurutan:
> 1. `flutter build web --web-renderer canvaskit`
> 2. `firebase deploy --only hosting`
> 
> Pengguna di iPhone tidak perlu melakukan apa-apa. Saat dia menutup dan membuka kembali aplikasinya, otomatis akan mendapatkan versi terbaru!
