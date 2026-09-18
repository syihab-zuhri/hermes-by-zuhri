# Hermes Agent — OMP Enhanced Edition (by Zuhri)

Distribusi konfigurasi, core behavioral prompt (`SOUL.md`), sistem skill rekayasa perangkat lunak, dan modernisasi UI/UX **Hermes Agent** (oleh Nous Research) yang diadaptasi dari filosofi eksekusi **Oh My Pi (OMP)** dan preset desain **shadcn `b1ZzrZbpw` (Mira Style)**.

Repositori ini memungkinkan siapa pun mereplikasi konfigurasi operasional harian yang digunakan oleh Zuhri ke mesin Linux/WSL/macOS mereka secara otomatis.

---

## 🚀 Filosofi Rekayasa OMP (Oh My Pi)

`oh-my-pi` (karya `can1357`) adalah AI coding agent berbasis terminal dengan performa native dan disiplin eksekusi sekelas IDE. Melalui repositori ini, prinsip dan alur kerja OMP ditanamkan langsung ke inti kepribadian dan sistem skill Hermes Agent:

1. **User's Word is Absolute (Ground Truth)**
   Kondisi error, anomali, atau fakta yang dilaporkan user dijadikan kebenaran mutlak. Hermes tidak memboroskan pemanggilan tool hanya untuk mengecek ulang hal yang sudah dilaporkan.
2. **Zero Stubs & Clean Cutover**
   Pantang meninggalkan placeholder, mock parsial, atau komentar `// TODO: implement later`. Semua kode diselesaikan secara utuh (*end-to-end*) sampai modul pemanggilnya (*callsites*) dan membersihkan sisa kode mati.
3. **Snapshot Integrity & Precision Patching**
   Setiap edit menggunakan penanda konteks unik. Jika terjadi pergeseran baris atau kegagalan patch, Hermes membaca ulang isi file terbaru sebelum menyusun patch baru.
4. **Batched Tool Execution**
   Pemanggilan tool independen (read file, search, run test) dieksekusi secara paralel dalam satu giliran untuk memangkas latensi round-trip dan menghemat token.
5. **Deliverable Proof & Empirical Smoke Tests**
   Hermes tidak menyatakan tugas selesai sebelum benar-benar menjalankan program dan membuktikannya lewat output eksekusi nyata di runtime.

---

## 🎨 Modernisasi UI/UX Dashboard (Preset shadcn `b1ZzrZbpw` / Mira Style)

Hermes Web Dashboard bawaan memiliki gaya visual retro-brutalist dengan font pixelated (*Mondwest*), sudut poligon terpotong (*notched clip-path*), dan teks kapital yang kaku. Repositori ini menyertakan modernisasi UI/UX penuh berbasis preset **shadcn `b1ZzrZbpw`**:

- **Tipografi Inter & JetBrains Mono:** Seluruh antarmuka beralih ke font **Inter** yang bersih, modern, dan nyaman dibaca, dipadukan dengan **JetBrains Mono** untuk terminal dan blok kode.
- **Lengkungan Halus (Smooth Radius `0.625rem`):** Menghilangkan efek notched sudut kasar pada header, sidebar, card, dan modal dialog, digantikan dengan sudut rounded modern.
- **Navigasi Pill Lembut:** Sidebar navigasi mengadopsi pill button dengan efek hover dan active state subtil (*subtle menu accent*).
- **Integritas Palet Warna:** Skema warna gelap khas Hermes tetap dipertahankan 100% tanpa merusak kontras visual.

---

## ⚡ Fitur & Mode Kerja OMP yang Diadaptasi

