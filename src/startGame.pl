:- dynamic(gameStatus/3).   
:- dynamic(isStart/1).  
:- dynamic(statusUNI/1).
:- dynamic(riwayatAksi/2).
:- dynamic(gameMode/1).
:- dynamic(timPemain/2).
:- dynamic(arahPermainan/1).
:- dynamic(sudahSwap/1).
:- dynamic(warnaAktf/1).
:- dynamic(harusAmbil/1).
:- dynamic(kartuTersembunyi/2).

adaDiDeck(H, [H|_]).
adaDiDeck(H, [_|T]) :- adaDiDeck(H, T).

deckLengkap(Deck) :- ambilDeck([], Deck).

ambilDeck(A, Deck) :- kartu(Warna, Jenis), \+ (adaDiDeck(kartu(Warna, Jenis), A)),!, ambilDeck([kartu(Warna, Jenis)|A], Deck).
ambilDeck(A, A).

shuffleKartu([], []).
shuffleKartu(Deck, [H|T]) :-
    getLen(Deck, Len),
    random(0, Len, Idx),
    getIdx0(Deck, Idx, H),
    select(H, Deck, Sisa),
    shuffleKartu(Sisa, T).

kartuAwalValid(kartu(Warna, Angka)) :-
    Warna \== hitam,
    integer(Angka).

ambilKartuAwalValid([H|T], H, T) :-
    kartuAwalValid(H),
    !.

ambilKartuAwalValid([H|T], KartuValid, DrawPileFinal) :-
    \+ kartuAwalValid(H),
    ambilKartuAwalValid(T, KartuValid, Sisa),
    appendElem(Sisa, H, DrawPileFinal).

awalBagiKartu(0, Pile, [], Pile) :- !.
awalBagiKartu(N, [H|T], [H| Kartu], Sisa) :-
    N > 0,
    N1 is N - 1,
    awalBagiKartu(N1, T, Kartu, Sisa).

bagikanKartu([], DrawPile, [], DrawPile).
bagikanKartu([player(Nama, Status, [])|T], DrawPile,
             [player(Nama, Status, KartuDiTangan)|ListBaru], DrawPileBaru) :-
    awalBagiKartu(7, DrawPile, KartuDiTangan, DrawPileSisa),
    bagikanKartu(T, DrawPileSisa, ListBaru, DrawPileBaru).

verifikasiJumlahPemain(X, 1) :- X >= 2, X =< 4.
verifikasiJumlahPemain(X, 0) :- X < 2.
verifikasiJumlahPemain(X, 0) :- X > 4.

jumlahPemain(X) :-
    write('>> Masukkan jumlah pemain (2-4) : '),
    read(Jumlah),
    verifikasiJumlahPemain(Jumlah, Y),
    Y =:= 1,
    X is Jumlah, !.

jumlahPemain(X) :-
    write('   [!] Jumlah pemain harus diantara 2-4 orang! Silakan input ulang.'), nl,nl,
    jumlahPemain(X).

isUniquePemain(_, [], 1).
isUniquePemain(Nama, [player(Nama,_,_)|_], 0) :- !.
isUniquePemain(Nama, [player(H,_,_)|T], X) :-
    Nama \== H,
    isUniquePemain(Nama, T, X).

loopInputNama(0, L, L, _) :- !.
loopInputNama(N, L, PlayerFinal, K) :-
    N > 0,
    K1 is K+1,
    write('>> Masukkan nama pemain '), write(K), write(' : '),
    read(Nama),
    isUniquePemain(Nama, L, X),
    ( X == 1 ->  N1 is N - 1, append(L, [player(Nama, main, [])], L1), loopInputNama(N1, L1, PlayerFinal, K1);
        write(' [!] Nama sudah digunakan! Silakan input ulang.'), nl, loopInputNama(N, L, PlayerFinal, K)).
    
printInputNama([player(T,_,_)]) :- write(T), !. 
printInputNama([player(H,_,_)|T]) :- write(H), write(' -> '), printInputNama(T).

