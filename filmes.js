import fetch from "node-fetch";
import fs from "fs";

const CHAVE_API = "5a88ca1bf5a69e2c706f8f19348f9a50";
const URL_BASE = "https://api.themoviedb.org/3";

// Função principal
async function main() {
  try {
    await salvarFilmesAleatorios();
    converterParaProlog();
  } catch (erro) {
    console.error("Erro no processo principal:", erro);
  }
}

async function salvarFilmesAleatorios() {
  try {
    const filmes = await buscarFilmesDaAPI();
    const generos = JSON.parse(fs.readFileSync("generos.json", "utf-8"));
    const filmesProcessados = await processarFilmes(filmes, generos);

    fs.writeFileSync("filmes.json", JSON.stringify(filmesProcessados, null, 2));
  } catch (erro) {
    console.error("Erro ao salvar filmes:", erro);
  }
}

async function buscarFilmesDaAPI() {
  const categorias = ["popular", "top_rated", "upcoming"];
  const categoriaAleatoria =
    categorias[Math.floor(Math.random() * categorias.length)];
  const page = Math.floor(Math.random() * 10) + 1;

  const resposta = await fetch(
    `${URL_BASE}/movie/${categoriaAleatoria}?api_key=${CHAVE_API}&language=pt-BR&page=${page}`
  );
  const dados = await resposta.json();
  return dados.results;
}

// Função para processar filmes (substituir IDs de gêneros e buscar diretores)
async function processarFilmes(filmes, generos) {
  const filmesProcessados = [];

  for (const filme of filmes) {
    // Substituir IDs de gêneros pelos nomes
    filme.generos = filme.genre_ids.map((id) => generos[id] || id);

    // Buscar detalhes do filme (incluindo diretor)
    const detalhes = await buscarDetalhesDoFilme(filme.id);
    filme.diretor =
      detalhes.credits.crew.find((pessoa) => pessoa.job === "Director")?.name ||
      "Desconhecido";
    filmesProcessados.push(filme);
  }

  return filmesProcessados;
}

function carregarIdsDosFilmesExistentes() {
  try {
    const ids = new Set();

    if (!fs.existsSync("filmes_base.pl")) {
      return ids;
    }

    const conteudo = fs.readFileSync("filmes_base.pl", "utf-8");
    const regex = "/filme((d+),/g";
    let match;

    while ((match = regex.match(conteudo)) !== null) {
      ids.add(parseInt(match[1], 10));
    }

    return ids;
  } catch (erro) {
    console.error("Erro ao carregar IDs dos filmes existentes:", erro);
    return new Set();
  }
}

// Função para buscar detalhes de um filme (incluindo diretor)
async function buscarDetalhesDoFilme(idFilme) {
  try {
    const resposta = await fetch(
      `${URL_BASE}/movie/${idFilme}?api_key=${CHAVE_API}&language=pt-BR&append_to_response=credits`
    );
    const dados = await resposta.json();
    return dados;
  } catch (erro) {
    console.error("Erro ao buscar detalhes do filme:", erro);
    return null;
  }
}

function converterParaProlog() {
  try {
    if (!fs.existsSync("filmes.json")) {
      throw new Error("Arquivo filmes.json não encontrado.");
    }

    const filmes = JSON.parse(fs.readFileSync("filmes.json", "utf-8"));
    const idsExistentes = carregarIdsDosFilmesExistentes();
    const novosFilmes = filmes.filter((filme) => !idsExistentes.has(filme.id));

    if (novosFilmes.length === 0) return;

    let prologContent = "\n";

    novosFilmes.forEach((filme) => {
      const title = filme.title.replace(/"/g, '\\"');
      const overview = filme.overview.replace(/"/g, '\\"');
      prologContent += `filme(${
        filme.id
      }, "${title}", "${overview}", ${new Date(
        filme.release_date
      ).getFullYear()}, "${filme.diretor}", [${filme.generos
        .map((genero) => `"${genero}"`)
        .join(", ")}], ${filme.vote_average}).\n`;
    });

    prologContent += "\n";

    novosFilmes.forEach((filme) => {
      filme.generos.forEach((genero) => {
        prologContent += `genero_filme(${filme.id}, '${genero}').\n`;
      });
    });

    prologContent += "\n";

    novosFilmes.forEach((filme) => {
      prologContent += `diretor_filme(${filme.id}, '${filme.diretor}').\n`;
    });

    prologContent += "\n";

    novosFilmes.forEach((filme) => {
      prologContent += `ano_filme(${filme.id}, ${new Date(
        filme.release_date
      ).getFullYear()}).\n`;
    });

    prologContent += "\n";

    novosFilmes.forEach((filme) => {
      prologContent += `avaliacao_filme(${filme.id}, ${filme.vote_average}).\n`;
    });

    fs.appendFileSync("filmes_base.pl", prologContent);
  } catch (erro) {
    console.error("Erro ao converter JSON para Prolog:", erro);
  }
}

main();
