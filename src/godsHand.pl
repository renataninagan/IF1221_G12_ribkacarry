:- include('startGame.pl').
:- include('mekanismeDasar.pl').
:- include('primitif.pl').
:- include('cekInfo.pl').

godsHand :-
    gameStatus([player(NamaPemanggil, Status, Deck) | SisaPemain], Discard, DrawPile),

    randomizeIdx(0, 100, Probability),
    (Probability < 20 ->
        true
    ;
        format("Pemanggilan God's Hand gagal dilakukan ~w ", [NamaPemanggil]), nl, !, fail
    
    ),

    ListPemain is [player(NamaPemanggil, Status, Deck) | SisaPemain],
    pickRandom(2, ListPemain, [Pemberi | Penerima]),

    Pemberi = player(NamaPemberi, StatusPemberi, DeckPemberi),
    Penerima = player(NamaPenerima, StatusPenerima, DeckPenerima),

    getLen(DeckPemberi, LenPemberi),

    randomizeIdx(1, LenPemberi, IdxKartu),
    getCard(DeckPemberi, IdxKartu, KartuTerpilih),
    removeCard(DeckPemberi, IdxKartu, DeckPemberiNow),

    appendElem(KartuTerpilih, DeckPenerima, DeckPenerimaNow),

    (DeckPemberiNow =:= 0 ->
        StatusPemberiNow = menang
    ;
        StatusPemberiNow = StatusPemberi
    ),

    PemberiNow = player(NamaPemberi, StatusPemberiNow, DeckPemberiNow),
    PenerimaNow = player(NamaPenerima, StatusPeneri, DeckPenerimaNow),

    updatePemainList(NamaPemberi, ListPemain, DeckPemberiNow, ListPemainSementara1),
    updatePemainList(NamaPenerima, ListPemain, DeckPenerimaNow, ListFinal),

    pindahGiliran(ListFinal, ListPemainNow),

    retractall(gamestatus(_, _, _)),
    asserta(gameStatus(ListPemainNow, Discard, DrawPile)),

    write('Tuhan telah berkehendak.'), nl,
    format('Kartu ~w milik ~w berpindah tangan ke ~w', [KartuTerpilih, NamaPemberi, NamaPenerima]),

    (StatusPemberiNow == menang -> 
        format('~w Menang!~n', [NamaPemberi]) 
    ; 
        true
    ),

    cekInfo.