tangkap(NamaPemain) :-

    gameStatus([player(Pemanggil, StatusPemanggil, DeckPemanggil)|SisaPemain], Discard, DrawPile),

    ListSemua = [player(Pemanggil, StatusPemanggil, DeckPemanggil)|SisaPemain],
    
    ( member(player(NamaPemain, _, DeckTarget), ListSemua)->
        length(DeckTarget, SisaKartu),
        ( (SisaKartu =:= 1, \+ statusUNI(NamaPemain)) ->
            format('~w tertangkap tidak menyerukan UNI.~n', [NamaPemain]),
            format('~w mendapatkan 2 kartu penalti.~n', [NamaPemain]),
            drawKartu(2, DrawPile, DeckTarget, DrawPileNow, DeckTargetNow),
            updatePemainList(NamaPemain, ListSemua, DeckTargetNow, ListBaru),
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus(ListBaru, Discard, DrawPileNow)),
            cekInfo
            
        ;
            format('Tuduhan salah! ~w tidak melanggar aturan.~n', [NamaPemain]),
            format('~w mendapatkan 1 kartu penalti.~n', [Pemanggil]),
            
            drawKartu(1, DrawPile, DeckPemanggil, DrawPileNow, DeckPemanggilNow),
            
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus([player(Pemanggil, StatusPemanggil, DeckPemanggilNow)|SisaPemain], Discard, DrawPileNow)),
            akhiriGiliran(Pemanggil, StatusPemanggil, DeckPemanggilNow, SisaPemain, Discard, DrawPileNow)
        )
    ).

modeValid(1, klasik) :- !.
modeValid(2, turnamen) :- !.
modeValid(_, x).

pilihMode(ModePilihan) :-
    write('──────────────────────  MODE  ──────────────────────'), nl,
    write(' • PILIHAN MODE PERMAINAN'), nl,
    write('   1. Mode Klasik'), nl,
    write('   2. Mode Turnamen'), nl,
    write('────────────────────────────────────────────────────'), nl,
    write('>> Pilih mode permainan (nomor) : '),
    read(Pilihan),
    modeValid(Pilihan, Mode),
    ( 
        Mode \== x 
    ->
        ModePilihan = Mode
    ;
        nl,
        write('   [!] Pilihan tidak valid! Silakan input ulang.'), nl,
        pilihMode(ModePilihan)
    ).

timB([], _, _, []).
timB([H|T], A1, A2, [H|Sisa]) :-
    H \== A1, H \== A2, !,
    timB(T, A1, A2, Sisa).
timB([_|T], A1, A2, Sisa) :-
    timB(T, A1, A2, Sisa).

shuffleTim(ListPlayer, ListPlayerNow) :-
    nl, write('Membentuk tim secara acak...'), nl,
    ListPlayer = [player(P1,_,_), player(P2,_,_), player(P3,_,_), player(P4,_,_)],
    NamaPlayer = [P1,P2,P3,P4],

    pick2Random(NamaPlayer, A1, A2),
    timB(NamaPlayer, A1, A2, [B1, B2]),

    asserta(timPemain(A1, timA)),
    asserta(timPemain(A2, timA)),
    asserta(timPemain(B1, timB)),
    asserta(timPemain(B2, timB)),

    isMem(player(A1, SA1, DA1), ListPlayer),
    isMem(player(B1, SB1, DB1), ListPlayer),
    isMem(player(A2, SA2, DA2), ListPlayer),
    isMem(player(B2, SB2, DB2), ListPlayer),

    ListPlayerNow = [player(A1, SA1, DA1), player(B1, SB1, DB1), player(A2, SA2, DA2), player(B2, SB2, DB2)],
    
    nl,
    write('──────────────  HASIL PEMBAGIAN TIM  ───────────────'), nl,
    format(' • TIM A : ~w & ~w~n', [A1, A2]),
    format(' • TIM B : ~w & ~w~n', [B1, B2]),
    write('────────────────────────────────────────────────────'), nl.

inisialisasiGame :-
    retractall(isStart(_)),
    retractall(gameStatus(_, _, _)),
    retractall(statusUNI(_)),
    retractall(gameMode(_)),
    retractall(arahPermainan(_)),
    assertz(arahPermainan(kanan)),

    pilihMode(Mode),
    asserta(gameMode(Mode)),

    ( 
        gameMode(turnamen) 
    ->
        write(' • Permainan dimulai dalam mode TURNAMEN.'), nl,
        N = 4,
        write(' • Mode Turnamen: Pemain otomatis berjumlah 4 orang (2 vs 2)!'), nl, nl
    ;   
        write(' • Permainan dimulai dalam mode KLASIK.'), nl,nl,
        jumlahPemain(N)
    ),
    
    loopInputNama(N, [], ListPlayer, 1),

    ( 
        gameMode(turnamen) 
    ->
        shuffleTim(ListPlayer, ListPlayerNow)
    ; 
        ListPlayerNow = ListPlayer
    ),
    write('───────────────────  GAME START  ───────────────────'), nl,
    write(' • URUTAN BERMAIN'), nl,
    write('   '), printInputNama(ListPlayerNow), nl, nl,
    deckLengkap(DeckAwal),
    shuffleKartu(DeckAwal, DrawPileAwal),
    bagikanKartu(ListPlayerNow, DrawPileAwal, ListTerisi, DrawPileSisa),
    ambilKartuAwalValid(DrawPileSisa, KartuPertama, DrawPileFinal),
    DiscardPile = [KartuPertama],
    KartuPertama = kartu(W,J),

    retractall(warnaAktf(_)),
    assertz(warnaAktf(W)),

    write(' • PERSIAPAN DECK'), nl,
    write('   Setiap pemain mendapat 7 kartu acak.'), nl,
    format('   Kartu Teratas: [~w - ~w] ~n', [W, J]),
    write('────────────────────────────────────────────────────'), nl,
    retractall(gameStatus(_, _, _)),
    asserta(gameStatus(ListTerisi, DiscardPile, DrawPileFinal)),
    ( ListTerisi = [player(GiliranNow,_,_)|_] -> true ; GiliranNow = 'nullllll' ),
    nl, format(' >> Giliran : ~w~n', [GiliranNow]),
    asserta(isStart(true)).

