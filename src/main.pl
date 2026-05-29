:- initialization(randomize).
:- include('factsRules.pl').
:- include('primitif.pl').
:- include('cekInfo.pl').
:- include('mekanismeDasar.pl').
:- include('startGame.pl').
:- include('kartuTersembunyi.pl').
:- include('efekKartu.pl').
:- include('godsHand.pl').

 
startGame :-
    nl,
    write('───────────────────────  UNI  ──────────────────────'), nl,
    write('           Selamat datang di Permainan UNI!         '), nl,
    write('────────────────────────────────────────────────────'), nl,
    
    write(' • CARA BERMAIN'), nl,
    write('   1. Cocokkan warna / simbol dengan kartu teratas.'), nl,
    write('   2. Ketik \'DrawPile\' jika tidak bisa jalan.'), nl,
    write('   3. Habiskan kartu di tangan untuk MENANG.'), nl,nl,
    
    write(' • PERINGATAN'), nl,
    write('   Jika dek habis dan tidak ada kartu valid, KALAH.'), nl,
    write('────────────────────────────────────────────────────'), nl,
    
    inisialisasiGame,
    !.