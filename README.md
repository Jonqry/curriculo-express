# Currículo Express

API REST de currículo feita com Node.js, Express e PostgreSQL (NeonDB), como atividade da faculdade.

## Como rodar
1. Instalar Node.js 20 ou mais recente.
2. Criar banco PostgreSQL no Neon e executar `banco.sql` no SQL Editor.
3. Copiar `.env.example` para `.env` e colar a URL real do Neon em `DATABASE_URL`.
4. Executar `npm install` e `npm run dev`.
5. Testar `http://localhost:3000/health` e `http://localhost:3000/pessoas`.

## Tabelas e relacionamentos
- pessoas (currículo principal)
- formacoes, experiencias e projetos: cada item pertence a uma pessoa
- tecnologias
- projeto_tecnologias: relação muitos para muitos entre projetos e tecnologias

## Rotas
Para cada tabela acima: GET `/tabela`, GET `/tabela/:id`, POST `/tabela`, PUT `/tabela/:id` e DELETE `/tabela/:id`.

Extras: GET `/pessoas/:id/curriculo` (currículo completo com relações) e GET `/projetos/:id/tecnologias`.
Os códigos HTTP incluem 200, 201, 204, 400, 404, 409 e 500.

## Exemplo de POST
```json
{"nome":"Pessoa teste","email":"teste@exemplo.com","cidade":"Recife - PE","titulo":"Estudante"}
```
Envie para POST `/pessoas` no Postman.

## Vercel
Importar este repositório pelo painel da Vercel. Em Environment Variables, configurar `DATABASE_URL` com a conexão PostgreSQL do Neon. Fazer deploy e conferir `/health`.

**Atenção:** o `.env` não pode ser enviado ao GitHub. Esta API é didática e não possui autenticação; os endpoints CRUD devem ser protegidos antes de expor dados reais ou aceitar escrita pública em produção.
