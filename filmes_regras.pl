:- consult('filmes_base.pl').

filme_por_id(ID, Titulo, Sinopse, Ano, Diretor, Autores, Generos, Avaliacao) :-
    filme(ID, Titulo, Sinopse, Ano, Diretor, Autores, Generos, Avaliacao).

filmes_por_genero(Genero, Titulo) :-
    genero_filme(ID, Genero),
    filme(ID, Titulo, _, _, _, _, _, _).

filmes_por_diretor(Diretor, Titulo) :-
    diretor_filme(ID, Diretor),
    filme(ID, Titulo, _, _, _, _, _, _).

filmes_por_ator(Ator, Titulo) :-
    ator_filme(ID, Ator),
    filme(ID, Titulo, _, _, _, _, _, _).

filmes_por_ano(Ano, Titulo) :-
    ano_filme(ID, Ano),
    filme(ID, Titulo, _, _, _, _, _, _).

melhores_filmes(AvaliacaoMinima, Titulo) :-
    avaliacao_filme(ID, Avaliacao),
    Avaliacao >= AvaliacaoMinima,
    filme(ID, Titulo, _, _, _, _, _, _).