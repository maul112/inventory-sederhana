# Rencana Implementasi Aplikasi Inventaris Flutter (Bahasa Indonesia)

## Deskripsi Tujuan
Membuat aplikasi Flutter modern dan mudah digunakan untuk guru TK dalam mencatat inventaris barang. Aplikasi akan mendukung beberapa jenis inventaris (kelas B, kantor, dan kategori lain yang dapat ditambah di masa depan), otentikasi Google Sign‑In, penyimpanan data menggunakan Cloud Firestore (bukan Realtime Database), serta manajemen state dengan GetX.

## Review Pengguna Diperlukan
> [!IMPORTANT]
> Silakan tinjau model data dan alur navigasi UI. Konfirmasi pilihan skema warna, preferensi mode gelap/terang, serta aset branding (logo) jika ada.

## Keputusan Desain
- **Palet warna**: dapat diubah-ubah oleh pengguna melalui pengaturan tema (pilihan warna dinamis).
- **Sinkronisasi**: aplikasi akan mendukung mode online dengan kemampuan cache offline menggunakan Firestore offline persistence.
- **Akses**: satu peran saja yaitu pencatat inventaris (tanpa perbedaan admin).
- **Logo**: akan ditambahkan kemudian.
- Palet warna utama yang diinginkan (misalnya teal, indigo, atau lainnya)?
- Apakah aplikasi perlu mendukung sinkronisasi offline atau hanya online?
- Apakah diperlukan akses berbasis peran (admin vs. pengguna biasa) atau cukup satu tingkat akses?
- Apakah ada logo atau gambar khusus yang ingin dimasukkan?

## Perubahan yang Diusulkan

### Alur Navigasi UI
- **Login** → setelah berhasil, arahkan ke halaman pemilihan jenis inventaris.
- **Pilih Jenis Inventaris** → user memilih kategori (kelas B, kantor, atau lainnya) dan masuk ke halaman **Listing**.
- **Listing (CRUD)** → menampilkan data inventaris dengan kemampuan tambah, ubah, hapus.
- **Export Excel** → tombol pada app bar untuk mengekspor data list ke file .xlsx.
- Semua halaman mendukung **mode gelap** melalui `ThemeController`.
- **Logo** akan ditambahkan kemudian.

---
---
### Struktur Proyek
- **[NEW]** `flutter_inventory_app/` – folder root proyek Flutter (sudah Anda buat).
- **[NEW]** `pubspec.yaml` – tambahkan dependensi:
  ```yaml
  dependencies:
    flutter:
      sdk: flutter
    get: ^4.6.5
    firebase_core: ^2.15.0
    cloud_firestore: ^4.8.0
    firebase_auth: ^4.7.0
    google_sign_in: ^6.1.0
    flutter_svg: ^2.0.7
    intl: ^0.18.0
  ```

### Konfigurasi Firebase
- **[NEW]** `android/app/google-services.json` & `ios/Runner/GoogleService-Info.plist` (akan Anda sediakan).
- Inisialisasi Firebase di `main.dart`.

### Otentikasi
- **[NEW]** Direktori `auth/`:
  - `auth_controller.dart` (GetX controller untuk Google Sign‑In & FirebaseAuth).
  - UI: `login_page.dart` dengan tombol masuk bergaya glass‑morphism.

### Model Data
- **[NEW]** Direktori `models/`:
  - `inventory_item.dart` – kelas dasar dengan field umum: `nama`, `jumlah`, `kondisi`, `sumberDana`.
  - `class_inventory.dart` memperluas `InventoryItem` menambah `namaKelas`.
  - `office_inventory.dart` memperluas `InventoryItem` menambah `jumlahSisa`.
  - Enum `InventoryCategory { kelasB, kantor, lainnya }` untuk memudahkan penambahan kategori di masa depan.

### Manajemen State (GetX)
- **[NEW]** Direktori `controllers/`:
  - `inventory_controller.dart` – menyimpan `RxList<InventoryItem>` per kategori, serta CRUD yang berinteraksi dengan Firestore.
  - `category_controller.dart` – mengelola kategori yang dipilih saat menambah data.

### Komponen UI
- **[NEW]** Direktori `ui/`:
  - `home_page.dart` – menampilkan kartu tiap kategori inventaris dan FAB untuk menambah barang.
  - `add_item_page.dart` – formulir dinamis yang berubah sesuai kategori yang dipilih (dropdown pilih kategori, kemudian tampilkan field yang relevan).
  - `item_tile.dart` – komponen reusable menampilkan detail barang dengan tombol edit/hapus.
  - `theme.dart` – skema warna modern, container glass‑morphism, dan Google Font *Inter*.
  - `widgets/` – komponen umum (tombol melengkung, dropdown, chip kondisi).

### Navigasi
- Menggunakan `GetMaterialApp` dengan routing bernama: `/login`, `/home`, `/addItem`.

### Struktur Firestore
```
inventories (koleksi)
  └── <userId> (dokumen)
        └── <kategori> (sub‑koleksi)   // contoh: kelasB, kantor, lainnya
              └── <itemId> (dokumen)
                    - nama: string
                    - jumlah: int
                    - kondisi: string ("Layak" / "Rusak")
                    - sumberDana: string ("BOP" / "Sekolah")
                    - field tambahan sesuai kategori
```
---
### Rencana Verifikasi
- **Tes Otomatis**: Unit test untuk `InventoryController` menggunakan paket `flutter_test`.
- **Verifikasi Manual**:
  1. Masuk dengan Google – pastikan alur otentikasi berjalan di Android & iOS.
  2. Tambah barang untuk tiap kategori – periksa bahwa data tersimpan di Firestore dengan field yang tepat.
  3. Edit & hapus barang – pastikan UI terupdate secara real‑time melalui observables GetX.
  4. Ganti tema perangkat – pastikan UI modern tetap responsif dan tampak bagus.

### Estimasi Waktu (kasar)
1. Scaffold proyek & dependensi – 1 jam
2. Inisialisasi Firebase & alur otentikasi – 2 jam
3. Model data & layanan Firestore – 1,5 jam
4. Controller GetX – 1 jam
5. Layar UI & formulir dinamis – 3 jam
6. Styling, animasi, polish – 2 jam
7. Pengujian & perbaikan bug – 2 jam
### Fitur Export ke Excel
- Tambahkan tombol export pada halaman list inventory.
- Gunakan paket `excel` atau `syncfusion_flutter_xlsio` untuk menghasilkan file .xlsx.
- Simpan file ke penyimpanan perangkat atau bagikan via share intent.
- Implementasi service di `export_controller.dart` yang mengambil data Firestore dan menulis ke Excel.
- Pastikan data yang diekspor mengikuti struktur kolom sesuai kategori.

---
*Rencana ini siap untuk ditinjau. Setelah Anda menyetujuinya, saya akan membuat `task.md` dan memulai implementasi.*
