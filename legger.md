# Rekap Legger Tahfiz & Tahsin — Implementation Plan

## Overview

Fitur ini menambahkan jenis catatan baru bernama **Legger** (rekap nilai tahfiz & tahsin) ke dalam aplikasi, sekaligus **menghapus jenis "Lainnya"**. Fitur ini terpisah sepenuhnya dari sistem inventaris barang yang sudah ada.

---

## Perubahan Utama

### 1. Hapus Jenis "Lainnya"

- Hapus `InventoryCategory.other` dari enum
- Hapus model `other_inventory.dart`
- Hapus referensi di `inventory_controller.dart`, `add_item_page.dart`, `export_controller.dart`, `home_page.dart`
- Hapus `OtherInventory` fallback di `inventory_record.dart`

---

### 2. Tambah Jenis "Legger" (Rekap Tahfiz & Tahsin)

Sistem **Legger** adalah entitas terpisah dari inventaris. Setelah user membuat catatan bertipe `legger`, halaman detailnya berbeda: berisi 3 menu utama.

---

## Alur Pengguna (User Flow)

```
HomePage (Buat Catatan)
  └── Pilih Jenis: Kelas B | Kantor | Legger
        ↓ (jika Legger)
LeggerDetailPage
  ├── Menu 1: Kelola Siswa (CRUD: Nama, NISN opsional)
  ├── Menu 2: Kelola Surah (CRUD: nama surah)
  ├── Menu 3: Kelola Komponen Penilaian (3 Tahsin + 3 Tahfiz, flexibel)
  └── Tabel Nilai: masing-masing siswa × masing-masing surah × semua komponen
        └── Klik siswa → Halaman Input Nilai per Surah
              └── Form nilai per komponen
  └── Tombol Ekspor Excel → file .xlsx dengan format legger
```

---

## Firebase Database Schema (Baru)

```
legger/{userId}/{recordId}/
  ├── students/{studentId}
  │     ├── name: "Ahmad Fauzi"
  │     └── nisn: "1234567890" (opsional)
  ├── surahs/{surahId}
  │     └── name: "Al-Fatihah"
  ├── components/
  │     ├── tahsin/{compId}
  │     │     └── name: "Makhraj"
  │     └── tahfiz/{compId}
  │           └── name: "Kelancaran"
  └── grades/{studentId}/{surahId}/{compType}/{compId}
        └── value: 85 (angka, bisa kosong)
```

---

## Keputusan Desain (Sudah Dikonfirmasi)

- **Alur nilai:** Klik siswa → daftar surah → input nilai per komponen
- **Format nilai input:** Angka **1–20** per komponen
- **Format nilai rekap Excel:** Nilai × 5 = **1–100**
- **Rata-rata:** Dihitung otomatis per Tahsin dan per Tahfiz (rata-rata semua komponen ×5)
- **Komponen default saat buat Legger:**
  - Tahsin: *Makhraj, Tajwid, Kelancaran Baca*
  - Tahfiz: *Kelancaran Hafalan, Muraja'ah, Fashahah*
  - (Semua dapat di-CRUD)

---

## Proposed Changes

### A. Models (Baru)

#### [MODIFY] `inventory_item.dart`
- Tambah `legger` ke enum `InventoryCategory`
- Hapus `other`

#### [DELETE] `other_inventory.dart`

#### [NEW] `lib/models/legger/student.dart`
```dart
class Student { id, name, nisn }
```

#### [NEW] `lib/models/legger/surah.dart`
```dart
class Surah { id, name }
```

#### [NEW] `lib/models/legger/grading_component.dart`
```dart
class GradingComponent { id, name, type } // type: 'tahsin' | 'tahfiz'
```

#### [NEW] `lib/models/legger/grade_entry.dart`
```dart
class GradeEntry { studentId, surahId, componentId, value }
```

---

### B. Controllers (Baru)

