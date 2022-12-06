CREATE SCHEMA aposentadoria; 
SET search_path = aposentadoria;

-- 1 
create table DADOSAPOS(
	nome VARCHAR(40),
	cpf VARCHAR(14),
	situcao VARCHAR(15),
	matricula VARCHAR(10),
	uorg NUMERIC,
	orgao VARCHAR(40),
	classe VARCHAR(10),
	padrao VARCHAR(5),
	regime_juridico VARCHAR(5),
	fundamentacao VARCHAR(15),
	dataocorrencia DATE,
	datadou DATE,
	estado VARCHAR(70)
);
							  
copy DADOSAPOS (
	nome,
	cpf,
	situcao ,
	matricula,
	uorg ,
	orgao,
	classe ,
	padrao,
	regime_juridico,
	fundamentacao ,
	dataocorrencia,
	datadou,
	estado )
		      from 'D:\Danilo Quirino\aposentadoria.csv'
			  csv header 
			  delimiter ';'
			  encoding 'win1252';
			  
ALTER TABLE DADOSAPOS ADD idaposentado SERIAL PRIMARY KEY;
SELECT * FROM DADOSAPOS LIMIT 10;

-- ----------------------------------------------------------------------------
-- 2
CREATE OR REPLACE FUNCTION retornaNomeEstado (cpf VARCHAR(14), opcao INT) RETURNS VARCHAR(70)
AS $$
DECLARE
	estados VARCHAR(70) DEFAULT '';
	digito VARCHAR(1) DEFAULT '';
	retorno VARCHAR(70) DEFAULT '';
BEGIN
	digito = SUBSTRING(cpf, 11, 1);
	
	IF (digito = '0') THEN 
		estados = 'Rio Grande do Sul';
	END IF;
	
	IF (digito = '1') THEN 
		estados = 'Distrito Federal,Goiás,Mato Grosso,Mato Grosso do Sul,Tocantins';
	END IF;
	
	IF (digito = '2') THEN 
		estados = 'Amazonas,Pará,Roraima,Amapá,Acre,Rondônia';
	END IF;
	
	IF (digito = '3') THEN 
		estados = 'Ceará,Maranhão,Piauí';
	END IF;
	
	IF (digito = '4') THEN 
		estados = 'Paraíba,Pernambuco,Alagoas,Rio Grande do Norte';
	END IF;
	
	IF (digito = '5') THEN 
		estados = 'Bahia,Sergipe';
	END IF;
	
	IF (digito = '6') THEN 
		estados = 'Minas Gerais';
	END IF;
	
	IF (digito = '7') THEN 
		estados = 'Rio de Janeiro,Espirito Santo';
	END IF;
	
	IF (digito = '8') THEN 
		estados = 'São Paulo';
	END IF;
	
	IF (digito = '9') THEN 
		estados = 'Paraná,Santa Catarina';
	END IF;

	IF (opcao = -1 ) THEN
		retorno = estados;
	END IF;
	
	IF (opcao = 0 ) THEN
		retorno = split_part(estados, ',', 1);
	END IF;
	
	IF (opcao >= 1 ) THEN
		retorno = split_part(estados, ',', opcao);
	END IF;
	RETURN retorno;
END;
$$ LANGUAGE 'plpgsql';

SELECT nome, cpf, retornaNomeEstado(cpf, 2) FROM DADOSAPOS LIMIT 2;
-- Resultado esperado: Aparecer Goías na coluna retornaNomeEstado
UPDATE DADOSAPOS SET estado = retornaNomeEstado(cpf, 0) WHERE idaposentado > 0;

-- ----------------------------------------------------------------------------
-- 3
CREATE OR REPLACE VIEW quantidadePorEstados AS
SELECT estado, COUNT(*) AS quantidade FROM DADOSAPOS GROUP BY estado ORDER BY quantidade DESC;

SELECT * FROM quantidadePorEstados;
-- Resposta esperada: Distrito Federal: 1751; Rio de Janeiro: 1223; São Paulo: 986 .....

