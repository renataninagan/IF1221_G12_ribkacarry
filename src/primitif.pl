randomizeIdx(I,N,X) :- random(I, N, X).

getCard([H|_],1,H).
getCard([_|T],I,H) :-
    I > 1,
    I1 is I-1,
    getCard(T, I1, H).

removeCard([_|T], 1, T).
removeCard([H|T], I, [H|UT]) :-
    I > 1,
    I1 is I-1,
    removeCard(T, I1, UT).

appendElem([], Element, [Element]).
appendElem([Head|Tail], Element, [Head|NewTail]) :-
    appendElem(Tail, Element, NewTail).

getLen([], 0).
getLen([_|Tail], Length) :-
    getLen(Tail, TailLength),
    Length is TailLength + 1.

getIdx0([_|Tail], Index, Element) :-
    Index > 0,
    NewIndex is Index - 1,
    getIdx0(Tail, NewIndex, Element).
getIdx0([Element|_], 0, Element).

reverseL(List, Reversed) :-
    reverseH(List, [], Reversed).
reverseH([], Accumulator, Accumulator).
reverseH([Head|Tail], Accumulator, Reversed) :-
    reverseH(Tail, [Head|Accumulator], Reversed).
    
pemainTerakhir([X], X).
pemainTerakhir([_|T], X) :- pemainTerakhir(T, X).

cutLastElem([_], []).
cutLastElem([H|T], [H|R]) :- cutLastElem(T, R).

pick2Random(List, El1, El2) :-
    getLen(List, Len),
    Len >= 2,

    Batas1 is Len + 1,
    randomizeIdx(1, Batas1, IdxEl1),
    getCard(List, IdxEl1, El1),
    removeCard(List, IdxEl1, ListTemp),

    LenSisa is Len - 1,
    Batas2 is LenSisa + 1,
    randomizeIdx(1, Batas2, IdxEl2),
    getCard(ListTemp, IdxEl2, El2).

cekSisaKartuPemain([], 0).
cekSisaKartuPemain([player(_Nama, _Status, Deck) | SisaPemain], Jumlah) :-
    getLen(Deck, Len),
    cekSisaKartuPemain(SisaPemain, SisaKartu),
    ( L =:= 1 ->
        Jumlah is SisaKartu + 1
    ;
        Jumlah is SisaKartu
    ).

lastElem([X], X).
lastElem([_|T], X) :-
    lastElem(T, X).

isMem(X, [X|_]).
isMem(X, [_|T]) :-
    isMem(X, T).
