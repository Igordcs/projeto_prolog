import fetch from "node-fetch";
import fs from "fs";

const CHAVE_API = "5a88ca1bf5a69e2c706f8f19348f9a50";
const URL_BASE = "https://api.themoviedb.org/3";

async function main() {
  await salvarFilmes();
  escreverProlog();
}

async function salvarFilmes() {
  try {
    const filmes = await buscarFilmesAleatorios();
    const filmesProcessados = await processarFilmes(filmes);
    fs.writeFileSync("filmes.json", JSON.stringify(filmesProcessados, null, 2));
  } catch (erro) {
    console.error("Erro ao salvar filmes:", erro);
  }
}

async function buscarFilmesAleatorios() {
  const categorias = ["popular", "top_rated", "upcoming"];
  const categoriaAleatoria = categorias[Math.floor(Math.random() * categorias.length)];
  const page = Math.floor(Math.random() * 10) + 1;

  const resposta = await fetch(`${URL_BASE}/movie/${categoriaAleatoria}?api_key=${CHAVE_API}&language=pt-BR&page=${page}`);
  const dados = await resposta.json();
  return dados.results;
}

// Função para processar filmes (gêneros, atores e diretores)
async function processarFilmes(filmes) {
  const filmesProcessados = [];
  const generos = JSON.parse(fs.readFileSync("generos.json", "utf-8"));

  for (const filme of filmes) {
    const detalhes = await buscarDetalhesDoFilme(filme.id);

    filme.generos = filme.genre_ids.map((id) => generos[id] || id);
    filme.diretor = detalhes.credits.crew.find((pessoa) => pessoa.job === "Director")?.name || "Desconhecido";
    filme.elenco = detalhes.credits.cast.map((pessoa) => pessoa.name).slice(0, 5);

    filmesProcessados.push(filme);
  }

  return filmesProcessados;
}

async function buscarDetalhesDoFilme(idFilme) {
  try {
    const resposta = await fetch(`${URL_BASE}/movie/${idFilme}?api_key=${CHAVE_API}&language=pt-BR&append_to_response=credits`);
    const dados = await resposta.json();
    return dados;
  } catch (erro) {
    console.error("Erro ao buscar detalhes do filme:", erro);
    return null;
  }
}

// Função para carregar conteúdo Prolog existente
function carregarPredicadosProlog() {
  try {
    let conteudo = "";

    if (fs.existsSync("filmes_base.pl")) {
      conteudo = fs.readFileSync("filmes_base.pl", "utf-8");
    }

    const predicados = {
      filme: [],
      genero_filme: [],
      diretor_filme: [],
      ator_filme: [],
      ano_filme: [],
      avaliacao_filme: []
    };

    conteudo.split("\n").forEach((linha) => {
      if (linha.startsWith("filme(")) predicados.filme.push(linha);
      else if (linha.startsWith("genero_filme(")) predicados.genero_filme.push(linha);
      else if (linha.startsWith("diretor_filme(")) predicados.diretor_filme.push(linha);
      else if (linha.startsWith("ator_filme(")) predicados.ator_filme.push(linha);
      else if (linha.startsWith("ano_filme(")) predicados.ano_filme.push(linha);
      else if (linha.startsWith("avaliacao_filme(")) predicados.avaliacao_filme.push(linha);
    });

    return predicados;
  } catch (erro) {
    console.error("Erro ao inicializar conteúdo Prolog:", erro);
    return null;
  }
}

function escreverProlog() {
  try {
    if (!fs.existsSync("filmes.json")) {
      throw new Error("Arquivo filmes.json não encontrado.");
    }

    const filmesJSON = JSON.parse(fs.readFileSync("filmes.json", "utf-8"));
    const predicados = carregarPredicadosProlog();

    const IDsFilmesExistentes = new Set(predicados.ano_filme.map((linha) => parseInt(linha.match(/\d+/)[0])));
    const novosFilmes = filmesJSON.filter((filme) => !IDsFilmesExistentes.has(filme.id));

    if (novosFilmes.length === 0) return;

    novosFilmes.forEach((filme) => {
      const titulo = filme.title.replace(/"/g, '');
      const sinopse = filme.overview.replace(/"/g, '');
      const anoFilme = new Date(filme.release_date).getFullYear();
      const generos = filme.generos.map((genero) => `'${genero}'`).join(", ");
      const atores = filme.elenco.map((ator) => `"${ator}"`).join(", ");

      predicados.filme.push(
        `filme(${filme.id}, "${titulo}", "${sinopse}", ${anoFilme}, "${filme.diretor}", [${atores}], [${generos}], ${filme.vote_average}).`
      );

      filme.generos.forEach((genero) => {
        predicados.genero_filme.push(`genero_filme(${filme.id}, '${genero}').`);
      });

      filme.elenco.forEach((ator) => {
        predicados.ator_filme.push(`ator_filme(${filme.id}, '${ator.replace(/'/g, '')}').`);
      });

      predicados.diretor_filme.push(`diretor_filme(${filme.id}, '${filme.diretor}').`);
      predicados.ano_filme.push(`ano_filme(${filme.id}, ${anoFilme}).`);
      predicados.avaliacao_filme.push(`avaliacao_filme(${filme.id}, ${filme.vote_average}).`);
    });

    const conteudoProlog = [
      ...predicados.filme,
      "",
      ...predicados.genero_filme,
      "",
      ...predicados.ator_filme,
      "",
      ...predicados.diretor_filme,
      "",
      ...predicados.ano_filme,
      "",
      ...predicados.avaliacao_filme,
      ""
    ].join("\n");

    fs.writeFileSync("filmes_base.pl", conteudoProlog);
  } catch (erro) {
    console.error("Erro ao converter JSON para Prolog:", erro);
  }
}

main();
