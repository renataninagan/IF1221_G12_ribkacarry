pindahGiliran(List, ListBaru) :-
    arahPermainan(kanan),
    List = [Pemain|Sisa],
    appendElem(Sisa, Pemain, ListBaru),
    !.

pindahGiliran(List, ListBaru) :-
    arahPermainan(kiri),
    reverseL(List, Rev),
    Rev = [Pemain|Sisa],
    appendElem(Sisa, Pemain, RevBaru),
    reverseL(RevBaru, ListBaru).

adaKartu(Deck, kartu(Warna, Jenis)) :-
    member(kartu(W, J), Deck),
    (W == Warna ; J == Jenis ; W == hitam),!.

drawKartu(0, DrawPile, Deck, DrawPile, Deck) :- !.
drawKartu(_, [], Deck, [], Deck) :-
    write('Draw pile habis!'), nl,
    !.
drawKartu(N, [KartuAtas|SisaDraw], Deck, DrawPileSisa, DeckSisa) :-
    N > 0,
    appendElem(Deck, KartuAtas, DeckNow),
    N1 is N - 1,
    drawKartu(N1, SisaDraw, DeckNow, DrawPileSisa, DeckSisa).

akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemain, Discard, DrawPileNow) :-
    PemainNow = player(Nama, StatusNow, DeckNow),
    
    pindahGiliran([PemainNow|SisaPemain], ListPemainNow),
    retractall(gameStatus(_, _, _)),
    retractall(sudahSwap(_)),
    asserta(gameStatus(ListPemainNow, Discard, DrawPileNow)),
    (
        StatusNow == menang ->
        format('~w Menang!~n', [Nama]),
        endGame
    ;
        cekInfo
    ),
    !.

reverseArah :-
    arahPermainan(kanan),
    retractall(arahPermainan(_)),
    assertz(arahPermainan(kiri)), !.

reverseArah :-
    arahPermainan(kiri),
    retractall(arahPermainan(_)),
    assertz(arahPermainan(kanan)).

ambilKartu :-
    gameStatus([player(Nama, Status, Deck)|SisaPemain], [KartuTerakhir|SisaDiscard], DrawPile),!,
    (
        KartuTerakhir = kartu(_, wilddrawfour)
    ->
        drawKartu(4, DrawPile, Deck, DrawPileNow, DeckNow),
        format('~w mengambil 4 kartu dari deck karena kartu Wild Draw Four dan mengakhiri giliran.~n', [Nama]), nl,
        akhiriGiliran(Nama, Status, DeckNow, SisaPemain, [KartuTerakhir|SisaDiscard], DrawPileNow)
    ;
        drawKartu(1, DrawPile, Deck, DrawPileNow, DeckNow),
        format('~w mengambil 1 kartu dari deck dan mengakhiri giliran.~n',
        [Nama]), nl,
        akhiriGiliran(Nama, Status, DeckNow,
        SisaPemain,
        [KartuTerakhir|SisaDiscard],
        DrawPileNow)
    ).

kartuCocokSelainHitam(Deck, WarnaTerakhir, JenisTerakhir) :-
    member(kartu(W, J), Deck),
    W \== hitam,
    (W == WarnaTerakhir ; J == JenisTerakhir),!.

warnaValid(merah).
warnaValid(biru).
warnaValid(hijau).
warnaValid(kuning).

pilihWarna(Warna) :-
    nl,
    write('Pilih warna baru:'), nl,
    write('1. merah'), nl,
    write('2. kuning'), nl,
    write('3. hijau'), nl,
    write('4. biru'), nl,
    write('>> '),
    read(Pilih),

    (
        Pilih =:= 1 -> Warna = merah
    ;   Pilih =:= 2 -> Warna = kuning
    ;   Pilih =:= 3 -> Warna = hijau
    ;   Pilih =:= 4 -> Warna = biru
    ;
        write('Pilihan tidak valid!'), nl,
        pilihWarna(Warna)
    ).

