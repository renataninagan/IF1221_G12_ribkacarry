:- include('primitif.pl').

/*hitung nilai*/
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
    
/*END GAME*/
endGame :-
    gameStatus(ListPlayer,_,_),nl,
    write('==========================================='), nl,
    write('=========== PERMAINAN SELESAI ============='), nl,
    write('   Ada Pemain yang Menghabiskan Kartunya   '), nl,
    write('==========================================='), nl, nl,,

    ( 
        gameMode(turnamen) 
    ->
        write('Berikut perhitungan poin sisa kartu:'), nl,

        hitungPoinTim(ListPlayer, timA, PoinTimA),
        hitungPoinTim(ListPlayer, timB, PoinTimB),

        ambilNamaAnggota(ListPlayer, timA, [A1, A2]),
        ambilNamaAnggota(ListPlayer, timB, [B1, B2]),

        write('Berikut perhitungan poin untuk masing-masing tim:'), nl,
        format('Tim A (~w, ~w) : ~w poin~n', [A1, A2, PoinTimA]),
        format('Tim B (~w, ~w) : ~w poin~n', [B1, B2, PoinTimB]), nl,

        ( 
            PoinTimA < PoinTimB 
        ->
            write('Selamat, Tim A menjadi pemenang turnamen!'), nl
        ; 
            PoinTimB < PoinTimA 
        ->
            write('Selamat, Tim B menjadi pemenang turnamen!'), nl
        ;
            write('Game Berakhir Seri! Kedua tim memiliki total poin yang sama.'), nl
        )
    ;
        dataPemain(ListPlayer, Data),
        urutkan(Data, RankingFinal),

        write('URUTAN PEMENANG:'), nl,
        tampilRank(RankingFinal, 1), nl,

        RankingFinal = [hasil(Pemenang, _, _)|_],
        format('Selamat, ~w menjadi pemenang!~n', [Pemenang])
    ),
    nl,

    retractall(isStart(_)),
    retractall(gameStatus(_, _, _)),
    retractall(sudahSwap(_)),
    retractall(gameMode(_)),
    retractall(timPemain(_, _)),
    !.
