# Panduan Lengkap & Final Setup Firebase + Google Sign-In di Flutter

Panduan ini disusun secara berurutan dan sangat detail untuk memastikan Anda terhindar dari *error* seperti `clientConfigurationError` atau `No Firebase App`. Lakukan langkah-langkah ini secara perlahan dan berurutan.

---

## TAHAP 1: Persiapan Kunci SHA (Sidik Jari Keamanan)
Kunci SHA wajib ada agar Google percaya bahwa aplikasi yang mencoba login benar-benar milik Anda.
1. Buka terminal di VSCode.
2. Ketik perintah berikut dan tekan Enter:
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. Tunggu prosesnya selesai. Scroll ke atas pada hasil terminal, cari bagian yang bertuliskan `Variant: debug` dan `Config: debug`.
4. Salin (Copy) kode **SHA1** dan **SHA-256** Anda ke Notepad.

---

## TAHAP 2: Registrasi di Firebase Console
1. Buka [Firebase Console](https://console.firebase.google.com/).
2. Buat project baru (misal: "InventarisTK").
3. Di halaman utama project, klik logo **Android** (atau pergi ke Project Settings > Add app > Android).
4. **Android package name:** Isi dengan `com.tk.listing`. *(Bisa dicek di `android/app/build.gradle.kts` pada bagian `applicationId`)*.
5. **App nickname:** Boleh dikosongkan.
6. **Debug signing certificate SHA-1:** Paste kode **SHA1** yang tadi Anda simpan di Notepad.
7. Klik **Register app**.

---

## TAHAP 3: Memasang `google-services.json`
Tahap ini paling sering menjadi sumber masalah jika salah penempatan.
1. Klik tombol biru **Download google-services.json**.
2. Buka folder/direktori proyek Flutter Anda.
3. Masukkan file tersebut **tepat** ke dalam folder: `listing/android/app/`.
   *(Bukan di folder `listing/android/`, melainkan di dalam folder `app`)*.
4. Pastikan nama filenya persis `google-services.json` (jangan sampai ada embel-embel angka seperti `google-services (1).json`).

---

## TAHAP 4: Mengatur `build.gradle` (Pengaturan Gradle)
Anda harus mengatur dua file Gradle agar Android bisa membaca JSON tadi.

**File Pertama: `android/build.gradle.kts` (Level Project)**
Tambahkan kode *plugins* ini di **baris paling atas**:
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.1" apply false
}

allprojects { ... }
```

**File Kedua: `android/app/build.gradle.kts` (Level App)**
Tambahkan plugin Google Services di dalam blok `plugins`:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Tambahkan baris di bawah ini:
    id("com.google.gms.google-services")
}
```

---

## TAHAP 5: Mengaktifkan Google Sign-In & Support Email (SANGAT KRUSIAL)
Ini adalah penyebab utama `ApiException` atau `clientConfigurationError`.
1. Kembali ke web Firebase Console.
2. Di menu kiri, pilih **Build > Authentication**.
3. Klik **Get Started**.
4. Pergi ke tab **Sign-in method**, lalu pilih **Google**.
5. Aktifkan *toggle* (sakelar) **Enable** di pojok kanan atas.
6. **Project support email:** Klik *dropdown* ini dan **wajib** pilih alamat email Anda. Jika dibiarkan kosong, Google Sign-In pasti akan gagal!
7. Klik **Save**.
8. Buka menu **Project settings** (Ikon Roda Gigi di kiri atas). Gulir ke bawah ke aplikasi Android Anda, dan pastikan **SHA-256** juga sudah ditambahkan. Jika belum, klik *Add fingerprint* dan masukkan SHA-256 dari Notepad tadi.

---

## TAHAP 6: Bersihkan Cache dan Jalankan
Karena Anda melakukan banyak perubahan konfigurasi sistem Android, fitur *Hot Reload* tidak akan berfungsi untuk membaca JSON yang baru.
1. Hentikan aplikasi yang sedang berjalan (tombol kotak merah *Stop* di VSCode).
2. **Uninstall/Hapus** aplikasi Inventaris dari Emulator Android / HP Anda sepenuhnya.
3. Buka Terminal VSCode, pastikan Anda berada di folder utama `listing/`, lalu jalankan:
   ```bash
   flutter clean
   flutter pub get
   ```
4. Pastikan Anda memilih target perangkat **Android Emulator** (bukan Windows/Web).
5. Jalankan aplikasi dari awal (`flutter run` atau tekan F5).

Jika keenam tahap ini diikuti tanpa ada yang terlewat, fitur Google Sign-In Anda dijamin 100% akan berhasil!

---

## TAHAP 7: Konfigurasi Khusus untuk iOS (Jika Anda menggunakan Mac)

Jika Anda ingin menjalankan aplikasi ini di iPhone/iOS, Anda harus melakukan konfigurasi iOS. **Perhatian:** *Aplikasi iOS hanya bisa di-build/dijalankan menggunakan komputer Mac.*

### Opsi A: Cara Otomatis (Sangat Disarankan)
Cara termudah adalah menggunakan `flutterfire configure`. Alat ini otomatis menarik file `.plist` dari Firebase ke dalam Xcode.
1. Buka Terminal VSCode.
2. Jalankan perintah:
   ```bash
   flutterfire configure
   ```
3. Saat ditanya *platform*, gunakan tombol Spasi untuk mencentang **ios** (pastikan `android` juga tercentang). Tekan Enter.
4. Selesai! `firebase_options.dart` Anda akan secara otomatis mengenali iOS.

### Opsi B: Cara Manual (Menggunakan Xcode)
Jika Opsi A gagal atau Anda ingin menambahkan Google Sign-In secara manual:
1. Buka Firebase Console, klik **Add app**, lalu pilih **iOS**.
2. Masukkan **iOS bundle ID** Anda (contoh: `com.tk.listing`). Anda bisa melihatnya dengan membuka folder `ios` di Xcode.
3. Unduh file **`GoogleService-Info.plist`**.
4. Buka aplikasi **Xcode** di Mac, lalu buka file `Runner.xcworkspace` di dalam folder `ios`.
5. *Drag and drop* (Tarik dan lepas) file `GoogleService-Info.plist` ke dalam folder `Runner` **di dalam jendela aplikasi Xcode**. Jangan ditaruh langsung menggunakan Finder/VSCode, karena tidak akan terdaftar di registry Xcode.
6. Centang opsi **"Copy items if needed"** dan klik Finish.

### Pengaturan Google Sign-In (Wajib untuk iOS)
Agar proses Login via Google tidak error (`clientConfigurationError`) di iOS:
1. Buka file `ios/Runner/Info.plist`.
2. Temukan nilai **`REVERSED_CLIENT_ID`** di dalam file `GoogleService-Info.plist` (contoh nilainya: `com.googleusercontent.apps.12345-abcde...`).
3. Tambahkan kode blok XML berikut ini ke bagian paling bawah file `Info.plist` (tepat sebelum tag `</dict>` penutup terakhir), lalu ganti teks di dalamnya dengan `REVERSED_CLIENT_ID` Anda:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Ganti teks di bawah ini dengan REVERSED_CLIENT_ID Anda -->
      <string>ISI_DENGAN_REVERSED_CLIENT_ID_ANDA</string>
    </array>
  </dict>
</array>
```
4. Buka terminal VSCode, masuk ke direktori ios (`cd ios`), lalu jalankan `pod install`.
