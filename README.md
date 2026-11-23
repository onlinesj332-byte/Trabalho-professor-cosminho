E-commerce de Moda — Refatoração de Banco de Dados
1. Sobre o projeto
Este projeto foi desenvolvido para o Exercício 6 – Sprint Ágil de Refatoração de Banco de Dados.

O objetivo é aplicar conceitos de Scrum, Kanban e DevOps para melhorar a estrutura de um banco de dados de um e-commerce de moda.
2. Problema identificado
A tabela Pedidos armazenava informações dos clientes repetidamente, como:

Nome completo

CPF

Endereço

Telefone

Essa repetição provocava redundância, lentidão nas consultas e risco de inconsistência cadastral.
3. Solução aplicada
Foi realizada a refatoração do banco de dados, criando uma tabela independente chamada Clientes.

A tabela Pedidos passou a utilizar o campo id_cliente como chave estrangeira para relacionar os pedidos aos seus respectivos clientes.
4. Tecnologias utilizadas
Python

SQLite

Google Colab

SQL

GitHub

Trello

Scrum

Kanban
5. Etapas do desenvolvimento
Identificação dos problemas do banco de dados.

Criação do Product Backlog.

Planejamento da Sprint.

Normalização das tabelas.

Criação e atualização dos scripts SQL (DDL e DML).

Criação de índices e relacionamentos.

Testes e validação das consultas.

Versionamento do projeto no GitHub.
6. Organização da equipe
Integrante A: Product Owner / Revisor.

Integrante B: Scrum Master / Desenvolvedor.

Ambos participaram do desenvolvimento e da revisão do projeto.
7. Entregáveis
Scripts SQL de criação e manipulação das tabelas.

Banco de dados refatorado.

Históricos de alterações e commits.

Quadro Kanban.

Relatório da Sprint.
8. Objetivo final
Entregar um banco de dados organizado, normalizado e funcional, reduzindo redundâncias e melhorando a integridade das informações dos clientes e pedidos.
 
