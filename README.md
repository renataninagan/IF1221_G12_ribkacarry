# UNI - Tubes Logkom G-12

Proyek ini adalah permainan kartu berbasis Prolog bernama **UNI**. Source code lengkap tersedia melalui repository GitHub berikut:

[https://github.com/renataninagan/Tubes-Logkom-12-Ribkahama](https://github.com/renataninagan/Tubes-Logkom-12-Ribkahama)

## Gambaran Singkat Proyek

UNI adalah permainan kartu turn-based yang mendukung beberapa mode permainan dan berbagai efek kartu. Pemain harus mencocokkan warna atau simbol kartu untuk mengosongkan kartu di tangan, sambil memanfaatkan kartu aksi seperti `skip`, `rev`, `drawtwo`, `wild`, `wilddrawfour`, dan `mimic`.

Proyek ini juga menyediakan fitur pendukung seperti informasi status permainan, tampilan kartu, penyimpanan dan pemuatan game, kartu tersembunyi, serta fitur khusus **God's Hand**.

## Cara Menjalankan Program

### Prasyarat

- GNU Prolog
- Terminal atau shell yang bisa menjalankan perintah Prolog

### Langkah Menjalankan

1. Buka terminal pada folder repository.
2. Masuk ke folder `src`.
3. Jalankan Prolog dengan memuat file utama:

```bash
gprolog --consult-file src/main.pl
```

4. Setelah masuk ke prompt Prolog, jalankan permainan:

```prolog
?- startGame.
```

5. Ikuti instruksi yang tampil di terminal untuk memilih mode, memasukkan nama pemain, dan memulai permainan.

### Perintah yang Umum Digunakan

- `startGame.` untuk memulai permainan.
- `mainkanKartu(N).` untuk memainkan kartu ke-`N` dari tangan.
- `ambilKartu.` untuk mengambil kartu dari draw pile.
- `lihatCommand.` untuk melihat daftar perintah yang tersedia.
- `lihatKartu.` untuk melihat kartu di tangan.
- `cekInfo.` untuk melihat status permainan.
- `saveGame.` untuk menyimpan permainan.
- `loadGame.` untuk memuat permainan yang tersimpan.
- `godsHand.` untuk menjalankan fitur God's Hand.
- `tantang.` untuk menantang efek wild draw four.
- `uni(N).` untuk menyerukan UNI.
- `swapKartu(A, B).` untuk menukar kartu pada mode turnamen.

## Struktur Repository

```text
.
├── README.md
├── docs/
│   ├── Milestone1_G12.pdf
│   └── Milestone2_G12.pdf
└── src/
    ├── main.pl
    ├── factsRules.pl
    ├── primitif.pl
    ├── startGame.pl
    ├── mekanismeDasar.pl
    ├── efekKartu.pl
    ├── cekInfo.pl
    ├── kartuTersembunyi.pl
    ├── godsHand.pl
    ├── save_load.pl
    └── endGame.pl
```

### Ringkasan Isi File

- `main.pl`: titik masuk program dan pemanggilan modul utama.
- `factsRules.pl`: fakta kartu, aturan dasar, dan definisi awal permainan.
- `primitif.pl`: operasi dasar seperti manipulasi list dan deck.
- `startGame.pl`: inisialisasi permainan, input pemain, mode permainan, dan pembagian kartu.
- `mekanismeDasar.pl`: logika utama main kartu, ambil kartu, tantangan, dan pergantian giliran.
- `efekKartu.pl`: implementasi efek kartu aksi.
- `cekInfo.pl`: tampilan status permainan, kartu, dan command help.
- `kartuTersembunyi.pl`: fitur kartu tersembunyi.
- `godsHand.pl`: fitur khusus God's Hand.
- `save_load.pl`: penyimpanan dan pemuatan game.
- `endGame.pl`: perhitungan poin dan penentuan pemenang.

## Fitur Utama

- Mode **Klasik** dan **Turnamen**.
- Input nama pemain dengan validasi jumlah pemain dan nama unik.
- Kartu aksi: `skip`, `rev`, `drawtwo`, `wild`, `wilddrawfour`, dan `mimic`.
- Sistem giliran dan arah permainan.
- Informasi permainan melalui `cekInfo`.
- Bantuan command melalui `lihatCommand`.
- Menampilkan kartu tangan melalui `lihatKartu`.
- Kartu tersembunyi yang tidak langsung terlihat.
- Fitur `saveGame` dan `loadGame`.
- Fitur spesial `godsHand`.
- Sistem akhir permainan dan perhitungan poin.

## Anggota Kelompok

Kelompok: **ribkacarry**

- Ribka Kaylena Sanjaya - 13525045
- Three Gie Gendhis Sekar Ayoe Jatmiko - 13525144
- Renata Puspanegara Ninagan - 13525041
- Muhammad Dhiya Rafi - 13525035

## Catatan

Dokumentasi tambahan tersedia di folder `docs/` dalam bentuk file PDF milestone.
