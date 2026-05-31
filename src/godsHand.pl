:- include('startGame.pl').
:- include('mekanismeDasar.pl').
:- include('primitif.pl').
:- include('cekInfo.pl').

cekBanyakKartu([]).
cekBanyakKartu([player(_Nama, _Status, Deck) | SisaPlayer]) :-
    getLen(Deck, X), 
    X =:= 1,
    cekBanyakKartu(SisaPlayer).

godsHand :-
    gameStatus([player(NamaPemanggil, Status, Deck) | SisaPemain], Discard, DrawPile),
    ListPemain = [player(NamaPemanggil, Status, Deck) | SisaPemain],

    (cekBanyakKartu(ListPemain) ->
        format('Gods Hand gagal dijalankan karena setiap pemain memiliki tepat 1 kartu.~n', []),
        akhiriGiliran(NamaPemanggil, Status, Deck, SisaPemain, Discard, DrawPile),
        !
    ;
        randomizeIdx(0, 100, Probability),
        (Probability < 20 ->
            
            pick2Random(ListPemain, Pemberi, Penerima),

            Pemberi = player(NamaPemberi, StatusPemberi, DeckPemberi),
            Penerima = player(NamaPenerima, StatusPenerima, DeckPenerima),

            (bisaUni(NamaPemberi) ->
                retractall(statusUNI(NamaPemberi)),
                asserta(statusUNI(NamaPemberi))
            ;
                true
            ),

            getLen(DeckPemberi, LenPemberi),
            BatasKartu is LenPemberi + 1,
            randomizeIdx(1, BatasKartu, IdxKartu),
            getCard(DeckPemberi, IdxKartu, KartuTerpilih),
            removeCard(DeckPemberi, IdxKartu, DeckPemberiNow),

            DeckPenerimaNow = [KartuTerpilih | DeckPenerima],

            (DeckPemberiNow == [] ->
                StatusPemberiNow = menang
            ;
                StatusPemberiNow = StatusPemberi
            ),

            updatePemainList(NamaPemberi, ListPemain, DeckPemberiNow, ListPemainSementara),
            updatePemainList(NamaPenerima, ListPemainSementara, DeckPenerimaNow, ListFinal),

            pindahGiliran(ListFinal, ListPemainNow),

            retractall(gameStatus(_, _, _)),
            asserta(gameStatus(ListPemainNow, Discard, DrawPile)),

            KartuTerpilih = kartu(W, J),
            write('Tuhan telah berkehendak.'), nl,
            format('Kartu ~w-~w milik ~w berpindah tangan ke ~w~n', [W, J, NamaPemberi, NamaPenerima]),

            (StatusPemberiNow == menang -> 
                format('~w Menang!~n', [NamaPemberi]),
                endGame 
            ; 
                true
            ),
            cekInfo, !
        ;
            format("Pemanggilan God's Hand gagal dilakukan oleh ~w~n", [NamaPemanggil]),
            akhiriGiliran(NamaPemanggil, Status, Deck, SisaPemain, Discard, DrawPile), !
        )
    ).

    