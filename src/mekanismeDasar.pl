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

    (JenisPilih == drawtwo ->
        SisaPemain = [player(NamaNext, StatusNext, DeckNext)|SisaLain],
        drawKartu(2, DrawPile, DeckNext, DrawPileNow, DeckNextNow),
        format('~w mengambil 2 kartu dari draw pile akibat drawtwo card!~n', [NamaNext]),
        
        PemainNext = player(NamaNext, StatusNext, DeckNextNow),
        (
            SisaLain == []
        ->
            PemainNow = player(Nama, StatusNow, DeckNow),
            ListFinal = [PemainNow, PemainNext],
            DiscardNow = [Played, KartuTerakhir | SisaDiscard],
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus(ListFinal, DiscardNow, DrawPileNow)),
            cekInfo, !
        ;
            appendElem(SisaLain, PemainNext, SisaPemainEfek),
            DiscardNow = [Played, KartuTerakhir | SisaDiscard],
            akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemainEfek, DiscardNow, DrawPile)
        )

    ; JenisPilih == rev ->
        (
            SisaPemain = [PemainKorban | []]
        ->
            PemainNow = player(Nama, StatusNow, DeckNow),
            ListFinal = [PemainNow, PemainKorban],
            DiscardNow = [Played, KartuTerakhir | SisaDiscard],
            write('Urutan giliran dibalik!'), nl,
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus(ListFinal, DiscardNow, DrawPile)),
            cekInfo, !
        ;
            reverseL(SisaPemain, ReversePlayer),
            appendElem(ReversePlayer, player(Nama, StatusNow, DeckNow), ListFinal),
            DiscardNow = [Played, KartuTerakhir | SisaDiscard],
            write('Urutan giliran dibalik!'), nl,
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus(ListFinal, DiscardNow, DrawPile)),
            cekInfo, !
        )

    ; JenisPilih == skip ->
        SisaPemain = [PemainKorban | SisaSetelahSkip],
        (
            SisaSetelahSkip == []
        ->
            PemainNow = player(Nama, StatusNow, DeckNow),
            ListFinal = [PemainNow, PemainKorban],
            DiscardNow = [Played, KartuTerakhir | SisaDiscard],
            write('Pemain berikutnya dilewati!'), nl,
            retractall(gameStatus(_, _, _)),
            asserta(gameStatus(ListFinal, DiscardNow, DrawPile)),
            cekInfo, !
        ;
            appendElem(SisaSetelahSkip, PemainKorban, SisaPemainEfek),
            DiscardNow = [Played, KartuTerakhir | SisaDiscard],
            write('Pemain berikutnya dilewati!'), nl,
            akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemainEfek, DiscardNow, DrawPile)
        )

    ; JenisPilih == wild ->
        write('Pilih warna yang mau dimainkan: '), nl,
        read(WarnaBaru),
        (
            warnaValid(WarnaBaru)
            ->
            true
        ;
            write('Warna tidak valid!'), nl,
            fail
        ),
        format('Warna yang dipilih : ~w~n', [WarnaBaru]),
        PlayedNow = kartu(WarnaBaru, wild),
        DiscardNow = [PlayedNow, KartuTerakhir | SisaDiscard], nl,
        akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemain, DiscardNow, DrawPile)

    ; JenisPilih == wilddrawfour ->
        SisaPemain = [player(NamaNext, StatusNext, DeckNext)|SisaLain],
        drawKartu(4, DrawPile, DeckNext,
        DrawPileNow, DeckNextNow),
        format('~w mengambil 4 kartu akibat Wild Draw Four!~n',[NamaNext]),
        PemainNext = player(NamaNext, StatusNext, DeckNextNow),
        appendElem(SisaLain, PemainNext, SisaPemainEfek),

        write('Pilih warna yang mau dimainkan: '), nl,
        read(WarnaBaru),
        format('Warna yang dipilih : ~w~n', [WarnaBaru]),
        PlayedNow = kartu(WarnaBaru, wilddrawfour),
        DiscardNow = [PlayedNow, KartuTerakhir | SisaDiscard],
        akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemainEfek, DiscardNow, DrawPileNow)

    ;
    DiscardNow = [Played, KartuTerakhir | SisaDiscard],
    akhiriGiliran(Nama, StatusNow, DeckNow,
    SisaPemain, DiscardNow, DrawPile)
    ).

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
