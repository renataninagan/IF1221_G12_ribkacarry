% menampilkan kartu pemain

lihatKartu :-
    gameStatus(SemuaPemain, _, _),
    SemuaPemain = [player(Nama, _, ListKartu) | _],
    gameMode(Mode),
    (
        Mode == klasik 
    ->
        write('List Kartu'), nl,
        tampilkanKartu(Nama, ListKartu, 1)
    ;    
        write('List Kartu'), nl,
        tampilkanKartu(Nama, ListKartu, 1),

        timPemain(Nama, Regu),

        (
            isMem(player(Teman, _, KartuTeman), SemuaPemain), Teman \== Nama, timPemain(Teman, Regu)
        ->
            format('~nList Kartu Teman Anda (~w)~n', [Teman]),
            tampilkanKartu(Teman, KartuTeman, 1)
        ;
            true
        )
    ),
    
    !.

tampilkanKartu(_, [], _).

tampilkanKartu(Nama, [kartu(Warna, Jenis) | Rest], No) :-
    (kartuTersembunyi(Nama, No) 
    -> 
    write(No),
    write('. [KARTU TERSEMBUNYI]'),
    nl
    ;
    write(No),
    write('. '),
    write(Warna),
    write('-'),
    write(Jenis),
    nl
    ),
    Noke is No + 1,
    tampilkanKartu(Nama, Rest, Noke).