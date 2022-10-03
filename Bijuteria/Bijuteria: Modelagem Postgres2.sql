CREATE SCHEMA bijuteria;
SET search_path TO bijuteria;

CREATE TABLE curso (
	idcurso 		SERIAL,
	nomecurso 		VARCHAR(60),
	totalhoras 		INT,
	valordocurso 	DECIMAL(10,2),
	PRIMARY KEY (idcurso)
);

CREATE TABLE turmas (
	idcurso 		SERIAL,
	idturmas 		INT,
	horarioinicio 	TIME,
	horariofim 		TIME,
	totalaluno 		INT,
	PRIMARY KEY (idturmas),
	FOREIGN KEY (idcurso)  REFERENCES curso (idcurso)
);

CREATE TABLE materia (
    idmateria           SERIAL,
    nome                VARCHAR(100),
    carga_horaria       INT,
    PRIMARY KEY (idmateria)
);

CREATE TABLE curso_tem_materia (
    curso_idcurso           INT,
    materia_idmateria       INT,
    FOREIGN KEY (curso_idcurso)         REFERENCES curso (idcurso),
    FOREIGN KEY (materia_idmateria)     REFERENCES materia (idmateria)
);

CREATE TABLE participante (
    idparticipante      SERIAL,
    cpf                 VARCHAR(16),
    nome                VARCHAR(60),
    data_nascimento		DATE,
    cidade              VARCHAR(60),
    meio_locomocao      VARCHAR(60),
    PRIMARY KEY (idparticipante)
);

CREATE TABLE matricula (
    idmatricula                     SERIAL,
    participante_idparticipante     INT,
    turma_idturma                   INT,
    parcelas                        INT,
    situacao						VARCHAR(1),
    PRIMARY KEY (idmatricula, participante_idparticipante, turma_idturma),
    FOREIGN KEY (participante_idparticipante)   REFERENCES participante (idparticipante),
    FOREIGN KEY (turma_idturma)                 REFERENCES turma (idturma)
);

CREATE TABLE caixa (
    data_caixa  DATE,
    abertura    DECIMAL(10,2),
    entradas    DECIMAL(10,2),
    saida       DECIMAL(10,2),
    PRIMARY KEY (data_caixa)
);

CREATE TABLE pagamentos (
    matricula_idmatricula   INT,
    parcela                 INT,
    data_vencimento         DATE,
    caixa_data_pagamento    DATE,
    valor                   DECIMAL(10,2),
    FOREIGN KEY (matricula_idmatricula)     REFERENCES matricula (idmatricula),
    FOREIGN KEY (caixa_data_pagamento)      REFERENCES caixa (data_caixa)
);

CREATE TABLE gastos (
    idgastos                SERIAL,
    turma_idturma           INT,
    decricao                VARCHAR(100),
    valor                   DECIMAL(10,2),
    caixa_data_ocorrencia   DATE NULL,
    PRIMARY KEY (idgastos),
    FOREIGN KEY (turma_idturma)           REFERENCES turma (idturma),
    FOREIGN KEY (caixa_data_ocorrencia)   REFERENCES caixa (data_caixa)
);






