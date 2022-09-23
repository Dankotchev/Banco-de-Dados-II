CREATE SCHEMA professores;
SET search_path TO professores;

CREATE TABLE professor(
	nome 			VARCHAR(60),
	semestre_par	INT	DEFAULT 0,
	semestre_impar	INT DEFAULT 0,
	PRIMARY KEY (nome)
);

CREATE TABLE integrado (
	periodo 		INT,
	sigla 			VARCHAR(8),
	disciplina		VARCHAR(60),
	aulas			INT,
	n_professores 	INT,
	prof1			VARCHAR(60),
	prof2			VARCHAR(60),
	PRIMARY KEY (sigla),
	FOREIGN KEY (prof1) REFERENCES professor (nome),
	FOREIGN KEY (prof2) REFERENCES professor (nome)
);

CREATE TABLE bcc (
	periodo 		INT,
	semestre		VARCHAR(5),
	sigla 			VARCHAR(8),
	disciplina		VARCHAR(60),
	area  			VARCHAR(30),
	aulas			INT,
	n_professores 	INT,
	prof1			VARCHAR(60),
	prof2			VARCHAR(60),
	PRIMARY KEY (sigla),
	FOREIGN KEY (prof1) REFERENCES professor (nome),
	FOREIGN KEY (prof2) REFERENCES professor (nome)
);


CREATE TABLE outros (
	semestre		VARCHAR(5),
	sigla 			VARCHAR(8),
	disciplina		VARCHAR(60),
	curso  			VARCHAR(30),
	aulas			INT,
	n_professores 	INT,
	prof1			VARCHAR(60),
	prof2			VARCHAR(60),
	PRIMARY KEY (sigla),
	FOREIGN KEY (prof1) REFERENCES professor (nome),
	FOREIGN KEY (prof2) REFERENCES professor (nome)
);

-- FUNÇÃO: verifica professor
CREATE OR REPLACE FUNCTION f_verificar_professor(chave VARCHAR(60))
RETURNS VARCHAR(60) AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	SELECT nome INTO prof FROM professor WHERE nome = chave;
	RETURN prof;
END;
$$ LANGUAGE 'plpgsql';
-- ----------------------------------------------------------------------------


-- INTEGRADO
-- TRIGGER: Antes de inserir ou atualizar, verifica se existe o professor
--	Caso não haja, insere um novo professor
CREATE OR REPLACE FUNCTION f_professores_integrado()
RETURNS TRIGGER AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF (NEW.n_professores = 2) THEN
			prof := f_verificar_professor(NEW.prof2);
			IF (prof IS NULL) THEN
				INSERT INTO professor VALUES (NEW.prof2);
			END IF;
		END IF;

		prof := f_verificar_professor(NEW.prof1);
		IF (prof IS NULL) THEN
			INSERT INTO professor VALUES (NEW.prof1);
		END IF;

	RETURN NEW;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_professores_integrado
BEFORE INSERT OR UPDATE ON integrado
FOR EACH ROW EXECUTE PROCEDURE f_professores_integrado();
-- ----------------------------------------------------------------------------

-- INTEGRADO
-- TRIGGER: Atualiza o total de aulas de cada professor
CREATE OR REPLACE FUNCTION f_aulas_integrado()
RETURNS TRIGGER AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	IF (TG_OP = 'INSERT') THEN
		IF (NEW.n_professores = 2) THEN
			UPDATE professor SET semestre_par = semestre_par + NEW.aulas,
				semestre_impar = semestre_impar + NEW.aulas
				WHERE nome = NEW.prof2;
		END IF;

		UPDATE professor SET semestre_par = semestre_par + NEW.aulas,
				semestre_impar = semestre_impar + NEW.aulas
				WHERE nome = NEW.prof1;
	RETURN NEW;
	END IF;
	
	IF (TG_OP = 'UPDATE') THEN
		IF (NEW.n_professores = 2) THEN
			UPDATE professor SET semestre_par = semestre_par + NEW.aulas - OLD.aulas,
				semestre_impar = semestre_impar + NEW.aulas - OLD.aulas
				WHERE nome = NEW.prof2;
		END IF;

		UPDATE professor SET semestre_par = semestre_par + NEW.aulas - OLD.aulas,
				semestre_impar = semestre_impar + NEW.aulas - OLD.aulas
				WHERE nome = NEW.prof1;
	RETURN NEW;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		IF (NEW.n_professores = 2) THEN
			UPDATE professor SET semestre_par = semestre_par - OLD.aulas,
				semestre_impar = semestre_impar - OLD.aulas
				WHERE nome = OLD.prof2;
		END IF;

		UPDATE professor SET semestre_par = semestre_par - OLD.aulas,
				semestre_impar = semestre_impar - OLD.aulas
				WHERE nome = OLD.prof1;
	RETURN OLD;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_aulas_integrado
