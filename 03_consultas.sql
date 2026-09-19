
-- =============================================================
-- 03_consultas.sql
-- 15 consultas de verificação e análise do domínio.
-- Cada consulta é precedida pela pergunta de negócio
-- que ela responde.
-- =============================================================

USE acompanhamento_menstrual;

-- =============================================================
-- BÁSICAS 
-- =============================================================

-- 01. Quais usuários estão cadastrados no sistema?
SELECT id_usuario, nome, email, data_cadastro
FROM usuario
ORDER BY nome;


-- 02. Quais ciclos possuem duração entre 28 e 30 dias?
-- Utiliza BETWEEN para definir um intervalo de valores.
SELECT id_ciclo, id_usuario, data_inicio, data_fim, duracao
FROM ciclo_menstrual
WHERE duracao BETWEEN 28 AND 30
ORDER BY duracao, data_inicio;


-- 03. Quais sintomas pertencem às categorias Dor ou Físico?
-- Utiliza IN para consultar mais de uma possibilidade.
SELECT id_sintoma, nome, categoria
FROM sintoma
WHERE categoria IN ('Dor', 'Físico')
ORDER BY categoria, nome;


-- 04. Quais usuários possuem nome que contém 'ana'?
-- Utiliza LIKE para localizar nomes que possuem determinado texto.
SELECT id_usuario, nome, email
FROM usuario
WHERE nome LIKE '%ana%'
ORDER BY nome;


-- 05. Quais ciclos ainda estão em andamento, ou seja,
-- possuem a data de término em branco?
-- IS NULL é utilizado para localizar valores não preenchidos.
SELECT id_ciclo, id_usuario, data_inicio, data_fim, duracao
FROM ciclo_menstrual
WHERE data_fim IS NULL
ORDER BY data_inicio;


-- =============================================================
-- JUNÇÕES E AGREGAÇÃO (5)
-- =============================================================

-- 06. Quais sintomas foram registrados em cada ciclo
-- e para qual usuário?
-- A consulta utiliza três ou mais tabelas relacionadas.
SELECT u.nome AS usuario,
       c.id_ciclo,
       s.nome AS sintoma,
       rs.intensidade,
       rs.data_observacao
FROM usuario u
JOIN ciclo_menstrual c
    ON c.id_usuario = u.id_usuario
JOIN registro_sintoma rs
    ON rs.id_ciclo = c.id_ciclo
JOIN sintoma s
    ON s.id_sintoma = rs.id_sintoma
ORDER BY u.nome, c.data_inicio, rs.data_observacao;


-- 07. Quais usuários possuem ou não registros de humor?
-- LEFT JOIN mantém na consulta os usuários que não possuem
-- registros correspondentes na tabela de humor.
SELECT u.id_usuario,
       u.nome,
       h.estado_humor,
       h.data_ocorrencia
FROM usuario u
LEFT JOIN humor h
    ON h.id_usuario = u.id_usuario
ORDER BY u.nome, h.data_ocorrencia;


-- 08. Quantos ciclos cada usuário possui?
-- GROUP BY agrupa os registros por usuário e COUNT contabiliza
-- a quantidade de ciclos de cada um.
SELECT u.id_usuario,
       u.nome,
       COUNT(c.id_ciclo) AS quantidade_ciclos
FROM usuario u
LEFT JOIN ciclo_menstrual c
    ON c.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY quantidade_ciclos DESC, u.nome;


-- 09. Quais usuários possuem pelo menos dois ciclos registrados?
-- HAVING filtra os grupos depois que a quantidade de ciclos
-- foi calculada pelo COUNT.
SELECT u.id_usuario,
       u.nome,
       COUNT(c.id_ciclo) AS quantidade_ciclos
FROM usuario u
JOIN ciclo_menstrual c
    ON c.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
HAVING COUNT(c.id_ciclo) >= 2
ORDER BY quantidade_ciclos DESC;


-- 10. Qual é a duração média dos ciclos de cada usuário?
-- AVG calcula a média da duração dos ciclos.
SELECT u.id_usuario,
       u.nome,
       ROUND(AVG(c.duracao), 2) AS duracao_media
FROM usuario u
JOIN ciclo_menstrual c
    ON c.id_usuario = u.id_usuario
GROUP BY u.id_usuario, u.nome
ORDER BY u.nome;


-- =============================================================
-- AVANÇADAS (5)
-- =============================================================

-- 11. Quais ciclos possuem duração acima da média dos ciclos
-- do próprio usuário?
-- Utiliza uma subconsulta correlacionada, pois a subconsulta
-- depende do id_usuario do registro da consulta principal.
SELECT c.id_ciclo,
       c.id_usuario,
       c.data_inicio,
       c.duracao
FROM ciclo_menstrual c
WHERE c.duracao > (
    SELECT AVG(c2.duracao)
    FROM ciclo_menstrual c2
    WHERE c2.id_usuario = c.id_usuario
)
ORDER BY c.id_usuario, c.duracao DESC;


-- 12. Quais usuários possuem pelo menos um sintoma registrado?
-- EXISTS verifica se existe pelo menos um registro relacionado
-- ao usuário consultado.
SELECT u.id_usuario,
       u.nome
FROM usuario u
WHERE EXISTS (
    SELECT 1
    FROM ciclo_menstrual c
    JOIN registro_sintoma rs
        ON rs.id_ciclo = c.id_ciclo
    WHERE c.id_usuario = u.id_usuario
)
ORDER BY u.nome;


-- 13. Quais sintomas foram registrados pelo menos duas vezes?
-- Essa consulta identifica sintomas que possuem maior recorrência
-- no histórico registrado.
SELECT s.id_sintoma,
       s.nome,
       COUNT(rs.id_registro_sintoma) AS quantidade_registros
FROM sintoma s
JOIN registro_sintoma rs
    ON rs.id_sintoma = s.id_sintoma
GROUP BY s.id_sintoma, s.nome
HAVING COUNT(rs.id_registro_sintoma) >= 2
ORDER BY quantidade_registros DESC, s.nome;


-- 14. Qual foi a maior intensidade registrada para cada sintoma?
-- MAX identifica a maior intensidade registrada para cada sintoma.
SELECT s.nome AS sintoma,
       MAX(rs.intensidade) AS maior_intensidade
FROM sintoma s
JOIN registro_sintoma rs
    ON rs.id_sintoma = s.id_sintoma
GROUP BY s.id_sintoma, s.nome
ORDER BY maior_intensidade DESC, s.nome;


-- 15. Qual sintoma foi mais frequente no histórico de cada usuário?
-- Essa é uma pergunta de negócio não trivial, pois é necessário
-- comparar a frequência de cada sintoma dentro do histórico
-- individual de cada usuário.
SELECT usuario,
       sintoma,
       quantidade_registros
FROM (
    SELECT u.id_usuario,
           u.nome AS usuario,
           s.id_sintoma,
           s.nome AS sintoma,
           COUNT(rs.id_registro_sintoma) AS quantidade_registros,
           RANK() OVER (
               PARTITION BY u.id_usuario
               ORDER BY COUNT(rs.id_registro_sintoma) DESC
           ) AS posicao
    FROM usuario u
    JOIN ciclo_menstrual c
        ON c.id_usuario = u.id_usuario
    JOIN registro_sintoma rs
        ON rs.id_ciclo = c.id_ciclo
    JOIN sintoma s
        ON s.id_sintoma = rs.id_sintoma
    GROUP BY u.id_usuario,
             u.nome,
             s.id_sintoma,
             s.nome
) AS frequencias
WHERE posicao = 1
ORDER BY usuario, sintoma;
