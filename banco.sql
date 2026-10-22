-- Schema e carga inicial. Dados fictícios identificados.
CREATE TABLE IF NOT EXISTS pessoas (
 id SERIAL PRIMARY KEY, nome VARCHAR(120) NOT NULL,
 email VARCHAR(150) NOT NULL UNIQUE, cidade VARCHAR(100),
 titulo VARCHAR(150), resumo TEXT, github VARCHAR(250), linkedin VARCHAR(250)
);
CREATE TABLE IF NOT EXISTS formacoes (
 id SERIAL PRIMARY KEY, pessoa_id INTEGER NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
 curso VARCHAR(160) NOT NULL, instituicao VARCHAR(160) NOT NULL, tipo VARCHAR(60),
 ano_inicio INTEGER, ano_fim INTEGER, descricao TEXT, UNIQUE(pessoa_id,curso,instituicao)
);
CREATE TABLE IF NOT EXISTS experiencias (
 id SERIAL PRIMARY KEY, pessoa_id INTEGER NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
 cargo VARCHAR(150) NOT NULL, empresa VARCHAR(150) NOT NULL,
 ano_inicio INTEGER, ano_fim INTEGER, descricao TEXT, UNIQUE(pessoa_id,cargo,empresa)
);
CREATE TABLE IF NOT EXISTS projetos (
 id SERIAL PRIMARY KEY, pessoa_id INTEGER NOT NULL REFERENCES pessoas(id) ON DELETE CASCADE,
 titulo VARCHAR(150) NOT NULL, descricao TEXT, ano INTEGER, link VARCHAR(300),
 UNIQUE(pessoa_id,titulo)
);
CREATE TABLE IF NOT EXISTS tecnologias (id SERIAL PRIMARY KEY, nome VARCHAR(100) NOT NULL UNIQUE);
CREATE TABLE IF NOT EXISTS projeto_tecnologias (
 id SERIAL PRIMARY KEY, projeto_id INTEGER NOT NULL REFERENCES projetos(id) ON DELETE CASCADE,
 tecnologia_id INTEGER NOT NULL REFERENCES tecnologias(id) ON DELETE CASCADE,
 UNIQUE(projeto_id,tecnologia_id)
);

INSERT INTO pessoas(nome,email,cidade,titulo,resumo,github) VALUES
('João Victor Varela dos Santos','joaovictorvarela321@gmail.com','Recife - PE','Estudante de Sistemas para Internet','Estudante da UNICAP com interesse em desenvolvimento web e aplicativos.','https://github.com/Jonqry'),
('Marina Oliveira Costa','marina.exemplo@exemplo.com','Recife - PE','Estudante de tecnologia (fictício)','Currículo fictício de teste.',NULL),
('Lucas Henrique Alves','lucas.exemplo@exemplo.com','Olinda - PE','Estudante de desenvolvimento (fictício)','Currículo fictício de teste.',NULL)
ON CONFLICT(email) DO NOTHING;

INSERT INTO formacoes(pessoa_id,curso,instituicao,tipo,descricao)
SELECT id,'Sistemas para Internet','Universidade Católica de Pernambuco (UNICAP)','Graduação','Em andamento' FROM pessoas WHERE email='joaovictorvarela321@gmail.com'
ON CONFLICT DO NOTHING;
INSERT INTO formacoes(pessoa_id,curso,instituicao,tipo)
SELECT id,'Multimídia','Escola Técnica Estadual Cícero Dias','Curso complementar' FROM pessoas WHERE email='joaovictorvarela321@gmail.com'
ON CONFLICT DO NOTHING;
INSERT INTO formacoes(pessoa_id,curso,instituicao,tipo)
SELECT id,'Office 365 e Power BI','Eduliv','Curso complementar' FROM pessoas WHERE email='joaovictorvarela321@gmail.com'
ON CONFLICT DO NOTHING;
INSERT INTO formacoes(pessoa_id,curso,instituicao,tipo)
SELECT id,'Análise e Desenvolvimento de Sistemas','Faculdade Exemplo','Graduação fictícia' FROM pessoas WHERE email='marina.exemplo@exemplo.com'
ON CONFLICT DO NOTHING;
INSERT INTO formacoes(pessoa_id,curso,instituicao,tipo)
SELECT id,'Sistemas de Informação','Instituto Modelo','Graduação fictícia' FROM pessoas WHERE email='lucas.exemplo@exemplo.com'
ON CONFLICT DO NOTHING;