cekStatus(player(_, menang, []), menang) :- !.
cekStatus(player(_, kalah,  _), kalah)  :- !.
cekStatus(player(_, main,  []), menang).  
cekStatus(player(_, main,   _), main).

updateStatusList([], []).
updateStatusList([H|T], [player(Nama, StatusBaru, Deck)|T2]) :-
    H = player(Nama, _, Deck),
    cekStatus(H, StatusBaru),
    updateStatusList(T, T2).

updatePemainList(_, [], _, []).
updatePemainList(NamaTarget, [player(NamaTarget, Status, _)|T], DeckBaru, [player(NamaTarget, Status, DeckBaru)|T]) :- !.
updatePemainList(NamaTarget, [H|T], DeckBaru, [H|TBaru]) :-
    updatePemainList(NamaTarget, T, DeckBaru, TBaru).

listPemainAktif([], []).
listPemainAktif([H|T], [H|L]) :-
    H = player(_, main, _), !,
    listPemainAktif(T, L).
listPemainAktif([_|T], L) :-
    listPemainAktif(T, L).

bisaUni(NamaPemain) :- 
    gameStatus([player(NamaPemain, _, Deck) | _], _, _),
    getLen(Deck, 2).
     

uni(IndeksKartu) :-
    gameStatus([player(Nama, Status, Deck) | SisaPemain], Discard, DrawPile),
    ( bisaUni(Nama) ->
        retractall(statusUNI(Nama)),
        asserta(statusUNI(Nama)),
        format('~w menyerukan UNI!~n', [Nama]),
        mainkanKartu(IndeksKartu)
    ;   
        format('~w gagal menyerukan UNI!~n', [Nama]),
        format('~w mendapatkan 1 kartu penalti.~n', [Nama]),

        drawKartu(1, DrawPile, Deck, DrawPileNow, DeckNow),

        retractall(gameStatus(_, _, _)),
        asserta(gameStatus([player(Nama, Status, DeckNow) | SisaPemain], Discard, DrawPileNow))
    ).
/*
tangkap(NamaPemain) :-
    gameStatus([player(Pemanggil, StatusPemanggil, DeckPemanggil)|SisaPemain], Discard, DrawPile),
    
    ( member(player(NamaPemain, _, DeckTarget), [player(Pemanggil, StatusPemanggil, DeckPemanggil)|SisaPemain]) ->
        getLen(DeckTarget, SisaKartu),
        ( (SisaKartu =:= 1, \+ statusUNI(NamaPemain)) ->
            format('~w tertangkap tidak menyerukan UNI.~n', [NamaPemain]),
            format('~w mendapatkan 2 kartu penalti.~n', [NamaPemain]),
            
            drawKartu(2, DrawPile, DeckTarget, DrawPileNow, DeckTargetNow),
            
            updatePemainList(NamaPemain, SisaPemain, DeckTargetNow, SisaPemainNow),
            akhiriGiliran(Pemanggil, StatusPemanggil, DeckPemanggil, SisaPemainNow, Discard, DrawPileNow)
            
        ;
            format('Tuduhan salah! ~w tidak melanggar aturan.~n', [NamaPemain]),
            format('~w mendapatkan 1 kartu penalti.~n', [Pemanggil]),
            
            drawKartu(1, DrawPile, DeckPemanggil, DrawPileNow, DeckPemanggilNow),
            
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus([player(Pemanggil, StatusPemanggil, DeckPemanggilNow)|SisaPemain], Discard, DrawPileNow)),
            akhiriGiliran(Pemanggil, StatusPemanggil, DeckPemanggil, SisaPemain, Discard, DrawPileNow)
        )
    ).
*/
listPemenang([], []).
listPemenang([H|T], [H|L]) :-
    H = player(_, menang, _), !,
    listPemenang(T, L).
listPemenang([_|T], L) :-
    listPemenang(T, L).

updateGame(ListPlayer, DiscardPile, DrawPile) :-
    retractall(gameStatus(_, _, _)),
    asserta(gameStatus(ListPlayer, DiscardPile, DrawPile)).
