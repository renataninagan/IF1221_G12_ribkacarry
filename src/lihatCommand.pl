lihatCommand :-
    gameStatus(ListPlayer, DiscardPile, DrawPile),
    ListPlayer = [player(_,Status,Deck)|_],
    DiscardPile = [KartuTerakhir|_],
    write('Aksi utama yang tersedia :'), nl,
    (Status == 'main' -> write('1. mainKartu'), nl; true),
    ((\+ adaKartu(Deck, KartuTerakhir)) -> write('2. ambilKartu'), nl; true),
    % (bisaTantang -> write('3. tantang'), nl; true),
    nl,
    write('Aksi pendukung yang tersedia'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl.