require('dotenv').config();
const express = require('express');
const cors = require('cors');
const banco = require('./src/banco');
const rotas = require('./src/rotas');

const app = express();
app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ mensagem: 'API Currículo online', rotas: '/pessoas, /formacoes, /experiencias, /projetos, /tecnologias, /projeto_tecnologias' });
});

app.get('/health', async (req, res) => {
  try {
    await banco.query('SELECT 1');
    res.json({ status: 'ok', banco: 'conectado' });
  } catch (erro) {
    console.error('Conexão com banco:', erro.message);
    res.status(503).json({ status: 'erro', banco: 'indisponível' });
  }
});

app.use(rotas);
app.use((req, res) => res.status(404).json({ erro: 'Rota não encontrada.' }));
app.use((erro, req, res, next) => {
  if (erro instanceof SyntaxError && 'body' in erro) {
    return res.status(400).json({ erro: 'JSON malformado.' });
  }
  console.error(erro);
  res.status(500).json({ erro: 'Erro interno.' });
});

module.exports = app;
