% menampilkan kartu pemain

lihatKartu :-
    gameStatus([player(Nama,_,ListKartu)|_], _, _),
    tampilkanKartu(Nama, ListKartu, 1),
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