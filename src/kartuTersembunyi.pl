:- dynamic(kartuTersembunyi/2).

sembunyikanKartu(N) :-
    gameStatus([player(Nama, Status, Deck) | SisaPemain], Discard, DrawPile),

    length(Deck, L),
    ( L =:= 1 ->
        write('Tidak dapat menyembunyikan kartu jika hanya memiliki 1 kartu.'), nl,
        fail
    ; true ),

    ( N >= 1, N =< L ->
        true
    ;
        format('Tidak ada kartu ke ~w! Pilih kartu antara 1 - ~w.~n', [N, L]),
        fail
    ),

    retractall(kartuTersembunyi(Nama, _)),
    assertz(kartuTersembunyi(Nama, N)),

    retractall(gameStatus(_, _, _)),
    asserta(gameStatus([player(Nama, Status, Deck) | SisaPemain], Discard, DrawPile)),

    write('Kartu berhasil disembunyikan.'), nl,
    cekInfo.

kembalikanKartu :-
    gameStatus([player(Nama, _, _) | _], _, _),
    ( 
        kartuTersembunyi(Nama, _) 
        ->
        retractall(kartuTersembunyi(Nama, _)),
        write('Kartu berhasil ditampilkan kembali.'), nl,
        cekInfo,
        !
    ;
        format('~w tidak memiliki kartu yang disembunyikan.~n', [Nama]),
        fail
    ).

cekTangkap(Target) :-
    ( kartuTersembunyi(Target, _) ->
        write('Terdapat kartu yang disembunyikan oleh '),
        write(Target), write('.'), nl,
        write('Perintah tangkap tidak valid.'), nl,
        fail
    ;
        true
    ).