AFTER INSERT OR UPDATE OR DELETE ON integrado
FOR EACH ROW EXECUTE PROCEDURE f_aulas_integrado();
-- ----------------------------------------------------------------------------

-- BCC
-- TRIGGER: Antes de inserir ou atualizar, verifica se existe o professor
--	Caso não haja, insere um novo professor
CREATE OR REPLACE FUNCTION f_professores_bcc()
RETURNS TRIGGER AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF (NEW.n_professores = 2) THEN
			prof := f_verificar_professor(NEW.prof2);
			IF (prof IS NULL) THEN
				INSERT INTO professor VALUES (NEW.prof2);
			END IF;
		END IF;

		prof := f_verificar_professor(NEW.prof1);
		IF (prof IS NULL) THEN
			INSERT INTO professor VALUES (NEW.prof1);
		END IF;
		
	RETURN NEW;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_professores_bcc
BEFORE INSERT OR UPDATE ON bcc
FOR EACH ROW EXECUTE PROCEDURE f_professores_bcc();
-- ----------------------------------------------------------------------------

-- BCC
-- TRIGGER: Atualiza o total de aulas de cada professor
CREATE OR REPLACE FUNCTION f_aulas_bcc()
RETURNS TRIGGER AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	IF (TG_OP = 'INSERT') THEN
		IF (NEW.n_professores = 2) THEN
			IF (NEW.semestre = 'PAR') THEN
				UPDATE professor SET semestre_par = semestre_par + NEW.aulas
					WHERE nome = NEW.prof2;
			ELSE
				UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas
					WHERE nome = NEW.prof2;
			END IF;
		END IF;

		IF (NEW.semestre = 'PAR') THEN
			UPDATE professor SET semestre_par = semestre_par + NEW.aulas
				WHERE nome = NEW.prof1;
		ELSE
			UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas
				WHERE nome = NEW.prof1;
		END IF;
	RETURN NEW;
	END IF;
	
	IF (TG_OP = 'UPDATE') THEN
		IF (NEW.n_professores = 2) THEN
			IF (NEW.semestre = 'PAR') THEN
				UPDATE professor SET semestre_par = semestre_par + NEW.aulas - OLD.aulas
					WHERE nome = NEW.prof2;
			ELSE
				UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas - OLD.aulas
					WHERE nome = NEW.prof2;
			END IF;		
		END IF;

		IF (NEW.semestre = 'PAR') THEN
			UPDATE professor SET semestre_par = semestre_par + NEW.aulas - OLD.aulas
				WHERE nome = NEW.prof1;
		ELSE
			UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas - OLD.aulas
				WHERE nome = NEW.prof1;
		END IF;

	RETURN NEW;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		IF (NEW.n_professores = 2) THEN
			IF (NEW.semestre = 'PAR') THEN
				UPDATE professor SET semestre_par = semestre_par - OLD.aulas
					WHERE nome = OLD.prof2;
			ELSE
				UPDATE professor SET semestre_impar = semestre_impar - OLD.aulas
					WHERE nome = OLD.prof2;
			END IF;		
		END IF;

		IF (NEW.semestre = 'PAR') THEN
			UPDATE professor SET semestre_par = semestre_par - OLD.aulas
				WHERE nome = OLD.prof1;
		ELSE
			UPDATE professor SET semestre_impar = semestre_impar - OLD.aulas
				WHERE nome = OLD.prof1;
		END IF;
	RETURN NEW;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_aulas_bcc
