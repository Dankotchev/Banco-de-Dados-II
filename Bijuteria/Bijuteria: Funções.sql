CREATE SCHEMA bijuteria;
SET search_path TO bijuteria;


--1 Atualizar o total de horas dos cursos
CREATE OR REPLACE FUNCTION f_atualiza_totalhoras() RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $$
DECLARE carga_horaria_materia INT DEFAULT 0;
BEGIN
	IF (TG_OP = 'INSERT') THEN
		SELECT carga_horaria FROM materia WHERE idmateria = NEW.materia_idmateria INTO carga_horaria_materia;
		UPDATE curso SET totalhoras = totalhoras + carga_horaria_materia
			WHERE idcurso = NEW.idcurso;
	END IF;

	IF (TG_OP = 'UPDATE') THEN
		UPDATE curso SET totalhoras = totalhoras +
			(SELECT carga_horaria FROM materia WHERE idmateria = NEW.materia_idmateria) -
			(SELECT carga_horaria FROM materia WHERE idmateria = OLD.materia_idmateria)
			WHERE idcurso = NEW.idcurso;
		RETURN NEW;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		UPDATE curso SET totalhoras = totalhoras -
			(SELECT carga_horaria FROM materia WHERE idmateria = OLD.materia_idmateria)
			WHERE idcurso = OLD.idcurso;
		  RETURN OLD;
	END IF;
	RETURN NEW;
END $$

CREATE TRIGGER t_atualizar_totalhoras AFTER INSERT OR UPDATE OR DELETE ON curso_tem_materia
FOR EACH ROW EXECUTE PROCEDURE f_atualiza_totalhoras();


-- 2 Total vez que uma matrícula for adicionada os pagamentos devem ser gerados
-- em pagamentos para o aluno correspondente, de acordo com QTDEPARCELAS e o
-- VALORDOCURSO em curso, a matricula deve ser inserida com SITUACAO de A de ATIVO.

CREATE OR REPLACE FUNCTION f_parcelas_matricula() RETURNS TRIGGER
LANGUAGE 'plpgsql'
AS $$
DECLARE
	valor_curso_busca	DECIMAL(10,2),
	data 				DATE,
	valor_parcela		DECIMAL(10,2),
	i 					INT DEFAULT 0;

BEGIN
	IF (TG_OP = 'INSERT') THEN
		IF (NEW.situacao = 'A') THEN
			data = current_date;
			SELECT valor_curso FROM curso JOIN turma ON (idcurso = curso_idcurso)
				WHERE idturma = NEW.turma_idturma INTO valor_curso_busca;

			valor_parcela = round((valor_curso_busca / NEW.parcelas), 2);

			FOR i in 1..NEW.parcelas LOOP
				INSERT INTO pagamentos (matricula_idmatricula, parcela, data_vencimento, valor)
					VALUES (NEW.idmatricula, i, data, valor_parcela);
				data = data + 30;
			END LOOP;
		END IF;
	RETURN NEW;
	END IF;
RETURN NEW;
END $$

CREATE TRIGGER t_parcelas_matricula AFTER INSERT on matricula
FOR EACH ROW EXECUTE PROCEDURE f_parcelas_matricula();


-- 3 	Toda vez que for efetuado um pagamento o valor deve ir para caixa do dia, se o
-- caixa do dia não existir ele deve ser criado automaticamente e o valor acumulado na
-- entrada e o saldo do caixa atualizado

CREATE OR REPLACE FUNCTION f_efetuar_pagamentos() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
DECLARE
	data_pagamento DATE,
BEGIN
	IF (TG_OP = 'UPDATE') THEN

		-- Verificando se alterou a data de pagamento
		IF (NEW.caixa_data_pagamento IS NOT NULL) THEN
		SELECT data_caixa FROM caixa WHERE data_caixa = NEW.caixa_data_pagamento
			INTO data_pagamento;

			-- Verificando se existe um caixa aberto na data de pagamento
			IF (data_pagamento IS NULL) THEN
				INSERT INTO caixa VALUES (NEW.caixa_data_pagamento, 0, 0, 0);
			END IF;

		-- Atualizando o caixa
		UPDATE caixa SET entrada = entrada + NEW.valor 
			WHERE data_caixa = NEW.caixa_data_pagamento;
		UPDATE caixa SET saldo = abertura + entrada - saida
			WHERE data_caixa = NEW.caixa_data_pagamento;

		END IF;
	RETURN NEW;
	END IF;
RETURN NEW;
END $$

CREATE TRIGGER t_efetuar_pagamentos BEFORE UPDATE ON pagamentos
FOR EACH ROW EXECUTE PROCEDURE f_efetuar_pagamentos();


-- 4	Toda vez que um aluno for matriculado deve ser inserido no arquivo de notas os
-- registros para armazenar as notas para cada disciplina do curso, as notas devem ser
-- inseridas com 0

CREATE OR REPLACE FUNCTION f_inserir_notas_nova_matricula() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
DECLARE
	nova_matricula 	RECORD;
