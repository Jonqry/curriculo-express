const express = require('express');
const banco = require('./banco');
const router = express.Router();

const tabelas = {
  pessoas: ['nome', 'email', 'cidade', 'titulo', 'resumo', 'github', 'linkedin'],
  formacoes: ['pessoa_id', 'curso', 'instituicao', 'tipo', 'ano_inicio', 'ano_fim', 'descricao'],
  experiencias: ['pessoa_id', 'cargo', 'empresa', 'ano_inicio', 'ano_fim', 'descricao'],
  projetos: ['pessoa_id', 'titulo', 'descricao', 'ano', 'link'],
  tecnologias: ['nome'],
  projeto_tecnologias: ['projeto_id', 'tecnologia_id']
};

const idValido = (id) => Number.isSafeInteger(Number(id)) && Number(id) > 0;
function tratarErro(erro, res) {
  if (erro.code === '23503') return res.status(400).json({ erro: 'Relacionamento inválido: ID não existe.' });
  if (erro.code === '23505') return res.status(409).json({ erro: 'Registro já cadastrado.' });
  if (['23502', '22P02', '23514', '22003'].includes(erro.code)) return res.status(400).json({ erro: 'Dados inválidos.' });
  console.error(erro);
  return res.status(500).json({ erro: 'Erro no banco.' });
}

Object.entries(tabelas).forEach(([tabela, permitidos]) => {
  router.get('/' + tabela, async (req, res) => {
    try { res.json((await banco.query('SELECT * FROM ' + tabela + ' ORDER BY id')).rows); }
    catch (erro) { tratarErro(erro, res); }
  });

  router.get('/' + tabela + '/:id', async (req, res) => {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    try {
      const rows = (await banco.query('SELECT * FROM ' + tabela + ' WHERE id=$1', [req.params.id])).rows;
      if (!rows.length) return res.status(404).json({ erro: 'Registro não encontrado.' });
      res.json(rows[0]);
    } catch (erro) { tratarErro(erro, res); }
  });

  router.post('/' + tabela, async (req, res) => {
    if (!req.body || Array.isArray(req.body) || typeof req.body !== 'object') return res.status(400).json({ erro: 'Envie um objeto JSON.' });
    const campos = Object.keys(req.body);
    if (!campos.length || campos.some(c => !permitidos.includes(c))) return res.status(400).json({ erro: 'Campos permitidos: ' + permitidos.join(', ') });
    const marcadores = campos.map((_, i) => '$' + (i + 1)).join(', ');
    try {
      const sql = 'INSERT INTO ' + tabela + ' (' + campos.join(', ') + ') VALUES (' + marcadores + ') RETURNING *';
      const rows = (await banco.query(sql, campos.map(c => req.body[c]))).rows;
      res.status(201).json(rows[0]);
    } catch (erro) { tratarErro(erro, res); }
  });

  router.put('/' + tabela + '/:id', async (req, res) => {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    if (!req.body || Array.isArray(req.body) || typeof req.body !== 'object') return res.status(400).json({ erro: 'Envie um objeto JSON.' });
    const campos = Object.keys(req.body);
    if (!campos.length || campos.some(c => !permitidos.includes(c))) return res.status(400).json({ erro: 'Campos inválidos.' });
    const atribuicoes = campos.map((c, i) => c + '=$' + (i + 1)).join(', ');
    try {
      const sql = 'UPDATE ' + tabela + ' SET ' + atribuicoes + ' WHERE id=$' + (campos.length + 1) + ' RETURNING *';
      const rows = (await banco.query(sql, [...campos.map(c => req.body[c]), req.params.id])).rows;
      if (!rows.length) return res.status(404).json({ erro: 'Registro não encontrado.' });
      res.json(rows[0]);
    } catch (erro) { tratarErro(erro, res); }
  });

  router.delete('/' + tabela + '/:id', async (req, res) => {
    if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
    try {
      const rows = (await banco.query('DELETE FROM ' + tabela + ' WHERE id=$1 RETURNING id', [req.params.id])).rows;
      if (!rows.length) return res.status(404).json({ erro: 'Registro não encontrado.' });
      res.status(204).send();
    } catch (erro) { tratarErro(erro, res); }
  });
});

router.get('/pessoas/:id/curriculo', async (req, res) => {
  if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
  try {
    const id = req.params.id;
    const pessoa = (await banco.query('SELECT * FROM pessoas WHERE id=$1', [id])).rows[0];
    if (!pessoa) return res.status(404).json({ erro: 'Pessoa não encontrada.' });
    const [formacoes, experiencias, projetos, ligacoes] = await Promise.all([
      banco.query('SELECT * FROM formacoes WHERE pessoa_id=$1 ORDER BY ano_inicio DESC NULLS LAST, id DESC', [id]),
      banco.query('SELECT * FROM experiencias WHERE pessoa_id=$1 ORDER BY ano_inicio DESC NULLS LAST, id DESC', [id]),
      banco.query('SELECT * FROM projetos WHERE pessoa_id=$1 ORDER BY ano DESC NULLS LAST, id DESC', [id]),
      banco.query('SELECT pt.projeto_id, t.id, t.nome FROM projeto_tecnologias pt JOIN tecnologias t ON t.id=pt.tecnologia_id JOIN projetos p ON p.id=pt.projeto_id WHERE p.pessoa_id=$1 ORDER BY t.nome', [id])
    ]);
    res.json({
      pessoa,
      formacoes: formacoes.rows,
      experiencias: experiencias.rows,
      projetos: projetos.rows.map(p => ({
        ...p,
        tecnologias: ligacoes.rows.filter(x => x.projeto_id === p.id).map(x => ({ id: x.id, nome: x.nome }))
      }))
    });
  } catch (erro) { tratarErro(erro, res); }
});

router.get('/projetos/:id/tecnologias', async (req, res) => {
  if (!idValido(req.params.id)) return res.status(400).json({ erro: 'ID inválido.' });
  try {
    const projeto = (await banco.query('SELECT id FROM projetos WHERE id=$1', [req.params.id])).rows[0];
    if (!projeto) return res.status(404).json({ erro: 'Projeto não encontrado.' });
    const rows = (await banco.query('SELECT pt.id AS ligacao_id, t.id, t.nome FROM projeto_tecnologias pt JOIN tecnologias t ON t.id=pt.tecnologia_id WHERE pt.projeto_id=$1 ORDER BY t.nome', [req.params.id])).rows;
    res.json(rows);
  } catch (erro) { tratarErro(erro, res); }
});

module.exports = router;
