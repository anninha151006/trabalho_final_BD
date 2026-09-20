
-- =============================================================
-- 02_carga.sql
-- Dados fictícios, plausíveis e destinados a testes.
-- =============================================================

USE acompanhamento_menstrual;

-- Os dados utilizados neste arquivo são fictícios e foram criados
-- exclusivamente para representar situações possíveis no sistema.
-- A ordem dos INSERTs respeita a dependência entre as tabelas,
-- evitando inserir registros que dependam de dados ainda inexistentes.

-- Usuários fictícios.
-- Os nomes e e-mails não pertencem a pessoas reais.
INSERT INTO usuario (nome, email, data_cadastro) VALUES
('Ana Oliveira', 'ana.oliveira@example.com', '2026-01-10'),
('Mariana Costa', 'mariana.costa@example.com', '2026-02-05'),
('Camila Souza', 'camila.souza@example.com', '2026-02-20'),
('Juliana Santos', 'juliana.santos@example.com', '2026-03-12'),
('Beatriz Lima', 'beatriz.lima@example.com', '2026-04-01');

-- Sintomas cadastrados no sistema.
-- Foram utilizados diferentes tipos e categorias para representar
-- situações variadas que podem ser registradas durante um ciclo.
INSERT INTO sintoma (nome, categoria) VALUES
('Cólica', 'Dor'),
('Dor de cabeça', 'Dor'),
('Náusea', 'Gastrointestinal'),
('Cansaço', 'Físico'),
('Inchaço', 'Físico'),
('Sensibilidade nos seios', 'Físico'),
('Dor lombar', 'Dor');

-- Ciclos menstruais.
-- Foram cadastrados vários ciclos para alguns usuários, representando
-- um histórico de acompanhamento ao longo do tempo.
--
-- Caso de contorno:
-- O ciclo da Camila ainda está em andamento, por isso a data_fim
-- permanece NULL. A duração representa a situação registrada até o momento.
INSERT INTO ciclo_menstrual (id_usuario, data_inicio, data_fim, duracao) VALUES
(1, '2026-01-03', '2026-01-30', 28),
(1, '2026-01-31', '2026-02-28', 29),
(1, '2026-03-01', '2026-03-29', 29),
(2, '2026-02-02', '2026-03-02', 29),
(2, '2026-03-03', '2026-03-31', 29),
(2, '2026-04-01', '2026-04-29', 29),
(3, '2026-08-20', NULL, 30),
(4, '2026-04-10', '2026-05-07', 28),
(4, '2026-05-08', '2026-06-04', 28),
(5, '2026-05-15', '2026-06-13', 30);

-- Registros de sintomas.
-- Um mesmo sintoma pode aparecer em ciclos diferentes e um mesmo ciclo
-- pode possuir vários sintomas registrados em datas diferentes.
-- Isso representa o histórico de eventos do acompanhamento.
INSERT INTO registro_sintoma (id_ciclo, id_sintoma, intensidade, data_observacao) VALUES
(1, 1, 4, '2026-01-04'),
(1, 2, 2, '2026-01-05'),
(1, 4, 3, '2026-01-08'),
(2, 1, 3, '2026-02-01'),
(2, 5, 2, '2026-02-03'),
(3, 1, 5, '2026-03-02'),
(3, 7, 3, '2026-03-04'),
(4, 2, 3, '2026-02-03'),
(4, 4, 2, '2026-02-05'),
(5, 1, 4, '2026-03-04'),
(5, 3, 2, '2026-03-05'),
(6, 5, 3, '2026-04-03'),
(7, 1, 4, '2026-08-21'),
(7, 6, 2, '2026-08-22'),
(8, 7, 2, '2026-04-11'),
(9, 1, 3, '2026-05-09'),
(10, 4, 3, '2026-05-16');

-- Histórico de humor.
-- Foram registrados vários eventos para alguns usuários, permitindo
-- representar mudanças de humor ao longo do tempo.
INSERT INTO humor (id_usuario, estado_humor, data_ocorrencia) VALUES
(1, 'Estável', '2026-01-10'),
(1, 'Irritada', '2026-01-16'),
(1, 'Disposta', '2026-02-10'),
(2, 'Ansiosa', '2026-02-08'),
(2, 'Feliz', '2026-02-20'),
(2, 'Cansada', '2026-03-10'),
(3, 'Tranquila', '2026-08-25'),
(4, 'Feliz', '2026-04-18'),
(4, 'Irritada', '2026-05-12'),
(5, 'Estável', '2026-05-20');

-- Os registros acima também servem para testar casos de histórico,
-- com mais de um evento relacionado à mesma entidade.
-- Não foram utilizados dados pessoais reais de terceiros.

