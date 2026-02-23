# 👁️ Glaucoma Detection System (Monorepo)

Sistem deteksi dini glaukoma menggunakan Deep Learning. Project ini mengintegrasikan Backend Laravel, Frontend React, Mobile Flutter, dan AI Service Flask ke dalam satu ekosistem terpadu.

---

## 🛠️ Persyaratan Sistem (Prerequisites)

Sebelum melakukan instalasi, pastikan laptopmu (khususnya pengguna Ubuntu/Debian) sudah terpasang:

- **PHP 8.3** & ekstensi (`php-pgsql`, `php-xml`, `php-curl`)
- **Node.js** v18 atau v20
- **Python 3.10+** & `pip`
- **PostgreSQL** (berjalan di port 5432)
- **Flutter SDK** (Channel stable)

---

## 📂 Arsitektur Folder

| Folder | Tech Stack | Fungsi |
| :--- | :--- | :--- |
| `backend/` | Laravel 11, PostgreSQL | Pusat data, API Auth, & Manajemen Pasien |
| `frontend/` | React, Vite, Tailwind | Dashboard Admin/Dokter untuk cek hasil deteksi |
| `mobile/` | Flutter | Aplikasi Pasien untuk scan mata mandiri |
| `ai-service/` | Flask, TensorFlow/OpenCV | Engine AI yang memproses klasifikasi glaukoma |

---

## 🚀 Langkah Instalasi Cepat

### 1. Backend API (Laravel)

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

> **Konfigurasi Database:** Buka file `.env`, sesuaikan `DB_DATABASE`, `DB_USERNAME`, dan `DB_PASSWORD`. Pastikan PostgreSQL sudah berjalan.

```bash
php artisan migrate
php artisan serve
```

---

### 2. Frontend Admin (React)

```bash
cd frontend
npm install
npm run dev
```

---

### 3. AI Service (Python/Flask)

```bash
cd ai-service
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python app.py
```

---

### 4. Mobile App (Flutter)

```bash
cd mobile
flutter pub get
flutter run
```

---

## 🛰️ Alur Komunikasi (Data Flow)

1. User/Admin upload gambar mata via Flutter atau React.
2. Laravel menerima file, menyimpannya di storage, dan mencatat data ke PostgreSQL.
3. Laravel mengirim request ke AI Service (Flask) melalui HTTP request.
4. AI Service memproses gambar dengan model `.h5` dan mengembalikan hasil klasifikasi (Glaukoma / Normal).
5. Laravel memperbarui database dan mengirimkan hasil kembali ke Frontend.

---

## ⚠️ Troubleshooting (Kendala Umum)

| Masalah | Solusi |
| :--- | :--- |
| **Error PostgreSQL di Laravel** | Install driver: `sudo apt install php8.3-pgsql` |
| **Error CORS di React** | Cek `backend/config/cors.php`, pastikan `'allowed_origins' => ['http://localhost:5173']` |
| **Python Library Error (OpenCV)** | Jalankan: `sudo apt install libgl1-mesa-glx` |
| **Git Submodule (folder abu-abu di GitHub)** | Hapus folder `.git` di dalam sub-folder, lalu push ulang |

---

## 🤝 Kontributor

| Nama | GitHub | Peran |
| :--- | :--- | :--- |
| Malakul Kabir Ar Rabbani | [@vexeeldev](https://github.com/vexeeldev) | Project Leader |
| Ahmad Syauqi Al-Farisi | [@Syauqi-men](https://github.com/Syauqi-men) | - |
| Ahmad Fikri Ramadhan | [@AhmadFikri17](https://github.com/AhmadFikri17)  | - |

---

<p align="center">
  Glaucoma Detection Project — PENS PSDKU Lamongan 2026 🎓
</p>

