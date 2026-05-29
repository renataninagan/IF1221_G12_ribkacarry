:- initialization(randomize).
:- include('factsRules.pl').
:- include('primitif.pl').
:- include('cekInfo.pl').
:- include('mekanismeDasar.pl').
:- include('startGame.pl').
:- include('lihatKartu.pl').
:- include('lihatCommand.pl').
:- include('kartuTersembunyi.pl').
:- include('godsHand.pl').

 
startGame :-
    nl,
    write('===================================='), nl,
    write('  Selamat datang di Permainan UNI!  '), nl,
    write('===================================='), nl,
    nl,
    write('Aturan :'), nl,
    write('  - Cocokkan warna atau angka kartu teratas'), nl,
    write('  - Ketik DrawPile untuk ambil kartu dari DrawPile'), nl,
    write('  - Pemain  yang kartunya habis maka MENANG'), nl,
    write('  - Jika DrawPile habis dan tidak bisa main, KALAH'), nl,
    nl,
    inisialisasiGame,
    nl.
 