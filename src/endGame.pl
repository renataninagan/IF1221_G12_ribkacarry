:- include('primitif.pl').

/*hitung nilai*/
nilaiKartu(kartu(_,0), 1) :- !.
nilaiKartu(kartu(_, Angka), Angka) :-
    integer(Angka), !.
nilaiKartu(kartu(_,skip), 10).
nilaiKartu(kartu(_,rev), 10).
nilaiKartu(kartu(_,drawtwo), 10).

nilaiKartu(kartu(_,wild), 20).
nilaiKartu(kartu(_,wilddrawfour), 20).
nilaiKartu(kartu(_,mimic), 20).

/*Total Poin*/
hitungPoin([],0).
hitungPoin([Kartu|T],Sum) :-
    nilaiKartu(Kartu,Nilai),
    hitungPoin(T,Sisa),
    Sum is Nilai + Sisa.
    
/*poin untuk tim*/
hitungPoinTim([], _, 0).
hitungPoinTim([player(Nama, _, Deck) | T], Tim, Total) :-
    timPemain(Nama, Tim), !,
    hitungPoin(Deck, Poin),
    hitungPoinTim(T, Tim, SisaPoin),
    Total is Poin + SisaPoin.
hitungPoinTim([_ | T], Tim, Total) :-
    hitungPoinTim(T, Tim, Total).

/*Daftar Pemain*/
/*hasil(Nama, TotalPoin, JumlahKartu)*/
dataPemain([],[]).
dataPemain([player(Nama,_,Deck)|T],[hasil(Nama,Poin,JmlKartu)|THasil]) :-
    hitungPoin(Deck,Poin),
    getLen(Deck,JmlKartu),
    dataPemain(T,THasil).

ambilNamaAnggota([], _, []).
ambilNamaAnggota([player(Nama, _, _) | T], Tim, [Nama | Sisa]) :-
    timPemain(Nama, Tim), !,
    ambilNamaAnggota(T, Tim, Sisa).
ambilNamaAnggota([_ | T], Tim, Sisa) :-
    ambilNamaAnggota(T, Tim, Sisa).

/*nama kartu*/
namaKartu(kartu(Warna, Angka), Teks) :-
    integer(Angka),
    atomic_list_concat([Warna,'-',Angka], Teks).
namaKartu(kartu(Warna, skip), Teks) :-
    atomic_list_concat([Warna,'-skip'], Teks).
namaKartu(kartu(Warna, rev), Teks) :-
    atomic_list_concat([Warna,'-reverse'], Teks).
namaKartu(kartu(Warna, drawtwo), Teks) :-
    atomic_list_concat([Warna,'-drawtwo'], Teks).
namaKartu(kartu(Warna, wild), Teks) :-
    atomic_list_concat([Warna,'-wild'], Teks).
namaKartu(kartu(Warna, wilddrawfour), Teks) :-
    atomic_list_concat([Warna,'-wilddrawfour'], Teks).
namaKartu(kartu(Warna, mimic), Teks) :-
    atomic_list_concat([Warna,'-mimic'], Teks).

/*detail deck*/
detailDeck([], [], []).
detailDeck([K|T], [Nama|TNama], [Nilai|TNilai]) :-
    namaKartu(K, Nama),
    nilaiKartu(K, Nilai),
    detailDeck(T, TNama, TNilai).

/*gabung*/
gabungPlus([X], X).
gabungPlus([H|T], Hasil) :-
    gabungPlus(T, Sisa),
    atomic_list_concat([H,' + ',Sisa], Hasil).

/*ubah angka ke atom*/
angkaKeAtom(Angka, Atom):-
    number_chars(Angka, Chars),
    atom_chars(Atom, Chars).

/*tampilkan poin tiap pemain*/
tampilPoinPemain([]).
tampilPoinPemain([player(Nama,_,Deck)|T]) :-
    (
        Deck = []
    ->
        format('~w: kartu habis = 0 poin~n', [Nama])
    ;
        detailDeck(Deck, NamaKartuList, NilaiList),
        gabungPlus(NamaKartuList, KartuStr),
        maplist(angkaKeAtom, NilaiList, NilaiAtom),
        gabungPlus(NilaiAtom, NilaiStr),
        hitungPoin(Deck, Total),
        format(
            '~w: ~w = ~w = ~d poin~n',
            [Nama, KartuStr, NilaiStr, Total]
        )
    ),
    tampilPoinPemain(T).