mainkanKartu(N) :-
    gameStatus([player(Nama, Status, Deck)|SisaPemain], [KartuTerakhir|SisaDiscard], DrawPile),
    retractall(statusUNI(Nama)),
    KartuTerakhir = kartu(_, JenisTerakhir),
    warnaAktf(WarnaAktif),
    length(Deck, L),
    (
        N >= 1,
        N =< L
    ->
        true
    ;
        format('   [!] Tidak ada kartu ke-~w!~n', [N]),
        fail
    ),

    getCard(Deck, N, Played),
    Played = kartu(WarnaPilih, JenisPilih),

    /*cek wild draw four*/

    (
        WarnaPilih == hitam,
        JenisPilih == wilddrawfour,
        kartuCocokSelainHitam(
            Deck,
            WarnaAktif,
            JenisTerakhir
        )
    ->
        write('   [!] Wild Draw Four tidak boleh digunakan.'), nl,
        fail
    ;
        true
    ),

   /*cek stacking terlaeanrg*/
    (
        JenisPilih == drawtwo,
        JenisTerakhir == drawtwo
    ->
        write('   [!] Draw Two tidak boleh ditumpuk!'), nl,
        fail
    ;
        true
    ),

    (
        JenisPilih == wild,
        JenisTerakhir == wild
    ->
        write('   [!] Wild tidak boleh ditumpuk!'), nl,
        fail
    ;
        true
    ),

    (
        JenisPilih == wilddrawfour,
        JenisTerakhir == wilddrawfour
    ->
        write('   [!] Wild Draw Four tidak boleh ditumpuk!'), nl,
        fail
    ;
        true
    ),
    
/*CEK KECOCOKAN KARTU*/

    (
        WarnaPilih == hitam
        ;
        WarnaPilih == WarnaAktif
        ;
        JenisPilih == JenisTerakhir
    ->
        kartuCocok(
            Nama,
            Status,
            Deck,
            N,
            Played,
            SisaPemain,
            KartuTerakhir,
            SisaDiscard,
            DrawPile
        )
    ;
        kartuTidakCocok(
            Nama,
            Deck,
            KartuTerakhir
        )
    ).
kartuCocok(Nama, Status, Deck, N, Played, SisaPemain, KartuTerakhir, SisaDiscard, DrawPile) :-
    Played = kartu(WarnaPilih, JenisPilih),

    removeCard(Deck, N, DeckNow),

    (
    kartuTersembunyi(Nama, HiddenIdx)
    ->
        (
            HiddenIdx =:= N
            ->
            retractall(kartuTersembunyi(Nama, _))
        ;
            HiddenIdx > N
            ->
            HiddenBaru is HiddenIdx - 1,
            retractall(kartuTersembunyi(Nama, _)),
            assertz(kartuTersembunyi(Nama, HiddenBaru))

        ;
            true
        )
    ;
        true
    ),

    (DeckNow == [] -> StatusNow = menang ; StatusNow = Status),

    format(' • ~w mengeluarkan kartu : [~w - ~w]~n',
    [Nama, WarnaPilih, JenisPilih]),

    DiscardNow = [Played, KartuTerakhir | SisaDiscard],

    (
        WarnaPilih == hitam
        ->
            pilihWarna(WarnaBaru),

            retractall(warnaAktf(_)),
            assertz(warnaAktf(WarnaBaru)),

            format('Warna aktif sekarang: ~w~n',
            [WarnaBaru])
        ;
            retractall(warnaAktf(_)),
            assertz(warnaAktf(WarnaPilih))
    ),

    efekKartu(
        JenisPilih,
        Played,
        Nama,
        StatusNow,
        DeckNow,
        SisaPemain,
        DrawPile,
        DiscardNow
    ).

kartuTidakCocok(Nama, Deck, KartuTerakhir) :-
    warnaAktf(WarnaAktif),
    gameStatus(
        _,
        [kartu(_, JenisTerakhir)|_],
        _
    ),

    write('   [!] Kartu tidak cocok! Pilih kartu lain.'), nl,
    (
        \+ adaKartuValid(
            Deck,
            WarnaAktif,
            JenisTerakhir
        )
    ->
        format(
            ' • ~w tidak punya kartu yang cocok, otomatis mengambil kartu.~n',
            [Nama]
        ),
        ambilKartu
    ;
        true
    ),
    fail.


    