| Mode / Fitur | Deskripsi & Implementasi di Hermes |
|---|---|
| **Vibe Mode (`/vibe`)** | Mode eksekusi berkecepatan tinggi: memangkas seremonial blueprint/TODO berlebih untuk tugas langsung; langsung membaca, memodifikasi, dan menguji kode. |
| **Autonomous Loop (`/loop`)** | Siklus otomasi *Diagnose → Edit → Test* menggunakan runner `scripts/loop_runner.py` (`--until '<cmd>'`) hingga perintah uji menghasilkan exit status `0`. |
| **Advisor Mode (`/advisor`)** | Protokol review model kedua via `delegate_task` sebelum modifikasi skema database atau refactor arsitektur besar untuk mencegat regresi dan bug. |
| **Extended Context (512K)** | Optimasi ambang batas kompresi (`threshold: 0.8`, `protect_last_n: 40`) untuk retensi konteks masif tanpa pemotongan riwayat dini. |
| **Auto-start Web Dashboard (Port 9119)** | Daemon otomatis (`hermes-dashboard-daemon`) yang langsung menyalakan server web dashboard di latar belakang setiap kali perintah `hermes` dipanggil di terminal, lengkap dengan banner URL. |
| **Collab & Multi-Surface** | Kolaborasi antar-antarmuka secara simultan (CLI Terminal, Web UI, dan Messaging Gateway seperti Telegram/Discord) dengan sinkronisasi database lokal. |
| **Skillful** | Manajemen skill cerdas: injeksi katalog ringkas di system prompt dan pemuatan konten skill penuh secara dinamis saat dibutuhkan. |

---

## 📦 Kumpulan Skill yang Disertakan

- **`autonomous-ai-agents/omp-workflows`**: Protokol operasional untuk Vibe, Loop, Advisor, Extended Context, dan script `loop_runner.py`.
- **`software-development/agentic-coding-discipline`**: Pedoman modifikasi kode presisi, hash-anchoring mindset, dan verifikasi runtime.
- **`software-development/ast-grep-code-surgery`**: Pencarian dan modifikasi kode berbasis AST (Abstract Syntax Tree) via `ast-grep` (imun terhadap spasi/format drift, ekstrak arsitektur proyek hemat 90% token).
- **`software-development/threat-aware-security-engineering`**: Protokol triage malware defensif, audit supply-chain, deobfuscation static analysis, dan pemeriksaan persistensi sistem (diadaptasi dari kurasi *awesome-malware-analysis*).
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
1. Memeriksa instalasi Hermes Agent (mengunduh otomatis jika belum ada).
2. Menanamkan `SOUL.md` (prinsip OMP) ke `~/.hermes/SOUL.md`.
3. Menyalin seluruh custom skills ke `~/.hermes/skills/`.
4. Menerapkan konfigurasi Extended Context (512K) dan guardrails.
5. Memasang daemon auto-start dashboard (`~/.local/bin/hermes-dashboard-daemon`) dan banner notifikasi di `~/.bashrc`.
6. Menerapkan preset UI/UX Mira (`ui-preset-mira`) dan me-rebuild dashboard web secara otomatis.
7. Menyiapkan template konfigurasi dan environment `.env`.

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
Cukup ketik:
```bash
hermes
```
Saat perintah dijalankan, banner aktif akan muncul di atas chat dan server web dashboard otomatis menyala di background:
```text
┌────────────────────────────────────────────────────────────┐
│  🌐 Hermes Web Dashboard aktif: http://localhost:9119      │
└────────────────────────────────────────────────────────────┘
```

### Membuka di Browser
Buka browser Anda dan kunjungi:
👉 **`http://localhost:9119`** (atau `http://127.0.0.1:9119`)

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
├── scripts/
│   └── hermes-dashboard-daemon # Daemon background auto-start dashboard
├── ui-preset-mira/         # Modul UI/UX preset shadcn b1ZzrZbpw
│   ├── apply-mira.sh       # Skrip kompilasi & penerapan UI
│   ├── index.css           # Global stylesheet modern (Inter + smooth radius)
│   ├── presets.ts          # Typography & layout tokens
│   └── utils.ts            # Helper font bindings
└── skills/                 # Modul skill kustom & adaptasi OMP
    ├── autonomous-ai-agents/
    │   ├── omp-workflows/
    │   │   ├── SKILL.md
    │   │   └── scripts/loop_runner.py
    │   └── hermes-mcp-cross-platform/
    └── software-development/
        ├── agentic-coding-discipline/
        ├── ast-grep-code-surgery/
        ├── nextjs-classroom-api/
        ├── shadcn-ui-bootstrap/
        ├── shadcn-ui-patterns/
        ├── threat-aware-security-engineering/
        └── web-ssr-hydration-debugging/
```

---

## 📜 Lisensi
Didistribusikan di bawah lisensi [MIT](LICENSE). Terbuka untuk digunakan dan dikembangkan kembali.