#### [NEW] `lib/controllers/legger_controller.dart`
Bertanggung jawab atas:
- Stream semua siswa, surah, komponen, dan nilai untuk `recordId` yang aktif
- CRUD: `addStudent`, `updateStudent`, `deleteStudent`
- CRUD: `addSurah`, `updateSurah`, `deleteSurah`
- CRUD: `addComponent`, `updateComponent`, `deleteComponent`
- CRUD: `setGrade(studentId, surahId, componentId, value)`
- Export: `exportToExcel(...)` → format legger

#### [MODIFY] `lib/controllers/inventory_controller.dart`
- Hapus referensi `OtherInventory` dan `InventoryCategory.other`

#### [MODIFY] `lib/controllers/export_controller.dart`
- Hapus referensi `OtherInventory`

---

### C. UI Pages (Baru & Modifikasi)

#### [NEW] `lib/ui/legger/legger_detail_page.dart`
Halaman utama setelah memilih catatan bertipe Legger. Berisi 3 kartu menu:
1. **Kelola Siswa** → `StudentManagePage`
2. **Kelola Surah** → `SurahManagePage`
3. **Kelola Komponen Penilaian** → `ComponentManagePage`
4. **Tombol: Lihat/Input Nilai** → `GradeEntryPage`
5. **Tombol AppBar: Export Excel**

#### [NEW] `lib/ui/legger/student_manage_page.dart`
Daftar siswa dengan CRUD. Tiap siswa punya field: Nama + NISN (opsional).

#### [NEW] `lib/ui/legger/surah_manage_page.dart`
Daftar surah dengan CRUD. Hanya 1 field: Nama Surah.

#### [NEW] `lib/ui/legger/component_manage_page.dart`
Daftar komponen penilaian dengan 2 tab: **Tahsin** dan **Tahfiz**. CRUD nama komponen per tab.

#### [NEW] `lib/ui/legger/grade_entry_page.dart`
- Menampilkan daftar siswa
- Klik siswa → halaman input nilai per surah
- Tiap surah memiliki form input nilai per komponen (Tahsin & Tahfiz)

#### [MODIFY] `lib/ui/record_detail_page.dart`
- Jika category == `legger` → redirect ke `LeggerDetailPage`
- Jika category lain → tampilan inventaris seperti sekarang

#### [MODIFY] `lib/ui/home_page.dart`
- Hapus `other` dari pilihan jenis
- Tambah `legger` ke pilihan jenis

#### [MODIFY] `lib/ui/add_item_page.dart`
- Hapus bagian form untuk `InventoryCategory.other`

#### [MODIFY] `lib/main.dart`
- Tambah route baru untuk semua halaman legger

---

### D. Format Export Excel

Berdasarkan gambar yang Anda lampirkan, format Excel yang akan dihasilkan:

**Baris 1:** Judul Catatan (merge all columns)  
**Baris 2:** No | Nama | NISN | [Surah 1 — merge (nTahsin+avg)+(nTahfiz+avg) cols] | [Surah 2...] | ...  
**Baris 3:** | | | Tahsin (merge n+1) | Tahfiz (merge n+1) | Tahsin | Tahfiz | ...  
**Baris 4:** | | | Makhraj | Tajwid | Kel. Baca | Rata2 | Kel. Hafalan | Muraja'ah | Fashahah | Rata2 | ...  
**Baris 5+:** 1 | Ahmad | 123 | 16→80 | 18→90 | 17→85 | 85.0 | 15→75 | 19→95 | 16→80 | 83.3 | ...  

> [!NOTE]
> Nilai ditampilkan sebagai hasil ×5 (misalnya input 16 → tampil 80). Rata-rata dihitung dari nilai ×5 tersebut.

---

## Verification Plan

### Automated Build Check
```
flutter build apk --debug
```

### Manual Verification
1. Buat catatan baru → pilih "Legger"
2. Tambah minimal 2 siswa, 2 surah, set komponen
3. Input nilai beberapa siswa
4. Klik Export → file .xlsx terbuka dengan format yang benar
5. Pastikan jenis "Lainnya" sudah hilang dari pilihan
