CREATE SCHEMA bijuteria;
SET search_path TO bijuteria;

CREATE TABLE curso (
    idcurso     SERIAL,
    nome        VARCHAR(60) NULL,
    descricao   VARCHAR(255) NULL,
    PRIMARY KEY (idcurso)
);

CREATE TABLE turma (
    idturma         SERIAL,
    curso_idcurso   INT NOT NULL,
    ano             INT NOT NULL,
    semestre        INT NOT NULL,
    PRIMARY KEY (idturma),
    FOREIGN KEY (curso_idcurso) REFERENCES curso (idcurso)
);

CREATE TABLE materia (
    idmateria           SERIAL,
    nome                VARCHAR(100),
    carga_horaria       INT,
    PRIMARY KEY (idmateria)
);

CREATE TABLE participante (
    idparticipante      SERIAL,
    cpf                 VARCHAR(16),
    nome                VARCHAR(60),
    cidade              VARCHAR(60),
    meio_locomocao      VARCHAR(60),
    PRIMARY KEY (idparticipante)
);

CREATE TABLE matricula (
    idmatricula                     SERIAL,
    participante_idparticipante     INT NOT NULL,
    turma_idturma                   INT NOT NULL,
    parcelas                        INT,
    PRIMARY KEY (idmatricula, participante_idparticipante, turma_idturma),
    FOREIGN KEY (participante_idparticipante)   REFERENCES participante (idparticipante),
    FOREIGN KEY (turma_idturma)                 REFERENCES turma (idturma)
);

CREATE TABLE caixa (
    data_caixa  DATE NOT NULL,
    abertura    DECIMAL(10,2) NULL,
    entradas    DECIMAL(10,2) NULL,
    saida       DECIMAL(10,2) NULL,
    PRIMARY KEY (data_caixa)
);

CREATE TABLE pagamentos (
    matricula_idmatricula   INT NOT NULL,
    parcela                 INT NOT NULL,
    data_vencimento         DATE,
    caixa_data_pagamento    DATE,
    valor                   DECIMAL(10,2),
    FOREIGN KEY (matricula_idmatricula)     REFERENCES matricula (idmatricula),
    FOREIGN KEY (caixa_data_pagamento)      REFERENCES caixa (data_caixa)
);

CREATE TABLE curso_tem_materia (
    curso_idcurso           INT NOT NULL,
    materia_idmateria       INT NOT NULL,
    FOREIGN KEY (curso_idcurso)         REFERENCES curso (idcurso),
    FOREIGN KEY (materia_idmateria)     REFERENCES materia (idmateria)
);

CREATE TABLE gastos (
    idgastos                SERIAL,
    turma_idturma           INT NOT NULL,
    decricao                VARCHAR(100),
    valor                   DECIMAL(10,2),
    caixa_data_ocorrencia   DATE NULL,
    PRIMARY KEY (idgastos),
    FOREIGN KEY (turma_idturma)           REFERENCES turma (idturma),
    FOREIGN KEY (caixa_data_ocorrencia)   REFERENCES caixa (data_caixa)
);

CREATE TABLE participante_faz_materia (
    participante_idparticipante     INT NOT NULL,
    materia_idmateria               INT NOT NULL,
    nota1                           DECIMAL(4,2),
    nota2                           DECIMAL(4,2),
    nota3                           DECIMAL(4,2),
    nota4                           DECIMAL(4,2),
    situacao                        VARCHAR(1),
    PRIMARY KEY (participante_idparticipante, materia_idmateria),
    FOREIGN KEY (participante_idparticipante)   REFERENCES participante (idparticipante),
    FOREIGN KEY (materia_idmateria)             REFERENCES materia (idmateria)
);