BEGIN
	IF (TG_OP = 'INSERT') THEN
		FOR nova_matricula_materia IN
							SELECT idmateria FROM turma t
								JOIN curso ON (t.curso_idcurso = idcurso)
								JOIN curso_tem_materia cm ON (idcurso = cm.curso_idcurso)
								JOIN materia ON (materia_idmateria = idmateria)
								WHERE idturma = NEW.turma_idturma 
			LOOP
				INSERT INTO notas (null, NEW.idmatricula, nova_matricula_materia);
		END LOOP;
	RETURN NEW;
	END IF;
END $$

CREATE TRIGGER t_inserir_notas_nova_matricula AFTER INSERT ON matricula
FOR EACH ROW EXECUTE PROCEDURE f_inserir_notas_nova_matricula();

-- 5	Faça uma função que passado a matricula do aluno informe se o aluno foi
-- aprovado para isso ela tera que verificar se todos as medias das 4 notas em cada
-- disciplina é acima de 6.0

CREATE OR REPLACE FUNCTION f_situacao_aluno(matricula INT)
LANGUAGE 'plpgsql' AS $$
DECLARE
	media 		DECIMAL(4,2);
BEGIN
	FOR sit_materia IN SELECT * FROM notas 
						JOIN materia ON (materia_idmateria = idmateria)
						WHERE matricula_idmatricula = matricula LOOP
		media = round(((sit_materia.nota1 + sit_materia.nota2 + sit_materia.nota3 + sit_materia.nota4) / 4), 2);

		IF (media < 6.0) THEN
			RAISE NOTICE 'Matéria: % - Reprovado', sit_materia.nome;
		ELSE
			RAISE NOTICE 'Matéria: % - Aprovado', sit_materia.nome;
		END IF;
	END LOOP;
END $$

CREATE OR REPLACE FUNCTION f_atualizar_total_alunos() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
		UPDATE turma SET total_aluno = total_aluno + 1 WHERE idturma = NEW.turma_idturma;
		RETURN NEW;
	END IF;

	IF (TG_OP = 'UPDATE') THEN
		IF (NEW.turma_idturma <> OLD.turma_idturma) THEN
			UPDATE turma SET total_aluno = total_aluno + 1 WHERE idturma = NEW.turma_idturma;
			UPDATE turma SET total_aluno = total_aluno - 1 WHERE idturma = OLD.turma_idturma;
		END IF;
		RETURN NEW;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		UPDATE turma SET total_aluno = total_aluno + 1 WHERE idturma = OLD.turma_idturma;
		RETURN OLD;
	END IF;

END $$

CREATE TRIGGER t_atualizar_total_alunos AFTER INSERT OR UPDATE OR DELETE ON matricula
FROM EACH ROW EXECUTE PROCEDURE f_atualizar_total_alunos();

-- 7	Quando a situação da matricula for C de CANCELADO todas os pagamentos não
-- pagos desse aluno deve ser colocado valor 0

CREATE OR REPLACE FUNCTION f_cancelar_matriculas() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
BEGIN
	IF (TG_OP = 'UPDATE') THEN
		IF (OLD.situacao <> 'C' AND NEW.situacao = 'C') THEN
			UPDATE pagamentos SET valor = 0
				WHERE matricula_idmatricula = NEW.idmatricula AND caixa_data_pagamento IS NULL;
		END IF;
	RETURN NEW;
	END IF;
RETURN NEW;
END $$

CREATE TRIGGER t_cancelar_matriculas AFTER UPDATE ON matricula
FROM EACH ROW EXECUTE PROCEDURE f_cancelar_matriculas();

-- 8	Toda vez que for pago uma despesa referente a uma determinada turma o caixa
-- deve ser atualizado, caso o caixa não exista ele deve ser criado e atualizado o campo
-- SAIDA e SALDO.

CREATE OR REPLACE FUNCTION f_efetuar_gastos() RETURNS TRIGGER
LANGUAGE 'plpgsql' AS $$
DECLARE
	data_pagamento DATE,
BEGIN
	IF (TG_OP = 'INSERT') THEN
		SELECT data_caixa FROM caixa WHERE data_caixa = NEW.caixa_data_gasto
			INTO data_pagamento;

		-- Verificando se existe um caixa aberto na data do gasto
		IF (data_pagamento IS NULL) THEN
			INSERT INTO caixa VALUES (NEW.caixa_data_gasto, 0, 0, 0);
		END IF;

		-- Atualizando o caixa
		UPDATE caixa SET saida = saida + NEW.valor 
			WHERE data_caixa = NEW.caixa_data_gasto;
		UPDATE caixa SET saldo = abertura + entrada - saida
			WHERE data_caixa = NEW.caixa_data_gasto;
	RETURN NEW;
	END IF;

	IF (TG_OP = 'UPDATE') THEN
		UPDATE caixa SET 
			saida = saida + NEW.valor - OLD.valor,
			saldo = abertura + entrada - saida
			WHERE data_caixa = NEW.caixa_data_gasto;
	RETURN NEW;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		UPDATE caixa SET 
			saida = saida + NEW.valor - OLD.valor,
			saldo = abertura + entrada - saida
			WHERE data_caixa = NEW.caixa_data_gasto;
	RETURN NEW;
	END IF;		

RETURN NEW;
END $$

CREATE TRIGGER t_efetuar_gastos BEFORE INSERT OR UPDATE OR DELETE ON gastos
FOR EACH ROW EXECUTE PROCEDURE f_efetuar_gastos();

