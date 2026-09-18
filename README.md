# Hermes Agent — OMP Enhanced Edition (by Zuhri)

Distribusi konfigurasi, core behavioral prompt (`SOUL.md`), dan modul skill **Hermes Agent** (oleh Nous Research) yang telah dioptimasi dengan disiplin rekayasa software dan mode kerja **Oh My Pi (OMP)**.

Repositori ini memungkinkan siapa pun memasang dan menggunakan Hermes Agent persis seperti konfigurasi operasional harian yang digunakan oleh Zuhri.

---

## 🚀 Mengapa Adaptasi OMP (Oh My Pi)?

`oh-my-pi` (karya `can1357`) adalah AI coding agent berbasis terminal dengan performa native dan disiplin eksekusi sekelas IDE. Melalui repositori ini, prinsip dan alur kerja OMP ditanamkan langsung ke inti kepribadian dan sistem skill Hermes Agent:

1. **User's Word is Absolute (Ground Truth)**
   Kondisi error, anomali, atau fakta yang dilaporkan user dijadikan kebenaran mutlak. Hermes tidak memboroskan pemanggilan tool hanya untuk mengecek ulang hal yang sudah Anda laporkan.
2. **Zero Stubs & Clean Cutover**
   Pantang meninggalkan placeholder, mock parsial, atau komentar `// TODO: implement later`. Semua kode diselesaikan secara utuh (*end-to-end*) sampai modul pemanggilnya (*callsites*) dan membersihkan sisa kode mati.
3. **Snapshot Integrity & Precision Patching**
   Setiap edit menggunakan penanda konteks unik. Jika terjadi pergeseran baris atau kegagalan patch, Hermes membaca ulang isi file terbaru sebelum menyusun patch baru.
4. **Batched Tool Execution**
   Pemanggilan tool independen (read file, search, run test) dieksekusi secara paralel dalam satu giliran untuk memangkas latensi round-trip dan menghemat token.
5. **Deliverable Proof & Empirical Smoke Tests**
   Hermes tidak menyatakan tugas selesai sebelum benar-benar menjalankan program dan membuktikannya lewat output eksekusi nyata di runtime.

---

## ⚡ Fitur & Mode Kerja OMP yang Diadaptasi

| Mode / Fitur | Deskripsi & Implementasi di Hermes |
|---|---|
| **Vibe Mode (`/vibe`)** | Mode eksekusi berkecepatan tinggi: memangkas tahap seremonial blueprint/TODO berlebih untuk tugas langsung, langsung membaca, memodifikasi, dan menguji kode. |
| **Autonomous Loop (`/loop`)** | Siklus otomasi *Diagnose → Edit → Test* menggunakan runner `scripts/loop_runner.py` (`--until '<cmd>'`) hingga perintah uji menghasilkan exit status `0`. |
| **Advisor Mode (`/advisor`)** | Protokol review model kedua via `delegate_task` sebelum modifikasi skema database atau refactor arsitektur besar untuk mencegat regresi dan bug. |
| **Extended Context (512K)** | Optimasi ambang batas kompresi (`threshold: 0.8`, `protect_last_n: 40`) untuk retensi konteks masif tanpa pemotongan riwayat dini. |
| **Web Dashboard (Port 9119)** | Antarmuka web penuh Hermes untuk live chat, manajemen sesi, konfigurasi MCP, dan analitik token via `http://localhost:9119`. |
| **Collab & Multi-Surface** | Kolaborasi antar-antarmuka secara simultan (CLI Terminal, Web UI, dan Messaging Gateway seperti Telegram/Discord) dengan sinkronisasi database lokal. |
| **Skillful** | Manajemen skill cerdas: injeksi katalog ringkas di system prompt dan pemuatan konten skill penuh secara dinamis saat dibutuhkan. |

---

## 📦 Kumpulan Skill yang Disertakan

- **`autonomous-ai-agents/omp-workflows`**: Protokol operasional untuk Vibe, Loop, Advisor, Extended Context, dan script `loop_runner.py`.
- **`software-development/agentic-coding-discipline`**: Pedoman modifikasi kode presisi, hash-anchoring mindset, dan verifikasi runtime.
- **`software-development/shadcn-ui-bootstrap` & `shadcn-ui-patterns`**: Alur setup otomatis shadcn/ui dan aturan desain UI modern.
- **`software-development/web-ssr-hydration-debugging`**: Penanganan bug SSR hydration, form state, dan filter searchable.
- **`software-development/nextjs-classroom-api`**: Arsitektur realtime API aman, token hashing, dan mitigasi DoS relay.
- **`autonomous-ai-agents/hermes-mcp-cross-platform`**: Sinkronisasi MCP server antara environment Windows dan Linux/WSL.

---

## 🛠️ Cara Pemasangan Cepat (Quick Start)

### 1. Prasyarat
- Sistem operasi: Linux, WSL (Windows Subsystem for Linux), atau macOS.
- Python 3.10+
- Node.js 20+ & npm

### 2. Clone & Jalankan Setup
Jalankan perintah berikut di terminal Anda:

```bash
git clone https://github.com/syihab-zuhri/hermes-by-zuhri.git
cd hermes-by-zuhri
chmod +x setup.sh
./setup.sh
```

Skrip `setup.sh` akan secara otomatis:
- Memeriksa instalasi Hermes Agent (mengunduh jika belum ada).
- Menanamkan `SOUL.md` (prinsip OMP) ke `~/.hermes/SOUL.md`.
- Menyalin seluruh custom skills ke `~/.hermes/skills/`.
- Menerapkan konfigurasi Extended Context (512K) dan guardrails.
- Menyiapkan template konfigurasi dan environment `.env`.

### 3. Masukkan Kredensial LLM
Buka file `~/.hermes/.env` dan tambahkan API key Anda:
```bash
nano ~/.hermes/.env
```
Contoh pengisian:
```env
OPENAI_API_KEY=sk-...
```

---

## 🖥️ Menjalankan Hermes

### Interaktif di Terminal (CLI)
```bash
hermes
```

### Membuka Web Dashboard
Jalankan server dashboard di background:
```bash
hermes dashboard --skip-build --no-open --port 9119
```
Lalu buka browser Anda di:
👉 **`http://localhost:9119`**

---

## 📁 Struktur Direktori Repositori

```
hermes-by-zuhri/
├── README.md               # Dokumentasi lengkap
├── LICENSE                 # Lisensi MIT
├── SOUL.md                 # Core behavioral prompt & prinsip OMP
├── setup.sh                # Skrip instalasi & bootstrap otomatis
├── config/
│   ├── config.example.yaml # Template konfigurasi optimal Hermes
│   └── .env.example        # Template variabel lingkungan
└── skills/                 # Modul skill kustom & adaptasi OMP
    ├── autonomous-ai-agents/
    │   ├── omp-workflows/
    │   │   ├── SKILL.md
    │   │   └── scripts/loop_runner.py
    │   └── hermes-mcp-cross-platform/
    └── software-development/
        ├── agentic-coding-discipline/
        ├── shadcn-ui-bootstrap/
        ├── shadcn-ui-patterns/
        ├── web-ssr-hydration-debugging/
        └── nextjs-classroom-api/
```

---

## 📜 Lisensi
Didistribusikan di bawah lisensi [MIT](LICENSE). Terbuka untuk digunakan dan dikembangkan kembali.
