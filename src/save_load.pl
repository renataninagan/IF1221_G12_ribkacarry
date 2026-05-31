/*save*/
saveGame :-
    isStart(true),
    write('Masukkan nama file penyimpanan: '),
    read(NamaFile),

    atom_concat(NamaFile, '.txt', FilePath),

    open(FilePath, write, Stream),
    gameStatus(ListPlayer, DiscardPile, DrawPile),
    gameMode(Mode),

    writeq(Stream, gameStatus(ListPlayer, DiscardPile, DrawPile)),
    write(Stream,'.'), nl(Stream),

    writeq(Stream, gameMode(Mode)),
    write(Stream,'.'), nl(Stream),

    forall(
        statusUNI(NamaUNI),
        (
            writeq(Stream, statusUNI(NamaUNI)),
            write(Stream,'.'),
            nl(Stream)
        )
    ),
    (
        Mode == turnamen
    ->
        forall(
            timPemain(Nama, Tim),
            (
                writeq(Stream, timPemain(Nama, Tim)),
                write(Stream,'.'),
                nl(Stream)
            )
        )
    ;
        true
    ),

    close(Stream),
    format(
        'Status permainan berhasil disimpan ke ~w.~n',
        [FilePath]
    ).

loadGame :-
    write('Masukkan nama file yang akan dimuat: '),
    read(NamaFile),

    atom_concat(NamaFile, '.txt', FilePath),

    (
        exists_file(FilePath)
    ->
        retractall(gameStatus(_,_,_)),
        retractall(gameMode(_)),
        retractall(statusUNI(_)),
        retractall(timPemain(_,_)),
        retractall(isStart(_)),

        consult(FilePath),

        asserta(isStart(true)),

        gameStatus(
            [player(Giliran,_,_)|_],
            _,
            _
        ),

        format(
            'Status permainan berhasil dimuat dari ~w.~n',
            [FilePath]
        ),

        format(
            'Melanjutkan giliran ~w.~n',
            [Giliran]
        ),

        (
            gameMode(turnamen)
        ->
            nl,
            write('Mode permainan : TURNAMEN'), nl,
            write('Komposisi tim yang dimuat:'), nl,

            forall(
                timPemain(Nama, Tim),
                format(' - ~w : ~w~n',[Nama,Tim])
            )
        ;
            nl,
            write('Mode permainan : KLASIK'), nl
        )

    ;
        write('File tidak ditemukan!'), nl
    ).