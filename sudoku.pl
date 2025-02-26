:- use_module(library(clpfd)).

sudoku(Tabuleiro, Solucao) :-
    Solucao = Tabuleiro,
    append(Solucao, Vars), Vars ins 1..9,  % Define valores 1-9 para cada célula
    maplist(all_different, Solucao),  % Linhas únicas
    transpose(Solucao, Columns), 
    maplist(all_different, Columns), % Colunas únicas
    blocos(Solucao),  % Restrições dos blocos 3x3
    labeling([], Vars).  % Resolve o Sudoku

blocos(Solucao) :-
    Solucao = [A, B, C, D, E, F, G, H, I],
    blocos_helper(A, B, C),
    blocos_helper(D, E, F),
    blocos_helper(G, H, I).

blocos_helper([], [], []).
blocos_helper(
    [A1, A2, A3 | Resto1],
    [B1, B2, B3 | Resto2],
    [C1, C2, C3 | Resto3]
) :-
    all_different([A1, A2, A3, B1, B2, B3, C1, C2, C3]),
    blocos_helper(Resto1, Resto2, Resto3).

solve :-
    Tabuleiro = [[9, _, _, _, _, _, _, _, 3],
                 [_, 3, _, 8, _, _, _, _, 7],
                 [_, 7, _, _, 2, _, _, _, _],
                 [_, _, 2, _, _, _, _, 3, _],
                 [_, _, _, 6, _, 3, 7, _, _],
                 [_, _, _, _, _, _, _, _, _],
                 [_, _, _, _, 5, _, _, _, 6],
                 [4, _, _, _, _, _, _, 8, _],
                 [_, _, _, _, _, _, 5, _, 9]],
    sudoku(Tabuleiro, Solucao),
    maplist(print_row, Solucao).

print_row(Row) :-
    writeln(Row).