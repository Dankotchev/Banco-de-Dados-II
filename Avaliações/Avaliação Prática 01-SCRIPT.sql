CREATE SCHEMA correcaoprovabim1;
SET search_path TO correcaoprovabim1;

CREATE TABLE curso (
	idcurso 		SERIAL,
	nome_curso 		VARCHAR(60),
	total_horas 	INT,
	valor_curso 	DECIMAL(10,2),
	PRIMARY KEY (idcurso)
);

CREATE TABLE turma (
	idturma 		   SERIAL,
	curso_idcurso      INT,
	horario_inicio 	   TIME,
	horario_fim        TIME,
	total_aluno        INT,
	PRIMARY KEY (idturma),
	FOREIGN KEY (curso_idcurso)  REFERENCES curso (idcurso)
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
    PRIMARY KEY (curso_idcurso, materia_idmateria),
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
    situacao						VARCHAR(1) DEFAULT 'P',
    PRIMARY KEY (idmatricula),
    FOREIGN KEY (participante_idparticipante)   REFERENCES participante (idparticipante),
    FOREIGN KEY (turma_idturma)                 REFERENCES turma (idturma)
);

CREATE TABLE caixa (
    data_caixa  DATE,
    abertura    DECIMAL(10,2) DEFAULT 0,
    entrada     DECIMAL(10,2) DEFAULT 0,
    saida       DECIMAL(10,2) DEFAULT 0,
    saldo       DECIMAL(10,2) DEFAULT 0,
    PRIMARY KEY (data_caixa)
);

CREATE TABLE pagamentos (
	idpagamentos			SERIAL,
    matricula_idmatricula   INT,
    parcela                 INT,
    data_vencimento         DATE,
    caixa_data_pagamento    DATE,
    valor                   DECIMAL(10,2),
    PRIMARY KEY (idpagamentos),
    FOREIGN KEY (matricula_idmatricula)     REFERENCES matricula (idmatricula),
    FOREIGN KEY (caixa_data_pagamento)      REFERENCES caixa (data_caixa)
);

CREATE TABLE gastos (
    idgastos                SERIAL,
    turma_idturma           INT,
    descricao               VARCHAR(100),
    valor                   DECIMAL(10,2),
    caixa_data_gasto        DATE,
    PRIMARY KEY (idgastos),
    FOREIGN KEY (turma_idturma)           REFERENCES turma (idturma),
    FOREIGN KEY (caixa_data_gasto)   REFERENCES caixa (data_caixa)
);

CREATE TABLE notas (
    idnota                          SERIAL,
    matricula_idmatricula           INT,
    materia_idmateria               INT,
    nota1                           DECIMAL(4,2) DEFAULT 0,
    nota2                           DECIMAL(4,2) DEFAULT 0,
    nota3                           DECIMAL(4,2) DEFAULT 0,
    nota4                           DECIMAL(4,2) DEFAULT 0,
    PRIMARY KEY (idnota, materia_idmateria),
    FOREIGN KEY (materia_idmateria) REFERENCES matricula (idmatricula),
    FOREIGN KEY (materia_idmateria) REFERENCES materia (idmateria)
);

-- 1	 Crie uma VIEW que mostre as turmas, quanto já foi recebido até o momento em
-- cada turma e quanto foi gasto em despesas. Na VIEW deve aparecer
-- IDTURMA,NOMECURSO,TOTALDESPESA E TOTALRECEITA.

CREATE OR REPLACE VIEW view_turmas
AS
	SELECT idturma, nome_curso, SUM(g.valor) as total_despesas, SUM(p.valor) as total_receitas
		FROM turma JOIN curso ON (curso_idcurso = idcurso)
					JOIN gastos g ON (g.turma_idturma = idturma)
					JOIN matricula m ON (m.turma_idturma = idturma)
					JOIN pagamentos p ON (matricula_idmatricula = idmatricula)
					WHERE caixa_data_pagamento IS NOT NULL
					GROUP BY idturma, curso.nome_curso
;

-- 2 Faça uma VIEW que mostre o NOMEALUNO, NOMECURSO, MATRICULA e se o
-- ALUNO ESTA APROVADO OU REPROVADO
CREATE OR REPLACE FUNCTION f_situacao_aluno(MAT INT) RETURNS VARCHAR
LANGUAGE 'plpgsql'
AS $$
DECLARE REGISTRO RECORD;
      MEDIA FLOAT;
	  SITUACAO VARCHAR(12);
	  MATRICULA INT;
begin
      SITUACAO='APROVADO';
	  SELECT MATRICULA_IDMATRICULA FROM NOTAS WHERE MATRICULA_IDMATRICULA=MAT LIMIT 1 INTO MATRICULA;
	 
		  FOR REGISTRO IN SELECT * FROM NOTAS WHERE MATRICULA_IDMATRICULA=MAT LOOP
			   MEDIA = (REGISTRO.NOTA1+REGISTRO.NOTA2+REGISTRO.NOTA3+REGISTRO.NOTA4)/4;
			   IF MEDIA < 6.0 THEN
				  SITUACAO = 'REPROVADO';
			   END IF;	  
		  END LOOP;
	 
	  IF MATRICULA IS NULL THEN
	     SITUACAO='REPROVADO';
	  END IF;	 
	  RETURN SITUACAO;
