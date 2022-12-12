-- 	####	IMPORTAR UMA BASE DE DADOS:	####
--	1º Criar uma tabela para receber a importação

CREATE TABLE aposentados (
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
	ato VARCHAR(15),
	doclegal VARCHAR(15),
	numeredoc VARCHAR(10),
	datapublicacao NUMERIC
);

-- 2º Copiar para a tabela criada, os valores a serem importados
COPY aposentados(
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
	ato,
	doclegal,
	numeredoc,
	datapublicacao
) FROM 'C:\caminho\do\arquivo.csv' csv header delimiter ';'encoding 'win1252';

-- 3º.A. Se a tabela criada não tiver um id para Chave Primária, criar:
ALTER TABLE aposentados ADD id SERIAL PRIMARY KEY;
-- 3º.b. Se a tabela já possui um campo de Chave Primária, usar:
-- ALTER TABLE aposentados ADD PRIMARY KEY (id);

-- 4º Normalizar a tabela, criando uma outra tabela:
--		4.A. Se já houver um código na tabela original, resolve-se deixando o codigo
-- como chave estrangeira na tabela original, e deletando as demais colunas da nova tabela que se encontram lá
CREATE TABLE orgao AS SELECT DISTINCT(uorg), orgao FROM aposentados;
-- Corrigindo uorg que se repete 
UPDATE orgao SET uorg = 25207 WHERE orgao = 'ELETROBRAS'
ALTER TABLE orgao ADD PRIMARY KEY (uorg);

--		4.B Se na tabela original não houver um id para a tabela a ser extraida,
-- após criar a tabela nova, adicionar um novo campo na tabela importada, e relacionar
-- os valores dos campos dela com a nova tabela e depois deletar os campos da tabela original

--_________________________________________________________________________________________________

-- 	#### VIEWs ####
-- Só vale a pena criar uma view quando envolve mais de uma tabela

CREATE VIEW V_aposentados_por_orgao AS
SELECT uorg, orgao, (SELECT COUNT(*) FROM aposentados WHERE uorg=o.uorg) FROM orgao o
	ORDER BY orgao;

SELECT * FROM V_aposentados_por_orgao;

--_________________________________________________________________________________________________

-- 	#### FUNCTIONs ####

-- Criar uma função de string que modifica o cpf da tabela, complementando os numeros faltantes

CREATE OR REPLACE FUNCTION f_mostra_cpf (cpf VARCHAR(14)) RETURNS VARCHAR(14)
AS $$
DECLARE
	novo VARCHAR(14) DEFAULT '';
BEGIN
	novo = substring(cpf,5,2)||substring(cpf,9,1); -- || o mesmo que a função concat
	novo = novo||substring(cpf,4,9)||substring(cpf,10,2);
	RETUNR novo;
END;
$$ LANGUAGE 'plpgsql';

-- Uso da função
-- Em uma visualização:
SELECT nome, f_mostra_cpf(cpf) FROM aposentados;

-- Em uma alteração na tabela
UPDATE aposentados SET cpf = f_mostra_cpf(cpf) WHERE id > 0;

-- Criar uma função que gera números aleatórios para preencer a matricula

CREATE OR REPLACE FUNCTION f_preencher_matricula (matricula VARCHAR(8)) RETURNS VARCHAR(8)
AS $$
DECLARE
	gerar INT DEFAULT 0;
	retorno VARCHAR(8) DEFAULT '';
BEGIN
	gerar = cast(random()*10000 as integer)* 100000;
	retorno = substring(valor,1,3)|| substring(cast(gerar as varchar),2,5);
END;
$$ LANGUAGE 'plpgsql';


--_________________________________________________________________________________________________

-- 	#### TRIGGERs ####
-- Atualizar o Valor Total do orçamento, após a incluir, atualizar ou remver de Itens Orçamento
CREATE OR REPLACE FUNCTION f_valor_total_orcamento()
RETURNS TRIGGER AS $$
BEGIN
	IF(TG_OP = 'INSERT') THEN
		UPDATE orcamento SET valortotal = valortotal + (NEW.valor_unitario * NEW.quantidade)
						WHERE id_orcamento = NEW.orcamento_id;
		RETURN NEW;
	END IF;
	
	IF(TG_OP = 'UPDATE') THEN
		UPDATE orcamento SET valortotal = valortotal - (OLD.valor_unitario * OLD.quantidade) + (NEW.valor_unitario * NEW.quantidade)
						WHERE id_orcamento = NEW.orcamento_id;
		RETURN NEW;
	END IF;
	
	IF(TG_OP = 'DELETE') THEN
		UPDATE orcamento SET valortotal = valortotal - (OLD.valor_unitario * OLD.quantidade)
						WHERE id_orcamento = OLD.orcamento_id;
		RETURN OLD;
	END IF;
	RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER t_atualizar_valor_total_orcamento
AFTER INSERT OR UPDATE OR DELETE  ON itens_orcamento
FOR EACH ROW EXECUTE PROCEDURE f_valor_total_orcamento();

--_________________________________________________________________________________________________

-- 	#### USUÁRIOS ####

-- 1º Criar os usuários e/ou seus roles
CREATE USER usuarioA with PASSWORD 'senha1' LOGIN;
CREATE USER usuarioB with PASSWORD 'senha2' LOGIN;
CREATE USER usuarioC with PASSWORD 'senha3' LOGIN;

CREATE ROLE papelA;
CREATE ROLE papelB;

-- 2º Remover as permições (ou dos usuários ou dos roles)
-- REVOKE ALL ON ALL TABLES IN SCHEMA public FROM papelA, papelB; -- Removendo de todas as tabelas de um schema
REVOKE ALL ON TABLE aposentados, orgao FROM papelA, papelB; -- Removendo apenas das tabelas selecionadas

-- 3º Concedendo permições aos usuários ou roles
-- GRANT USAGE, SELECT ON ALL TABLES IN SCHEMA public TO papelA, papelB; -- Pode ser necessário para usar o insert quando tem um SERIAL
GRANT SELECT, INSERT, UPDATE ON TABLE aposentados, orgao TO papelA, papelB;
GRANT DELETE ON TABLE aposentados, orgao TO papelA;

-- 4º Atribuindo as roles aos usuários
GRANT papelA TO usuarioA, usuarioB; -- Pode realizar todas as ações nas tabelas
GRANT papelB TO usuarioC; -- Não pode realizar delete nas tabelas

-- 5º Removendo usuários
REASSIGN OWNED BY usuarioB TO postgres;
DROP OWNED BY usuarioB;
-- DROP ROLE papelB
