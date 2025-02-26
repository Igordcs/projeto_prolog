:- consult('filmes_base.pl').
:- dynamic generos_preferidos/1.
:- dynamic diretores_preferidos/1.
:- dynamic atores_preferidos/1.

:- assertz(generos_preferidos([])).
:- assertz(diretores_preferidos([])).
:- assertz(atores_preferidos([])).

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

menu :-
    writeln("===== RECOMENDADOR DE FILMES ====="),
    writeln('Bem-vindo ao Recomendador de Filmes!'),
    writeln('Escolha uma opção:'),
    writeln('1. Adicionar gênero preferido'),
    writeln('2. Remover gênero preferido'),
    writeln('3. Ver gêneros preferidos'),
    writeln('4. Adicionar diretor preferido'),
    writeln('5. Remover diretor preferido'),
    writeln('6. Ver diretores preferidos'),
    writeln('7. Adicionar ator preferido'),
    writeln('8. Remover ator preferido'),
    writeln('9. Ver atores preferidos'),
    writeln('10. Ver recomendações'),
    writeln('11. Sair'),
    read(Opcao),
    (Opcao = 1 -> adicionar_genero;
     Opcao = 2 -> remover_genero;
     Opcao = 3 -> ver_generos;
     Opcao = 4 -> adicionar_diretor;
     Opcao = 5 -> remover_diretor;
     Opcao = 6 -> ver_diretores;
     Opcao = 7 -> adicionar_ator;
     Opcao = 8 -> remover_ator;
     Opcao = 9 -> ver_atores;
     Opcao = 10 -> ver_recomendacoes;
     Opcao = 11 -> writeln('Saindo...'), halt;
     writeln('Opção inválida!'), menu).

% Adicionar gênero preferido
adicionar_genero :-
    writeln('Digite o gênero que deseja adicionar:'),
    read(Genero),
    (generos_preferidos(Lista) ->
        (member(Genero, Lista) -> writeln('Gênero já está na lista.');
         retract(generos_preferidos(Lista)),
         assertz(generos_preferidos([Genero|Lista])),
         writeln('Gênero adicionado com sucesso!');
    assertz(generos_preferidos([Genero])))),
    menu.

% Remover gênero preferido
remover_genero :-
    writeln('Digite o gênero que deseja remover:'),
    read(Genero),
    (generos_preferidos(Lista) ->
        (select(Genero, Lista, NovaLista) ->
            retract(generos_preferidos(Lista)),
            assertz(generos_preferidos(NovaLista)),
            writeln('Gênero removido com sucesso!');
        writeln('Gênero não encontrado na lista.');
    writeln('Nenhum gênero foi adicionado ainda.'))),
    menu.

% Ver gêneros preferidos
ver_generos :-
    (generos_preferidos(Lista) ->
        (Lista = [] -> writeln('Nenhum gênero foi adicionado ainda.');
         writeln('Gêneros preferidos:'), listar_itens(Lista));
    writeln('Nenhum gênero foi adicionado ainda.')),
    menu.

% Adicionar diretor preferido
adicionar_diretor :-
    writeln('Digite o diretor que deseja adicionar:'),
    read(Diretor),
    (diretores_preferidos(Lista) ->
        (member(Diretor, Lista) -> writeln('Diretor já está na lista.');
         retract(diretores_preferidos(Lista)),
         assertz(diretores_preferidos([Diretor|Lista])),
         writeln('Diretor adicionado com sucesso!');
    assertz(diretores_preferidos([Diretor])))),
    menu.

% Remover diretor preferido
remover_diretor :-
    writeln('Digite o diretor que deseja remover:'),
    read(Diretor),
    (diretores_preferidos(Lista) ->
        (select(Diretor, Lista, NovaLista) ->
            retract(diretores_preferidos(Lista)),
            assertz(diretores_preferidos(NovaLista)),
            writeln('Diretor removido com sucesso!');
        writeln('Diretor não encontrado na lista.');
    writeln('Nenhum diretor foi adicionado ainda.'))),
    menu.

% Ver diretores preferidos
ver_diretores :-
    (diretores_preferidos(Lista) ->
        (Lista = [] -> writeln('Nenhum diretor foi adicionado ainda.');
         writeln('Diretores preferidos:'), listar_itens(Lista));
    writeln('Nenhum diretor foi adicionado ainda.')),
    menu.

% Adicionar ator preferido
adicionar_ator :-
    writeln('Digite o ator que deseja adicionar:'),
    read(Ator),
    (atores_preferidos(Lista) ->
        (member(Ator, Lista) -> writeln('Ator já está na lista.');
         retract(atores_preferidos(Lista)),
         assertz(atores_preferidos([Ator|Lista])),
         writeln('Ator adicionado com sucesso!');
    assertz(atores_preferidos([Ator])))),
    menu.

% Remover ator preferido
remover_ator :-
    writeln('Digite o ator que deseja remover:'),
    read(Ator),
    (atores_preferidos(Lista) ->
        (select(Ator, Lista, NovaLista) ->
            retract(atores_preferidos(Lista)),
            assertz(atores_preferidos(NovaLista)),
            writeln('Ator removido com sucesso!');
        writeln('Ator não encontrado na lista.');
    writeln('Nenhum ator foi adicionado ainda.'))),
    menu.

% Ver atores preferidos
ver_atores :-
    (atores_preferidos(Lista) ->
        (Lista = [] -> writeln('Nenhum ator foi adicionado ainda.');
         writeln('Atores preferidos:'), listar_itens(Lista));
    writeln('Nenhum ator foi adicionado ainda.')),
    menu.

% Ver recomendações
ver_recomendacoes :-
    (generos_preferidos(Generos), diretores_preferidos(Diretores), atores_preferidos(Atores) ->
        (Generos = [], Diretores = [], Atores = [] -> writeln('Adicione gêneros, diretores ou atores para ver recomendações.');
         findall(Titulo, (filmes_por_genero_ou_diretor_ou_ator(Generos, Diretores, Atores, Titulo)), Titulos),
         (Titulos = [] -> writeln('Nenhum filme encontrado com base nas suas preferências.');
          writeln('Filmes recomendados:'), listar_filmes(Titulos)));
    writeln('Adicione gêneros, diretores ou atores para ver recomendações.')),
    menu.

% Função para buscar filmes por gênero, diretor ou ator
filmes_por_genero_ou_diretor_ou_ator(Generos, Diretores, Atores, Titulo) :-
    (member(Genero, Generos), filmes_por_genero(Genero, Titulo);
     member(Diretor, Diretores), filmes_por_diretor(Diretor, Titulo);
     member(Ator, Atores), filmes_por_ator(Ator, Titulo)).

% Listar itens (gêneros, diretores ou atores)
listar_itens([]).
listar_itens([Item|Resto]) :-
    writeln(Item),
    listar_itens(Resto).

% Listar filmes encontrados
listar_filmes([]).
listar_filmes([Titulo|Resto]) :-
    writeln(Titulo),
    listar_filmes(Resto).

% Iniciar o programa
:- menu.