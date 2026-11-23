-- ==============================================================
-- EXERCICIO 6 - SPRINT AGIL DE REFATORACAO DE BANCO DE DADOS
-- TEMA: E-COMMERCE DE MODA
-- TECNOLOGIAS: SQLITE, SQL
-- ==============================================================

PRAGMA foreign_keys = ON;

-- ==============================================================
-- 1. CRIACAO DAS 7 TABELAS NORMALIZADAS (DDL)
-- ==============================================================

DROP TABLE IF EXISTS Kanban;
DROP TABLE IF EXISTS Tarefas;
DROP TABLE IF EXISTS UserStories;
DROP TABLE IF EXISTS Pedidos;
DROP TABLE IF EXISTS Sprints;
DROP TABLE IF EXISTS Integrantes;
DROP TABLE IF EXISTS Clientes;

-- TABELA 1: CLIENTES
CREATE TABLE Clientes (
    id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
    nome_completo TEXT NOT NULL,
    cpf TEXT NOT NULL UNIQUE,
    endereco TEXT NOT NULL,
    telefone TEXT NOT NULL
);

-- TABELA 2: PEDIDOS
CREATE TABLE Pedidos (
    id_pedido INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cliente INTEGER NOT NULL,
    data_pedido TEXT NOT NULL,
    valor_total REAL NOT NULL CHECK(valor_total >= 0),
    status TEXT NOT NULL,
    FOREIGN KEY (id_cliente)
        REFERENCES Clientes(id_cliente)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- TABELA 3: INTEGRANTES
CREATE TABLE Integrantes (
    id_integrante INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    funcao TEXT NOT NULL,
    responsabilidade TEXT NOT NULL
);

-- TABELA 4: SPRINTS
CREATE TABLE Sprints (
    id_sprint INTEGER PRIMARY KEY AUTOINCREMENT,
    nome TEXT NOT NULL,
    objetivo TEXT NOT NULL,
    duracao_dias INTEGER NOT NULL,
    data_inicio TEXT NOT NULL,
    data_fim TEXT NOT NULL,
    status TEXT NOT NULL
);

-- TABELA 5: USER STORIES
CREATE TABLE UserStories (
    id_story INTEGER PRIMARY KEY AUTOINCREMENT,
    id_sprint INTEGER NOT NULL,
    titulo TEXT NOT NULL,
    historia TEXT NOT NULL,
    criterios_aceitacao TEXT NOT NULL,
    prioridade TEXT NOT NULL,
    pontos_esforco INTEGER NOT NULL,
    FOREIGN KEY (id_sprint)
        REFERENCES Sprints(id_sprint)
);

-- TABELA 6: TAREFAS
CREATE TABLE Tarefas (
    id_tarefa INTEGER PRIMARY KEY AUTOINCREMENT,
    id_story INTEGER,
    id_integrante INTEGER NOT NULL,
    descricao TEXT NOT NULL,
    prioridade TEXT NOT NULL,
    tipo TEXT NOT NULL,
    estimativa_horas REAL NOT NULL,
    status TEXT NOT NULL,
    branch_git TEXT,
    pull_request TEXT,
    FOREIGN KEY (id_story)
        REFERENCES UserStories(id_story),
    FOREIGN KEY (id_integrante)
        REFERENCES Integrantes(id_integrante)
);

-- TABELA 7: KANBAN
CREATE TABLE Kanban (
    id_kanban INTEGER PRIMARY KEY AUTOINCREMENT,
    id_tarefa INTEGER NOT NULL UNIQUE,
    coluna TEXT NOT NULL,
    observacao TEXT,
    FOREIGN KEY (id_tarefa)
        REFERENCES Tarefas(id_tarefa)
);

-- ==============================================================
-- 2. INDICES PARA OTIMIZACAO
-- ==============================================================

CREATE INDEX idx_pedidos_cliente ON Pedidos(id_cliente);
CREATE INDEX idx_pedidos_data ON Pedidos(data_pedido);
CREATE INDEX idx_pedidos_status ON Pedidos(status);
CREATE INDEX idx_tarefas_story ON Tarefas(id_story);
CREATE INDEX idx_tarefas_integrante ON Tarefas(id_integrante);
CREATE INDEX idx_kanban_coluna ON Kanban(coluna);

-- ==============================================================
-- 3. REFATORACAO E MIGRACAO DE DADOS (DML)
-- ==============================================================

CREATE TEMP TABLE Pedidos_Antigos (
    nome_completo TEXT,
    cpf TEXT,
    endereco TEXT,
    telefone TEXT,
    data_pedido TEXT,
    valor_total REAL,
    status TEXT
);

INSERT INTO Pedidos_Antigos (nome_completo, cpf, endereco, telefone, data_pedido, valor_total, status) VALUES
    ('Ana Silva', '11111111111', 'Rua das Flores, 100', '11988881111', '2026-11-01', 159.90, 'Entregue'),
    ('Ana Silva', '11111111111', 'Rua das Flores, 100', '11988881111', '2026-11-05', 249.90, 'Entregue'),
    ('Bruno Santos', '22222222222', 'Av. Brasil, 250', '11988882222', '2026-11-06', 199.90, 'Em transporte'),
    ('Bruno Santos', '22222222222', 'Av. Brasil, 250', '11988882222', '2026-11-10', 89.90, 'Entregue'),
    ('Carla Oliveira', '33333333333', 'Rua Central, 300', '11988883333', '2026-11-11', 299.90, 'Processando'),
    ('Carla Oliveira', '33333333333', 'Rua Central, 300', '11988883333', '2026-11-12', 129.90, 'Entregue'),
    ('Daniel Costa', '44444444444', 'Rua das Palmeiras, 450', '11988884444', '2026-11-13', 179.90, 'Em transporte'),
    ('Daniel Costa', '44444444444', 'Rua das Palmeiras, 450', '11988884444', '2026-11-15', 349.90, 'Processando'),
    ('Eduarda Lima', '55555555555', 'Av. Paulista, 500', '11988885555', '2026-11-18', 219.90, 'Entregue'),
    ('Eduarda Lima', '55555555555', 'Av. Paulista, 500', '11988885555', '2026-11-20', 99.90, 'Processando');

-- Migracao dos clientes sem duplicidade
INSERT INTO Clientes (nome_completo, cpf, endereco, telefone)
SELECT DISTINCT
    nome_completo,
    cpf,
    endereco,
    telefone
FROM Pedidos_Antigos;

-- Migracao dos pedidos relacionando o cliente pelo CPF
INSERT INTO Pedidos (id_cliente, data_pedido, valor_total, status)
SELECT
    C.id_cliente,
    A.data_pedido,
    A.valor_total,
    A.status
FROM Pedidos_Antigos A
INNER JOIN Clientes C
    ON A.cpf = C.cpf;

DROP TABLE Pedidos_Antigos;

-- ==============================================================
-- 4. DADOS DA SPRINT, INTEGRANTES, USER STORIES, TAREFAS E KANBAN
-- ==============================================================

INSERT INTO Integrantes (nome, funcao, responsabilidade) VALUES
    ('Integrante A', 'Product Owner', 'Priorizar backlog, definir regras de negocio e aprovar historias.'),
    ('Integrante B', 'Scrum Master / Arquiteto de Dados', 'Organizar Kanban, planejar sprint e definir modelagem.'),
    ('Integrante C', 'Desenvolvedor / QA de Dados', 'Desenvolver SQL, migrar registros e testar integridade.');

INSERT INTO Sprints (nome, objetivo, duracao_dias, data_inicio, data_fim, status) VALUES
    ('Sprint 01 - Refatoracao da tabela Pedidos', 'Eliminar redundancias e melhorar o banco de dados.', 5, '2026-11-23', '2026-11-27', 'Planejada');

INSERT INTO UserStories (id_sprint, titulo, historia, criterios_aceitacao, prioridade, pontos_esforco) VALUES
    (1, 'US01 - Cadastro de clientes', 'Como administrador, quero cadastrar clientes separadamente para evitar repeticao de informacoes.', 'Cadastrar nome, CPF, endereco e telefone; gerar ID exclusivo; impedir CPF duplicado.', 'Alta', 3),
    (1, 'US02 - Relacionamento entre clientes e pedidos', 'Como administrador, quero relacionar pedidos aos clientes por uma chave estrangeira.', 'Utilizar id_cliente em Pedidos; impedir referencias inexistentes.', 'Alta', 5),
    (1, 'US03 - Historico de compras', 'Como cliente, quero consultar minhas compras anteriores.', 'Consultar pedidos por cliente; apresentar data, valor e status.', 'Alta', 3),
    (1, 'US04 - Atualizacao cadastral', 'Como cliente, quero atualizar endereco e telefone.', 'Atualizar um unico cadastro e preservar os relacionamentos.', 'Media', 3),
    (1, 'US05 - Migracao dos dados antigos', 'Como administrador, quero migrar os dados antigos preservando o historico.', 'Consolidar clientes, preservar pedidos e conferir registros.', 'Alta', 8),
    (1, 'US06 - Otimizacao das consultas', 'Como administrador, quero melhorar o desempenho das consultas.', 'Criar indices, utilizar JOIN e comparar consultas.', 'Media', 5),
    (1, 'US07 - Validacao e integridade', 'Como desenvolvedor, quero testar a integridade dos dados.', 'Verificar PK, FK, CPF duplicado e relacionamentos.', 'Media', 5);

INSERT INTO Tarefas (id_story, id_integrante, descricao, prioridade, tipo, estimativa_horas, status, branch_git, pull_request) VALUES
    (NULL, 2, 'T01 - Analisar estrutura atual da tabela Pedidos', 'Alta', 'Analise', 2, 'A Fazer', 'feature/analise-pedidos', 'Pendente de criacao no GitHub'),
    (NULL, 1, 'T02 - Identificar dados duplicados dos clientes', 'Alta', 'Analise', 2, 'A Fazer', 'feature/duplicidades', 'Pendente de criacao no GitHub'),
    (1, 2, 'T03 - Criar tabela Clientes', 'Alta', 'DDL', 2, 'A Fazer', 'feature/tabela-clientes', 'Pendente de criacao no GitHub'),
    (1, 2, 'T04 - Definir chave primaria id_cliente', 'Alta', 'DDL', 1, 'Em andamento', 'feature/chave-primaria', 'Pendente de criacao no GitHub'),
    (2, 2, 'T05 - Adicionar chave estrangeira em Pedidos', 'Alta', 'DDL', 2, 'Em andamento', 'feature/chave-estrangeira', 'Pendente de criacao no GitHub'),
    (5, 3, 'T06 - Desenvolver script de migracao', 'Alta', 'DML', 4, 'A Fazer', 'feature/migracao-dados', 'Pendente de criacao no GitHub'),
    (1, 3, 'T07 - Implementar validacao de CPF', 'Media', 'DML', 2, 'Em andamento', 'feature/validacao-cpf', 'Pendente de criacao no GitHub'),
    (6, 2, 'T08 - Criar indices para otimizacao', 'Media', 'DDL', 2, 'A Fazer', 'feature/indices', 'Pendente de criacao no GitHub'),
    (3, 3, 'T09 - Desenvolver consultas SQL com JOIN', 'Media', 'DML', 3, 'A Fazer', 'feature/consultas-join', 'Pendente de criacao no GitHub'),
    (7, 3, 'T10 - Testar integridade referencial', 'Alta', 'Teste', 3, 'Em revisao', 'feature/testes-integridade', 'Pendente de criacao no GitHub'),
    (6, 3, 'T11 - Comparar desempenho das consultas', 'Media', 'Teste', 2, 'Em revisao', 'feature/desempenho', 'Pendente de criacao no GitHub'),
    (7, 1, 'T12 - Revisar codigo e documentacao', 'Baixa', 'Revisao', 2, 'A Fazer', 'feature/documentacao', 'Pendente de criacao no GitHub');

INSERT INTO Kanban (id_tarefa, coluna, observacao) VALUES
    (1, 'A Fazer', 'Analise da estrutura antiga.'),
    (2, 'A Fazer', 'Identificacao de redundancias.'),
    (3, 'A Fazer', 'Criacao da tabela Clientes.'),
    (4, 'Em andamento', 'Definicao da chave primaria.'),
    (5, 'Em andamento', 'Relacionamento das tabelas.'),
    (6, 'A Fazer', 'Migracao de dados.'),
    (7, 'Em andamento', 'Validacao de CPF.'),
    (8, 'A Fazer', 'Criacao de indices.'),
    (9, 'A Fazer', 'Consultas JOIN.'),
    (10, 'Em revisao', 'Testes de integridade.'),
    (11, 'Em revisao', 'Comparacao de desempenho.'),
    (12, 'A Fazer', 'Documentacao e revisao.');

-- ==============================================================
-- 5. ATUALIZACAO CADASTRAL (DML)
-- ==============================================================

UPDATE Clientes
SET telefone = '11999990000'
WHERE id_cliente = 1;

-- ==============================================================
-- 6. CONSULTAS DE RELATORIO, AUDITORIA E DESEMPENHO (DQL)
-- ==============================================================

-- Historico de compras por cliente
SELECT
    C.nome_completo,
    C.cpf,
    P.id_pedido,
    P.data_pedido,
    P.valor_total,
    P.status
FROM Clientes C
INNER JOIN Pedidos P
    ON C.id_cliente = P.id_cliente
ORDER BY P.id_pedido;

-- Total gasto por cliente
SELECT
    C.nome_completo,
    COUNT(P.id_pedido) AS total_pedidos,
    ROUND(SUM(P.valor_total), 2) AS total_gasto
FROM Clientes C
LEFT JOIN Pedidos P
    ON C.id_cliente = P.id_cliente
GROUP BY C.id_cliente, C.nome_completo
ORDER BY total_gasto DESC;

-- Planejamento da Sprint e estimativa de horas
SELECT
    I.nome AS integrante,
    I.funcao,
    COUNT(T.id_tarefa) AS quantidade_tarefas,
    SUM(T.estimativa_horas) AS horas_estimadas
FROM Integrantes I
LEFT JOIN Tarefas T
    ON I.id_integrante = T.id_integrante
GROUP BY I.id_integrante, I.nome, I.funcao
ORDER BY I.id_integrante;

-- Prioridades do backlog
SELECT
    prioridade,
    COUNT(*) AS quantidade,
    SUM(estimativa_horas) AS horas
FROM Tarefas
GROUP BY prioridade
ORDER BY
    CASE prioridade
        WHEN 'Alta' THEN 1
        WHEN 'Media' THEN 2
        WHEN 'Baixa' THEN 3
    END;

-- Quadro Kanban completo
SELECT
    K.id_kanban,
    T.descricao,
    K.coluna,
    K.observacao
FROM Kanban K
JOIN Tarefas T
    ON K.id_tarefa = T.id_tarefa
ORDER BY K.id_kanban;

-- Resumo do Kanban
SELECT
    coluna,
    COUNT(*) AS quantidade_tarefas
FROM Kanban
GROUP BY coluna
ORDER BY coluna;

-- Verificacoes de integridade e indices
PRAGMA foreign_key_check;

SELECT cpf
FROM Clientes
GROUP BY cpf
HAVING COUNT(*) > 1;

SELECT COUNT(*) AS pedidos_sem_cliente
FROM Pedidos P
LEFT JOIN Clientes C
    ON P.id_cliente = C.id_cliente
WHERE C.id_cliente IS NULL;

SELECT name, tbl_name
FROM sqlite_master
WHERE type = 'index'
  AND name NOT LIKE 'sqlite_%'
ORDER BY tbl_name;

EXPLAIN QUERY PLAN
SELECT *
FROM Pedidos
WHERE id_cliente = 1;