INSERT INTO experiencias(pessoa_id,cargo,empresa,ano_inicio,ano_fim,descricao)
SELECT id,'Jovem Aprendiz','Ferreiro Café Ltda',2025,2025,'Fevereiro a outubro de 2025: atendimento ao público, organização e suporte operacional.'
FROM pessoas WHERE email='joaovictorvarela321@gmail.com' ON CONFLICT DO NOTHING;
INSERT INTO experiencias(pessoa_id,cargo,empresa,ano_inicio,descricao)
SELECT id,'Estagiária de suporte','Empresa Fictícia',2026,'Experiência fictícia de teste.'
FROM pessoas WHERE email='marina.exemplo@exemplo.com' ON CONFLICT DO NOTHING;
INSERT INTO experiencias(pessoa_id,cargo,empresa,ano_inicio,descricao)
SELECT id,'Monitor de informática','Projeto Modelo',2025,'Experiência fictícia de teste.'
FROM pessoas WHERE email='lucas.exemplo@exemplo.com' ON CONFLICT DO NOTHING;

INSERT INTO projetos(pessoa_id,titulo,descricao,ano) SELECT id,'EcoCiclo','Agendamento de coleta com Next.js, Spring Boot e PostgreSQL.',2026 FROM pessoas WHERE email='joaovictorvarela321@gmail.com' ON CONFLICT DO NOTHING;
INSERT INTO projetos(pessoa_id,titulo,descricao,ano) SELECT id,'Place Brokers','Plataforma imobiliária com mapa e filtros.',2026 FROM pessoas WHERE email='joaovictorvarela321@gmail.com' ON CONFLICT DO NOTHING;
INSERT INTO projetos(pessoa_id,titulo,descricao,ano) SELECT id,'Jogo de Dados','Jogo com Expo e React Native para dois jogadores.',2026 FROM pessoas WHERE email='joaovictorvarela321@gmail.com' ON CONFLICT DO NOTHING;
INSERT INTO projetos(pessoa_id,titulo,descricao,ano) SELECT id,'Lista de Tarefas','Projeto fictício.',2026 FROM pessoas WHERE email='marina.exemplo@exemplo.com' ON CONFLICT DO NOTHING;
INSERT INTO projetos(pessoa_id,titulo,descricao,ano) SELECT id,'Site Pessoal','Projeto fictício.',2026 FROM pessoas WHERE email='marina.exemplo@exemplo.com' ON CONFLICT DO NOTHING;
INSERT INTO projetos(pessoa_id,titulo,descricao,ano) SELECT id,'Controle de Estoque','Projeto fictício.',2026 FROM pessoas WHERE email='lucas.exemplo@exemplo.com' ON CONFLICT DO NOTHING;

INSERT INTO tecnologias(nome) VALUES ('JavaScript'),('React'),('React Native'),('Expo'),('Next.js'),('Java'),('Spring Boot'),('Node.js'),('Express'),('PostgreSQL'),('HTML'),('CSS'),('Git'),('Power BI') ON CONFLICT DO NOTHING;
INSERT INTO projeto_tecnologias(projeto_id,tecnologia_id)
SELECT p.id,t.id FROM projetos p JOIN pessoas pe ON pe.id=p.pessoa_id CROSS JOIN tecnologias t
WHERE
 (pe.email='joaovictorvarela321@gmail.com' AND p.titulo='EcoCiclo' AND t.nome IN ('Next.js','React','Spring Boot','Java','PostgreSQL'))
 OR (pe.email='joaovictorvarela321@gmail.com' AND p.titulo='Place Brokers' AND t.nome IN ('React','JavaScript','CSS'))
 OR (pe.email='joaovictorvarela321@gmail.com' AND p.titulo='Jogo de Dados' AND t.nome IN ('Expo','React Native','JavaScript'))
 OR (pe.email='marina.exemplo@exemplo.com' AND p.titulo='Lista de Tarefas' AND t.nome IN ('JavaScript','HTML','CSS'))
 OR (pe.email='marina.exemplo@exemplo.com' AND p.titulo='Site Pessoal' AND t.nome IN ('HTML','CSS'))
 OR (pe.email='lucas.exemplo@exemplo.com' AND p.titulo='Controle de Estoque' AND t.nome IN ('Node.js','Express','PostgreSQL'))
ON CONFLICT DO NOTHING;