/*pemain kartu habis*/
pemainHabis([player(Nama,_,Deck)|_], Nama):-
    Deck = [], !.
pemainHabis([_|T], Nama):-
    pemainHabis(T, Nama).


/*Rank Pemain (INSERT)*/
/*prioritas:
1. poin lebih kecil
2. jumlah kartu lebih sedikit
3. urutan lebih awal (stable)*/

/*compare poin dulu. poin sama? compare juml kartu*/
lebihTinggi(hasil(_,Poin1,_), hasil(_,Poin2,_)) :-
    Poin1 < Poin2, !.
/*poinnya sama*/
lebihTinggi(hasil(_,Poin,K1), hasil(_,Poin,K2)) :-
    K1 < K2.

/*insert*/
insertRank(H,[],[H]).
insertRank(H,[H1|T], [H,H1|T]) :-
    lebihTinggi(H,H1), !.
insertRank(H,[H1|T], [H1|TH]) :-
    insertRank(H,T,TH).

urutkan([],[]).
urutkan([H|T], Sorted) :-
    urutkan(T, SortedTail),
    insertRank(H, SortedTail, Sorted).

/*Rank Pemain (SHOW)*/
tampilRank([],_).
tampilRank([hasil(Nama,Poin,JumlahKartu)|T], Rank):-
    write(Rank), write('. '), write(Nama), write(' - Poin: '), write(Poin), write(', Jumlah Kartu: '), write(JumlahKartu), nl,
    NextRank is Rank + 1,
    tampilRank(T, NextRank).
    
endGame :-
    gameStatus(ListPlayer,_,_),
    nl,

    (
        gameMode(turnamen)
    ->
        write('==========================================='), nl,
        write('=========== PERMAINAN SELESAI ============='), nl,
        write('==========================================='), nl, nl,

        hitungPoinTim(ListPlayer, timA, PoinTimA),
        hitungPoinTim(ListPlayer, timB, PoinTimB),

        ambilNamaAnggota(ListPlayer, timA, [A1, A2]),
        ambilNamaAnggota(ListPlayer, timB, [B1, B2]),

        write('Berikut perhitungan poin untuk masing-masing tim:'), nl,

        format(
            'Tim A (~w, ~w) : ~w poin~n',
            [A1, A2, PoinTimA]
        ),

        format(
            'Tim B (~w, ~w) : ~w poin~n',
            [B1, B2, PoinTimB]
        ),
        nl,

        (
            PoinTimA < PoinTimB
        ->
            write('Selamat, Tim A menjadi pemenang turnamen!'), nl

        ;   PoinTimB < PoinTimA
        ->
            write('Selamat, Tim B menjadi pemenang turnamen!'), nl

        ;
            write('Game Berakhir Seri! Kedua tim memiliki total poin yang sama.'), nl
        )

    ;

        pemainHabis(ListPlayer, NamaHabis),

        format(
            'Permainan selesai! ~w menghabiskan semua kartunya!~n~n',
            [NamaHabis]
        ),

        write('Berikut perhitungan poin sisa kartu:'), nl,

        tampilPoinPemain(ListPlayer),
        nl,

        dataPemain(ListPlayer, Data),
        urutkan(Data, RankingFinal),

        write('Urutan pemenang:'), nl,
        tampilRank(RankingFinal, 1),
        nl,

        RankingFinal = [hasil(Pemenang, _, _)|_],

        format(
            'Selamat, ~w menjadi pemenang!~n',
            [Pemenang]
        )
    ),

    nl,

    retractall(isStart(_)),
    retractall(gameStatus(_, _, _)),
    retractall(sudahSwap(_)),
    retractall(gameMode(_)),
    retractall(timPemain(_, _)),
    !.