end $$;


	-- View
CREATE OR REPLACE VIEW view_aluno_aprovacao
AS
	SELECT nome, nome_curso, idmatricula, f_situacao_aluno(idparticipante)
		FROM participante
			JOIN matricula m ON (idparticipante = participante_idparticipante)
			JOIN turma ON (turma_idturma = idturma)
			JOIN curso ON (curso_idcurso = idcurso)
;

-- 3 Crie uma TRIGGER que ao excluir uma MATRICULA todos os lançamento em
-- NOTAS dessa matricula e os LANCAMENTOS em PAGAMENTOS que estejam pendentes
-- devem ser removidos.
CREATE OR REPLACE FUNCTION f_excluir_matricula() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
DECLARE
BEGIN
	IF (TG_OP = 'DELETE') THEN
		DELETE FROM notas WHERE matricula_idmatricula = OLD.idmatricula;
		DELETE FROM pagamentos WHERE matricula_idmatricula = OLD.idmatricula AND caixa_data_pagamento IS NULL;
		RETURN OLD;
	END IF;		
END $$;

CREATE TRIGGER t_excluir_matricula BEFORE DELETE ON matricula
FOR EACH ROW EXECUTE PROCEDURE f_excluir_matricula();


-- 4	Toda MATRICULA ao ser inserida é considerada (P) Pendente ao mudar a situação
--para (A) Ativa deve ser criado em NOTAS todos os lançamentos para cada DISCIPLINA
--do CURSO que o aluno foi matriculado, em PAGAMENTO as PARCELAS referente a
--MATRICULA ativada. A primeira parcela deve ser BAIXADA “PAGA” . Caso o caixa com a
-- DATA DA BAIXA “CURRENT_DATE”, não exista ele deve ser criado e o valor da parcela
-- armazenado no atributo ENTRADA e o SALDO atualizado.
CREATE OR REPLACE FUNCTION f_inserir_notas_pagamentos_matricula() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
DECLARE
	nova_matricula_cursor	 	RECORD;
	valor_curso_busca	NUMERIC(10,2);
	data 				DATE;
	valor_parcela		NUMERIC(10,2);
	i 					INT DEFAULT 0;
	data_pagamento		DATE;
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		IF (NEW.situacao = 'A' AND OLD.situacao = 'P') THEN
			-- Inserindo as notas para cada materia
			FOR nova_matricula_cursor IN SELECT idmateria FROM turma t
									JOIN curso ON (t.curso_idcurso = idcurso)
									JOIN curso_tem_materia cm ON (idcurso = cm.curso_idcurso)
									JOIN materia ON (materia_idmateria = idmateria)
									WHERE idturma = NEW.turma_idturma
									LOOP
								
					INSERT INTO notas (matricula_idmatricula, materia_idmateria) VALUES (NEW.idmatricula, nova_matricula_cursor.idmateria);
			END LOOP;
			
			-- Inserindo pagamentos
			data = current_date;
			SELECT valor_curso FROM curso JOIN turma ON (idcurso = curso_idcurso)
				WHERE idturma = NEW.turma_idturma INTO valor_curso_busca;

			valor_parcela = round((valor_curso_busca / NEW.parcelas), 2);

			FOR i in 1..NEW.parcelas LOOP
				INSERT INTO pagamentos (matricula_idmatricula, parcela, data_vencimento, valor)
					VALUES (NEW.idmatricula, i, data, valor_parcela);
				data = data + 30;
			END LOOP;
			
			-- Dando baixa na primeira parcela
			-- Verificando se existe um caixa aberto na data atual
			SELECT data_caixa FROM caixa WHERE data_caixa = CURRENT_DATE INTO data_pagamento;
			IF (data_pagamento IS NULL) THEN
				INSERT INTO caixa VALUES (CURRENT_DATE, 0, 0, 0);
			END IF;
			
			-- Atualizando primeiro pagamento
			UPDATE pagamentos SET caixa_data_pagamento = CURRENT_DATE
				WHERE matricula_idmatricula = NEW.idmatricula AND parcela = 1;
			
			-- Atualizando o caixa
			UPDATE caixa SET entrada = entrada + valor_parcela 
				WHERE data_caixa = CURRENT_DATE;
			UPDATE caixa SET saldo = abertura + entrada - saida
				WHERE data_caixa = CURRENT_DATE;		
		END IF;
	RETURN NEW;
	END IF;
END $$;

CREATE TRIGGER t_inserir_notas_pagamentos_matricula BEFORE UPDATE ON matricula
FOR EACH ROW EXECUTE PROCEDURE f_inserir_notas_pagamentos_matricula();