pindahGiliran([Pemain|SisaPemain], ListPemainNow) :-
    appendElem(SisaPemain, Pemain, ListPemainNow).

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
    appendElem(SisaPemain, PemainNow, ListPemainNow),
    retractall(gameStatus(_, _, _)),
    asserta(gameStatus(ListPemainNow, Discard, DrawPileNow)),
    (
        StatusNow == menang ->
        format('~w Menang!~n', [Nama]),
        endGame
    ;
        cekInfo
    ),

    !.

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

mainkanKartu(N) :-
    gameStatus([player(Nama, Status, Deck)|SisaPemain], [KartuTerakhir|SisaDiscard], DrawPile),
    retractall(statusUNI(Nama)),
    KartuTerakhir = kartu(WarnaTerakhir, JenisTerakhir),
    length(Deck, L),
    (
        N >= 1,
        N =< L
    ->
        true
    ;
        format('Tidak ada kartu ke ~w! Pilih kartu antara 1 - ~w.~n', [N, L]),
        write('Pilih nomor kartu (angka saja, diakhiri titik): '),
        read(NBaru),
        mainkanKartu(NBaru),
        !
    ),

    getCard(Deck, N, Played),
    Played = kartu(WarnaPilih, JenisPilih),

    (
        WarnaPilih == hitam,
        JenisPilih == wilddrawfour,
        kartuCocokSelainHitam(Deck, WarnaTerakhir, JenisTerakhir)
    ->
        write('Wild Draw Four tidak boleh digunakan. Ada kartu lain yang dapat digunakan.'), nl,
        write('Pilih nomor kartu lagi: '),
        read(NBaru),
        !,
        mainkanKartu(NBaru),
        !
    ;
        true
    ),

    (
        (JenisPilih == drawtwo, JenisTerakhir == drawtwo)
    ->
        write('Draw Two tidak boleh ditumpuk!'), nl,
        write('Pilih nomor kartu lagi: '),
        read(NBaru), mainkanKartu(NBaru), !
    ;
        true
    ),

    (
        (JenisPilih == wild, JenisTerakhir == wild)
    ->
        write('Wild tidak boleh ditumpuk!'), nl,
        write('Pilih nomor kartu lagi: '),
        read(NBaru), mainkanKartu(NBaru), !
    ;
        true
    ),
    (
        (JenisPilih == wilddrawfour, JenisTerakhir == wilddrawfour)
    ->
        write('Wild Draw Four tidak boleh ditumpuk!'), nl,
        write('Pilih nomor kartu lagi: '),
        read(NBaru), mainkanKartu(NBaru), !
    ;
        true
    ),

    (
        (
            WarnaPilih == WarnaTerakhir
        ;
            JenisPilih == JenisTerakhir
        ;
            (
                WarnaPilih == hitam,
                JenisTerakhir \== wild,
                JenisTerakhir \== wilddrawfour
            )
        )
    ->
        kartuCocok(Nama, Status, Deck, N, Played, SisaPemain, KartuTerakhir, SisaDiscard, DrawPile),
        !
    ;
        kartuTidakCocok(Nama, Deck, KartuTerakhir),
        !
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

    format('~w mengeluarkan kartu : ~w ~w~n', [Nama, WarnaPilih, JenisPilih]),
    DiscardNow = [Played, KartuTerakhir | SisaDiscard],
    applyEffect(JenisPilih, Played, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow).

kartuTidakCocok(Nama, Deck, KartuTerakhir) :-
    write('Kartu tidak cocok! Pilih kartu lain.'), nl,
    (\+ adaKartu(Deck, KartuTerakhir) -> format('~w tidak punya kartu yang cocok, otomatis mengambil kartu.~n', [Nama]),ambilKartu; true),fail.

tantang :-
    gameStatus([player(NamaTantang, StatusTantang, DeckTantang)|SisaPemain],
    [KartuTerakhir|SisaDiscard], DrawPile),

    (KartuTerakhir = kartu(_, wilddrawfour) ->
        true
    ;
        write('Tidak ada wild draw four yang bisa ditantang!'), nl, fail
    ),

    write('Tantangan dilakukan!'), nl,

    lastElem(SisaPemain, player(NamaPelaku, StatusPelaku, DeckPelaku)),

    format('Memeriksa kartu ~w...~n', [NamaPelaku]),

    (SisaDiscard = [KartuSebelum|_] ->
        KartuSebelum = kartu(WarnaSebelum, JenisSebelum)
    ;
        WarnaSebelum = none, JenisSebelum = none
    ),

    (kartuCocokSelainHitam(DeckPelaku, WarnaSebelum, JenisSebelum) ->
        write('Tantangan berhasil!'), nl,
        format('~w mendapatkan 4 kartu akibat ketahuan curang.~n', [NamaPelaku]),

        cutLastElem([player(NamaTantang, StatusTantang, DeckTantang)|SisaPemain],
                   SisaTanpaPelaku),
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
        
        cutLastElem([PemainTantangNow|SisaPemain], SisaTanpaPelaku2),
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
