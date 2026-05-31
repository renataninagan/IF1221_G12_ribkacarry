/* Basis untuk tulisPemain */
tulisPemain(Urutan, JumlahPemain,_) :-
    Urutan > JumlahPemain,
    !.

/* Rekurens tulisPemain */
tulisPemain(Urutan, JumlahPemain, [Nama | SisaNama]) :-
    ( Urutan < 10 -> Spasi = ' ' ; Spasi = '' ),
    player(Nama, DaftarKartu),
    getLen(DaftarKartu, X),
    format('   ~w~w. ~w (~w kartu)~n', [Spasi, Urutan, Nama, X]),
    NextUrutan is Urutan + 1,
    tulisPemain(NextUrutan, JumlahPemain, SisaNama).
/* Basis untuk tulisListUrutan */
tulisListUrutan([NamaTerakhir]) :-
    write(NamaTerakhir), write('.'), nl, !.

/* Rekurens tulisListUrutan */ 
tulisListUrutan([Nama | Sisa]) :-
    write(Nama), write(' -> '),
    tulisListUrutan(Sisa). 

cekInfo :-
    nl,
    gameStatus(ListPlayer, DiscardPile, _DrawPile),
    DiscardPile = [kartu(W,J)|_],
    ListPlayer = [player(Nama, _, _)|_],
    
    write('────────────────  STATUS PERMAINAN  ────────────────'), nl,
    format(' • KARTU TERATAS : [~w - ~w]~n', [W, J]),
    write(' • URUTAN BERMAIN: '), 
    findall(P, member(player(P, _, _), ListPlayer), ListNama),
    tulisListUrutan(ListNama),
    write(' • DETAIL PEMAIN :'), nl,
    tampilListPlayer(ListPlayer),
    write('────────────────────────────────────────────────────'), nl,nl,
    format(' >> Giliran : ~w~n', [Nama]),
    !.

tampilListPlayer([]) :- !.
tampilListPlayer([player(Nama, Status, Deck)|T]) :-
    getLen(Deck, TotalKartu),
    (
        kartuTersembunyi(Nama, _)
    ->
        JmlKartu is TotalKartu - 1
    ;
        JmlKartu is TotalKartu
    ),
    format('   - ~w (~w) | ~w kartu~n', [Nama, Status, JmlKartu]),
    tampilListPlayer(T).


% LIHAT COMMAND
lihatCommand :-
    gameStatus(ListPlayer, DiscardPile, _DrawPile),
    ListPlayer = [player(_,Status,Deck)|_],
    DiscardPile = [KartuTerakhir|_],
    
    % Ekstrak warna dan jenis kartu terakhir untuk pengecekan adaKartu
    KartuTerakhir = kartu(WarnaTerakhir, JenisTerakhir),
    
    nl,
    write('────────────────────  COMMAND  ────────────────────'), nl,
    write(' • AKSI UTAMA'), nl,
    
    (Status == 'main' -> write('   - mainkanKartu   (Mainkan kartu dari tangan)'), nl ; true),
    
    (
        harusAmbil(N), N > 1 
    -> 
        write('   - ambilKartu     (Ambil kartu efek dari draw pile)'), nl
    ; 
        ( \+ adaKartu(Deck, kartu(WarnaTerakhir, JenisTerakhir)) ->
            write('   - ambilKartu     (Ambil kartu dari draw pile)'), nl
        ;
            write('   - [ambilKartu]   (Terkunci: Kamu punya kartu yang bisa dimainkan)'), nl
        ),
        write('   - tantang        (Tantang pemain sebelumnya)'), nl
    ),

    nl,
    write(' • AKSI PENDUKUNG'), nl,
    write('   - lihatCommand   (Membuka panduan perintah ini)'), nl,
    write('   - lihatKartu     (Melihat kartu yang di tangan)'), nl,
    write('   - cekInfo        (Melihat status permainan)'), nl,
    write('────────────────────────────────────────────────────'), nl.
% LIHAT KARTU
% menampilkan kartu pemain

lihatKartu :-
    gameStatus(SemuaPemain, _, _),
    SemuaPemain = [player(Nama, _, ListKartu) | _],
    gameMode(Mode),
    (
        gameMode(klasik)
    ->
        nl,
        write('──────────────────────  KARTU  ─────────────────────'), nl,
        write(' • KARTU DI TANGAN ANDA'), nl,
        tampilkanKartu(Nama, ListKartu, 1),
        write('────────────────────────────────────────────────────'), nl
    ;    
        nl,
        write('──────────────────────  KARTU  ─────────────────────'), nl,
        format(' • KARTU DI TANGAN ANDA (~w)~n', [Nama]),
        tampilkanKartu(Nama, ListKartu, 1),

        timPemain(Nama, Regu),

        (
            isMem(player(P2, _, KartuP2), SemuaPemain), P2 \== Nama, timPemain(P2, Regu)
        ->
            format('~n • KARTU TEMAN ANDA (~w)~n', [P2]),
            tampilkanKartu(P2, KartuP2, 1)
        ;
            true
        ),
        write('────────────────────────────────────────────────────')
    ), 
    !.

tampilkanKartu(_, [], _).

tampilkanKartu(Nama, [kartu(Warna, Jenis) | Rest], No) :-
    (No < 10 -> Spasi = ' ' ; Spasi = ''),
    ( 
        Warna == kuning -> SpasiWarna = '' ;
        Warna == merah  -> SpasiWarna = ' ' ;
        Warna == hijau  -> SpasiWarna = ' ' ;
        Warna == hitam  -> SpasiWarna = ' ' ;
        Warna == biru   -> SpasiWarna = '  ' ; 
        SpasiWarna = '' 
    ),
    (
        kartuTersembunyi(Nama, No) 
    -> 
        format('   ~w~w. [KARTU TERSEMBUNYI]~n', [SpasiNo, No])
    ;
        format('   ~w~w. ~w~w - ~w~n', [Spasi, No, Warna, SpasiWarna, Jenis])
    ),
    Noke is No + 1,
    tampilkanKartu(Nama, Rest, Noke).