tantang :-
    gameStatus([player(NamaTantang, StatusTantang, DeckTantang)|SisaPemain],
    [KartuTerakhir|SisaDiscard], DrawPile),

    (KartuTerakhir = kartu(_, wilddrawfour) ->
        true
    ;
        write('   [!] Tidak ada wild draw four yang bisa ditantang!'), nl, fail
    ),

    write(' • Tantangan dilakukan!'), nl,

    pemainSebelumnya([player(NamaTantang, StatusTantang, DeckTantang)|SisaPemain],
    player(NamaPelaku, StatusPelaku, DeckPelaku)
    ),

    format('Memeriksa kartu ~w...~n', [NamaPelaku]),

    (SisaDiscard = [KartuSebelum|_] ->
        KartuSebelum = kartu(WarnaSebelum, JenisSebelum)
    ;
        WarnaSebelum = none, JenisSebelum = none
    ),

    (kartuCocokSelainHitam(DeckPelaku, WarnaSebelum, JenisSebelum) ->
        write('Tantangan berhasil!'), nl,
        format('~w mendapatkan 4 kartu akibat ketahuan curang.~n', [NamaPelaku]),

        hapusPemain(
            NamaPelaku,
            [player(NamaTantang, StatusTantang, DeckTantang)|SisaPemain],
            SisaTanpaPelaku
        ),
        drawKartu(4, DrawPile, DeckPelaku, DrawPileNow, DeckPelakuNow),
        PelakuNow = player(NamaPelaku, StatusPelaku, DeckPelakuNow),
        appendElem(SisaTanpaPelaku, PelakuNow, ListSementara),

        retractall(gameStatus(_, _, _)),
        asserta(gameStatus(ListSementara, [KartuTerakhir|SisaDiscard], DrawPileNow)),
        cekInfo
    ;
        format('Tantangan gagal. ~w mendapatkan 6 kartu acak.~n', [NamaTantang]),

        drawKartu(6, DrawPile, DeckTantang, DrawPileNow, DeckTantangNow),
        PemainTantangNow = player(NamaTantang, StatusTantang, DeckTantangNow),
        
        hapusPemain(
            NamaPelaku,
            [PemainTantangNow|SisaPemain],
            SisaTanpaPelaku2
        ),
        PelakuNow = player(NamaPelaku, StatusPelaku, DeckPelaku),
        appendElem(SisaTanpaPelaku2, PelakuNow, ListSementara),

        (
            SisaPemain == [PelakuNow]
        ->
            ListFinal = [PelakuNow, PemainTantangNow]
        ;
            pindahGiliran(ListSementara, ListFinal)
        ),

        retractall(gameStatus(_, _, _)),
        asserta(gameStatus(ListFinal, [KartuTerakhir|SisaDiscard], DrawPileNow)),
        cekInfo
    ).

swapKartu(NoKartuP1, NoKartuP2) :-
    isStart(true),
    gameMode(turnamen),

    gameStatus([player(P1, StatusNow, DeckP1) | SisaPemain], Discard, DrawPile),
    ListSemua = [player(P1, StatusNow, DeckP1) | SisaPemain],
    (
        sudahSwap(P1)
    ->
        write('   [!] Swap hanya bisa dilakukan sekali dalam 1 giliran!'), nl, !
    ;
        timPemain(P1, TimP),
        timPemain(P2, TimP),
        P1 \== P2, 
        isMem(player(P2, StatusP2, DeckP2), ListSemua),
        !,

        getLen(DeckP1, JmlKartuP1),
        getLen(DeckP2, JmlKartuP2),
        (
            (JmlKartuP1 =:= 1; JmlKartuP2 =:= 1)
        ->
            write('   [!] Swap tidak bisa dilakukan karena Anda/P2 Anda hanya memiliki 1 kartu!'), nl, !
        ;
            (
                (NoKartuP1 < 1; NoKartuP1 > JmlKartuP1;
                NoKartuP2 < 1; NoKartuP2 > JmlKartuP2)
            ->
                write('   [!] Index diluar jumlah kartu! Tolong input kembali.'), nl, !
            ;
                getCard(DeckP1, NoKartuP1, KartuP1),
                removeCard(DeckP1, NoKartuP1, DeckP1Removed),

                getCard(DeckP2, NoKartuP2, KartuP2),
                removeCard(DeckP2, NoKartuP2, DeckP2Removed),

                appendElem(DeckP1Removed, KartuP2, DeckP1Now),
                appendElem(DeckP2Removed, KartuP1, DeckP2Now),

                updatePemainList(P1, ListSemua, DeckP1Now, ListTemp),
                updatePemainList(P2, ListTemp, DeckP2Now, ListPemainBaru),

                asserta(sudahSwap(P1)),

                retractall(gameStatus(_, _, _)),
                asserta(gameStatus(ListPemainBaru, Discard, DrawPile)),

                format('Berhasil menukar kartu ke-~w Anda dengan kartu ke-~w milik ~w.~n', [NoKartuP1, NoKartuP2, P2]),
                format('Kartu baru Anda: ~w~n', [KartuP2]), !
            )
        )
    ).
