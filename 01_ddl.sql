-- =============================================================
-- 01_ddl.sql
-- Banco de dados: Sistema de Acompanhamento Menstrual
-- SGBD: MySQL 8.0+
-- =============================================================

DROP DATABASE IF EXISTS acompanhamento_menstrual;
CREATE DATABASE acompanhamento_menstrual
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE acompanhamento_menstrual;

-- =============================================================
-- RN01: Todo usuário possui identificador, nome, e-mail e data de cadastro.
-- RN02: O e-mail de cada usuário deve ser único.
-- =============================================================
CREATE TABLE usuario (
    id_usuario INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(254) NOT NULL,
    data_cadastro DATE NOT NULL,

    CONSTRAINT pk_usuario PRIMARY KEY (id_usuario),
    CONSTRAINT uq_usuario_email UNIQUE (email)
) ENGINE=InnoDB;

-- Índice para consultas por nome.
CREATE INDEX idx_usuario_nome ON usuario (nome);

-- =============================================================
-- RN03/RN04: Um usuário pode possuir vários ciclos e cada ciclo
-- pertence a um único usuário.
-- RN05: Todo ciclo deve possuir data de início.
-- RN06: Data de término não pode ser anterior à data de início.
-- RN07: Data de término pode ficar NULL enquanto o ciclo estiver em andamento.
-- RN08: Duração deve ser um inteiro positivo.
-- RN16: Um usuário não pode possuir dois ciclos com a mesma data de início.
-- =============================================================
CREATE TABLE ciclo_menstrual (
    id_ciclo INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario INT UNSIGNED NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NULL,
    duracao SMALLINT UNSIGNED NOT NULL,

    CONSTRAINT pk_ciclo_menstrual PRIMARY KEY (id_ciclo),
    CONSTRAINT uq_ciclo_usuario_data_inicio UNIQUE (id_usuario, data_inicio),
    CONSTRAINT ck_ciclo_duracao CHECK (duracao > 0),
    CONSTRAINT ck_ciclo_datas CHECK (data_fim IS NULL OR data_fim >= data_inicio),
    CONSTRAINT fk_ciclo_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_ciclo_data_inicio ON ciclo_menstrual (data_inicio);
CREATE INDEX idx_ciclo_usuario ON ciclo_menstrual (id_usuario);

-- =============================================================
-- RN09: Sintoma possui identificador, nome e categoria.
-- =============================================================
CREATE TABLE sintoma (
    id_sintoma INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    categoria VARCHAR(60) NOT NULL,

    CONSTRAINT pk_sintoma PRIMARY KEY (id_sintoma)
) ENGINE=InnoDB;

CREATE INDEX idx_sintoma_nome ON sintoma (nome);
CREATE INDEX idx_sintoma_categoria ON sintoma (categoria);

-- =============================================================
-- RN10/RN11: Um usuário pode registrar vários sintomas e o mesmo
-- sintoma pode aparecer em diferentes ciclos.
-- RN12: O registro informa intensidade e data de observação.
-- RN13: Intensidade utiliza escala definida pelo sistema (1 a 5).
-- RN17: Todo registro de sintoma deve estar vinculado a um ciclo existente.
-- =============================================================
CREATE TABLE registro_sintoma (
    id_registro_sintoma INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_ciclo INT UNSIGNED NOT NULL,
    id_sintoma INT UNSIGNED NOT NULL,
    intensidade TINYINT UNSIGNED NOT NULL,
    data_observacao DATE NOT NULL,

    CONSTRAINT pk_registro_sintoma PRIMARY KEY (id_registro_sintoma),
    CONSTRAINT ck_registro_sintoma_intensidade CHECK (intensidade BETWEEN 1 AND 5),
    CONSTRAINT fk_registro_sintoma_ciclo
        FOREIGN KEY (id_ciclo)
        REFERENCES ciclo_menstrual (id_ciclo)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_registro_sintoma_sintoma
        FOREIGN KEY (id_sintoma)
        REFERENCES sintoma (id_sintoma)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_registro_sintoma_ciclo ON registro_sintoma (id_ciclo);
CREATE INDEX idx_registro_sintoma_sintoma ON registro_sintoma (id_sintoma);
CREATE INDEX idx_registro_sintoma_data ON registro_sintoma (data_observacao);

-- =============================================================
-- RN14/RN15: Usuário pode registrar diferentes estados de humor;
-- cada registro possui usuário e data de ocorrência.
-- =============================================================
CREATE TABLE humor (
    id_humor INT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_usuario INT UNSIGNED NOT NULL,
    estado_humor VARCHAR(60) NOT NULL,
    data_ocorrencia DATE NOT NULL,

    CONSTRAINT pk_humor PRIMARY KEY (id_humor),
    CONSTRAINT fk_humor_usuario
        FOREIGN KEY (id_usuario)
        REFERENCES usuario (id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_humor_usuario ON humor (id_usuario);
CREATE INDEX idx_humor_data ON humor (data_ocorrencia);

-- =============================================================
-- RN18: O sistema mantém o histórico dos ciclos registrados.
-- As tabelas permanecem persistentes e os relacionamentos preservam
-- a integridade referencial do histórico.
-- =============================================================