-- ----------------------------------------------------------------------------
-- 4
CREATE OR REPLACE FUNCTION preencherMatricula (matricula VARCHAR(10)) RETURNS VARCHAR(10)
AS $$
DECLARE
	prefixo VARCHAR(3) DEFAULT '';
	sufixo VARCHAR(10) DEFAULT '';
	
	gerar INT DEFAULT 0;
	retorno VARCHAR(8) DEFAULT '';
BEGIN
	prefixo = SUBSTRING(matricula, 1, 3);
	SELECT interno.matricula FROM DADOSAPOS interno WHERE interno.matricula LIKE (prefixo||'%') ORDER BY interno.matricula ASC LIMIT 1 INTO sufixo;
	
	IF (sufixo LIKE '%*****') THEN
		gerar = 100001;
	ELSE
		gerar = cast(SUBSTRING(sufixo, 4, 5) as INT);
		gerar = gerar + 100001;
	END IF;
	
	retorno = prefixo|| substring(cast(gerar as varchar),2,5);
	RETURN retorno;
END;
$$ LANGUAGE 'plpgsql';

UPDATE DADOSAPOS SET matricula = preencherMatricula(matricula);
SELECT nome, matricula, preencherMatricula(matricula) FROM DADOSAPOS ORDER BY matricula ASC LIMIT 100;
-- Não deu muito certo, todo mundo ficou com a mesma numeração final

-- ----------------------------------------------------------------------------
-- 5
CREATE TABLE PESSOAS 
	(idpessoa SERIAL,
	 nome VARCHAR(40),
	 cpf VARCHAR(14),
	 matricula VARCHAR(10),
	 datahoje DATE,
	 idaposentado NUMERIC
);

CREATE OR REPLACE FUNCTION atualizarPessoa()
RETURNS TRIGGER AS $$
BEGIN
	IF(TG_OP = 'INSERT') THEN
		INSERT INTO PESSOAS (nome, cpf, matricula, datahoje, idaposentado)
			VALUES (NEW.nome, NEW.cpf, NEW.matricula, CURRENT_DATE, NEW.idaposentado);
		RETURN NEW;
	END IF;
	
	IF(TG_OP = 'UPDATE') THEN
		UPDATE PESSOAS p SET nome = NEW.nome, cpf = NEW.cpf, matricula = NEW.matricula,
		datahoje = CURRENT_DATE, idaposentado = NEW.idaposentado WHERE p.idaposentado = OLD.idaposentado;
		RETURN NEW;
	END IF;
	
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM PESSOAS p WHERE p.idaposentado = OLD.idaposentado;
		RETURN OLD;
	END IF;
	RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_atualizarPessoa
AFTER INSERT OR UPDATE OR DELETE  ON DADOSAPOS
FOR EACH ROW EXECUTE PROCEDURE atualizarPessoa();

INSERT INTO DADOSAPOS (nome, cpf, matricula)
	VALUES ('Danilo', '147.258.369-36', '99999999'), ('Domingues', '369.147.258-65', '88888888');

SELECT * FROM PESSOAS;
-- Resposta esperada: Inclusão na tabela PESSOA
DELETE FROM DADOSAPOS WHERE idaposentado = 5387;
-- Resposta esperada: Remoção da Pessoa id 5387, Domingues

-- ----------------------------------------------------------------------------
-- 6
CREATE USER pe3008835 with PASSWORD '3008835' LOGIN;
REVOKE ALL ON TABLE DADOSAPOS, PESSOAS FROM pe3008835;
GRANT SELECT, INSERT, UPDATE ON TABLE DADOSAPOS TO pe3008835;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA aposentadoria TO pe3008835;
GRANT SELECT ON TABLE PESSOAS TO pe3008835;
-- Usuário criado com os privilégios necessários

-- ----------------------------------------------------------------------------
-- 7
REASSIGN OWNED BY pe3008835 TO postgres;
DROP OWNED BY pe3008835;
-- Usuário removido