AFTER INSERT OR UPDATE OR DELETE ON bcc
FOR EACH ROW EXECUTE PROCEDURE f_aulas_bcc();
-- ----------------------------------------------------------------------------

-- OUTROS
-- TRIGGER: Antes de inserir ou atualizar, verifica se existe o professor
--	Caso não haja, insere um novo professor
CREATE OR REPLACE FUNCTION f_professores_outros()
RETURNS TRIGGER AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
		IF (NEW.n_professores = 2) THEN
			prof := f_verificar_professor(NEW.prof2);
			IF (prof IS NULL) THEN
				INSERT INTO professor VALUES (NEW.prof2);
			END IF;
		END IF;

		prof := f_verificar_professor(NEW.prof1);
		IF (prof IS NULL) THEN
			INSERT INTO professor VALUES (NEW.prof1);
		END IF;
		
	RETURN NEW;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_professores_outros
BEFORE INSERT OR UPDATE ON outros
FOR EACH ROW EXECUTE PROCEDURE f_professores_outros();
-- ----------------------------------------------------------------------------

-- OUTROS
-- TRIGGER: Atualiza o total de aulas de cada professor
CREATE OR REPLACE FUNCTION f_aulas_outros()
RETURNS TRIGGER AS $$
DECLARE
	prof 	VARCHAR(60);
BEGIN
	IF (TG_OP = 'INSERT') THEN
		IF (NEW.n_professores = 2) THEN
			IF (NEW.semestre = 'PAR') THEN
				UPDATE professor SET semestre_par = semestre_par + NEW.aulas
					WHERE nome = NEW.prof2;
			ELSE
				UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas
					WHERE nome = NEW.prof2;
			END IF;
		END IF;

		IF (NEW.semestre = 'PAR') THEN
			UPDATE professor SET semestre_par = semestre_par + NEW.aulas
				WHERE nome = NEW.prof1;
		ELSE
			UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas
				WHERE nome = NEW.prof1;
		END IF;
	RETURN NEW;
	END IF;
	
	IF (TG_OP = 'UPDATE') THEN
		IF (NEW.n_professores = 2) THEN
			IF (NEW.semestre = 'PAR') THEN
				UPDATE professor SET semestre_par = semestre_par + NEW.aulas - OLD.aulas
					WHERE nome = NEW.prof2;
			ELSE
				UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas - OLD.aulas
					WHERE nome = NEW.prof2;
			END IF;		
		END IF;

		IF (NEW.semestre = 'PAR') THEN
			UPDATE professor SET semestre_par = semestre_par + NEW.aulas - OLD.aulas
				WHERE nome = NEW.prof1;
		ELSE
			UPDATE professor SET semestre_impar = semestre_impar + NEW.aulas - OLD.aulas
				WHERE nome = NEW.prof1;
		END IF;

	RETURN NEW;
	END IF;

	IF (TG_OP = 'DELETE') THEN
		IF (NEW.n_professores = 2) THEN
			IF (NEW.semestre = 'PAR') THEN
				UPDATE professor SET semestre_par = semestre_par - OLD.aulas
					WHERE nome = OLD.prof2;
			ELSE
				UPDATE professor SET semestre_impar = semestre_impar - OLD.aulas
					WHERE nome = OLD.prof2;
			END IF;		
		END IF;

		IF (NEW.semestre = 'PAR') THEN
			UPDATE professor SET semestre_par = semestre_par - OLD.aulas
				WHERE nome = OLD.prof1;
		ELSE
			UPDATE professor SET semestre_impar = semestre_impar - OLD.aulas
				WHERE nome = OLD.prof1;
		END IF;
	RETURN NEW;
	END IF;

END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_aulas_outros
AFTER INSERT OR UPDATE OR DELETE ON outros
FOR EACH ROW EXECUTE PROCEDURE f_aulas_outros();
-- ----------------------------------------------------------------------------

