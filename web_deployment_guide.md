# Panduan Deployment Flutter Web ke Firebase Hosting (Untuk Windows)

Panduan ini akan membantu Anda mengubah kode Flutter Anda menjadi aplikasi Web (Progressive Web App / PWA) dan mengunggahnya ke internet menggunakan Firebase Hosting agar bisa diakses dan di-install di iPhone.

---

## TAHAP 1: Konfigurasi Otomatis (GitHub Actions)

Anda tidak perlu mem-build atau meng-upload aplikasi secara manual lagi dari laptop Anda. Semua akan dikerjakan oleh robot GitHub setiap kali Anda melakukan "push" kode.

1. Buka terminal di dalam VS Code (pastikan Anda berada di folder `listing`).
2. Jalankan perintah ini (hanya perlu dilakukan SATU KALI untuk mengaktifkan Firebase):
   ```bash
   firebase init hosting:github
   ```
3. Jawab pertanyaan di terminal dengan format berikut:
   - **For which GitHub repository would you like to set up a GitHub workflow?**: `username_anda/nama_repository` (contoh: `maul112/inventory-sederhana`)
   - **Set up the workflow to run a build script before every deploy?**: `y`
   - **What script should be run before every deploy?**: `flutter pub get && flutter build web`
   - **Set up automatic deployment to your site's live channel when a PR is merged?**: `y`
   - **What is the name of the GitHub branch associated with your site's live channel?**: `main`

---

## TAHAP 2: Deploy ke Internet (Sangat Mudah)

Sekarang, setiap kali Anda selesai mengubah kode (misal memperbaiki error atau menambah fitur), Anda cukup melakukan perintah Git normal untuk meng-upload perubahan ke internet:

```bash
git add .
git commit -m "Deskripsi perubahan Anda"
git push origin main
```

**Selesai!** 
Robot GitHub akan otomatis menginstal Flutter dan mem-build kode Anda di *cloud*. Tunggu sekitar 2-4 menit, dan aplikasi Web Anda akan ter-update otomatis di link Firebase Anda (contoh: `https://listing-inventaris.web.app`).

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
