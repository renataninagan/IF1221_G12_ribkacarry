efekKartu(drawtwo, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow) :-
    asserta(riwayatAksi(Nama, drawtwo)),
    SisaPemain = [player(NamaNext, StatusNext, DeckNext)|SisaLain],
    drawKartu(2, DrawPile, DeckNext, DrawPileNow, DeckNextNow),
    format('~w mengambil 2 kartu dari draw pile akibat drawtwo card!~n', [NamaNext]),
    
    PemainNow = player(Nama, StatusNow, DeckNow),
    PemainNext = player(NamaNext, StatusNext, DeckNextNow),
    (
        SisaLain == []
    ->
        ListFinal = [PemainNow, PemainNext]
    ;
        appendElem(SisaLain, PemainNow, ListTemp),
        appendElem(ListTemp, PemainNext, ListFinal)
    ),
    retractall(gameStatus(_, _, _)),
    asserta(gameStatus(ListFinal, DiscardNow, DrawPileNow)),
    cekInfo, !.

efekKartu(rev, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow) :-
    asserta(riwayatAksi(Nama, rev)),
    write('Urutan giliran dibalik!'), nl,   
    (
        SisaPemain = [PemainKorban | []]
    ->
        PemainNow = player(Nama, StatusNow, DeckNow),
        ListFinal = [PemainNow, PemainKorban],
        retractall(gameStatus(_, _, _)),
        asserta(gameStatus(ListFinal, DiscardNow, DrawPile)),
        cekInfo, !
    ;
        reverseL(SisaPemain, ReversePlayer),
        appendElem(ReversePlayer, player(Nama, StatusNow, DeckNow), ListFinal),
        retractall(gameStatus(_, _, _)),
        asserta(gameStatus(ListFinal, DiscardNow, DrawPile)),
        cekInfo, !
    ).

efekKartu(skip, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow) :-
    asserta(riwayatAksi(Nama, skip)),
    SisaPemain = [PemainKorban | SisaSetelahSkip],
    write('Pemain berikutnya dilewati!'), nl,
    
    PemainNow = player(Nama, StatusNow, DeckNow),
    
    (
        SisaSetelahSkip == []
    ->
        ListFinal = [PemainNow, PemainKorban]
    ;
        appendElem(SisaSetelahSkip, PemainNow, ListTemp),
        appendElem(ListTemp, PemainKorban, ListFinal)
    ),
    
    retractall(gameStatus(_, _, _)),
    asserta(gameStatus(ListFinal, DiscardNow, DrawPile)),
    cekInfo, !.

efekKartu(wild, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow) :-
    asserta(riwayatAksi(Nama, wild)),
    gantiWarna(WarnaBaru),
    format('Warna yang dipilih : ~w~n', [WarnaBaru]), nl,

    (
        DiscardNow = [_KartuTerakhir | SisaDiscard] 
    -> 
        true
    ; 
        SisaDiscard = DiscardNow
    ),
    DiscardBaru = [kartu(WarnaBaru, wild) | SisaDiscard],
    akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemain, DiscardBaru, DrawPile).


efekKartu(wilddrawfour, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, [_KartuTerakhir | SisaDiscard]) :-
    asserta(riwayatAksi(Nama, wilddrawfour)),
    SisaPemain = [player(NamaNext, StatusNext, DeckNext)|SisaLain],
    drawKartu(4, DrawPile, DeckNext, DrawPileNow, DeckNextNow),
    format('~w mengambil 4 kartu akibat Wild Draw Four!~n',[NamaNext]),

    PemainNow = player(Nama, StatusNow, DeckNow),
    PemainNext = player(NamaNext, StatusNext, DeckNextNow),

    gantiWarna(WarnaBaru),
    format('Warna yang dipilih : ~w~n', [WarnaBaru]),
    DiscardBaru = [kartu(WarnaBaru, wilddrawfour) | SisaDiscard],
    (
        SisaLain == []
    ->
        ListFinal = [PemainNow, PemainNext]
    ;
        appendElem(SisaLain, PemainNow, ListTemp),
        appendElem(ListTemp, PemainNext, ListFinal)
    ),
    retractall(gameStatus(_, _, _)),
    asserta(gameStatus(ListFinal, DiscardBaru, DrawPileNow)),
    cekInfo, !.

efekKartu(mimic, kartu(WarnaTerakhir, mimic), Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow) :-
    DiscardNow = [_KartuTerakhirMimic|SisaDiscard],
    (   
        findAction(SisaDiscard, 0, kartu(WarnaAksi, JenisTerakhir), Turn)
    ->  
        (retract(riwayatAksi(NamaPemainLama, JenisTerakhir)) -> true ; NamaPemainLama = 'Pemain sebelumnya'),
        write('Menelusuri riwayat permainan'), nl,
        format('Kartu aksi terakhir yang dimainkan: ~w-~w oleh ~w ~w giliran lalu.~n ', [WarnaAksi, JenisTerakhir, NamaPemainLama, Turn]),
        format('Kartu mimic menyalin efek ~w~n', [JenisTerakhir]),
        DiscardGanti = [kartu(WarnaAksi, JenisTerakhir) | SisaDiscard],
        efekKartu(JenisTerakhir, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardGanti)
    ;   
        write('Tidak ada kartu aksi di tumpukan! Mimic bertingkah seperti kartu wild.'), nl,
        efekKartu(wild, kartu(WarnaTerakhir, wild), Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow)
    ).

efekKartu(_, _, Nama, StatusNow, DeckNow, SisaPemain, DrawPile, DiscardNow) :-
    akhiriGiliran(Nama, StatusNow, DeckNow, SisaPemain, DiscardNow, DrawPile).

findAction([Kartu|_], I, Kartu, I) :-
    Kartu = kartu(_, Jenis), 
    isMem(Jenis, [skip, rev, drawtwo, wild, wilddrawfour]),
    !.

findAction([kartu(_, _)|T],I, Kartu, Turn) :-
    I1 is I+1,
    findAction(T, I1, Kartu, Turn).

gantiWarna(WarnaBaru) :-
    write('Pilih warna yang mau dimainkan: '), nl,
    read(WarnaInput),
    (
        warnaValid(WarnaInput)
    ->
        WarnaBaru = WarnaInput 
    ;
        write('Warna tidak valid! Silakan coba lagi.'), nl, nl,
        gantiWarna(WarnaBaru) 
    ).