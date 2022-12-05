CREATE EXTENSION file_fdw;
CREATE SERVER servidorarquivo FOREIGN DATA WRAPPER file_fdw;
CREATE FOREIGN TABLE dados (
	codlegislatura NUMERIC,
	datemissao DATE,
	idedocumento NUMERIC,
	idecadastro NUMERIC,
	indtipodocumento NUMERIC,
	nucarteiraparlamentar NUMERIC,
	nudeputadoid NUMERIC,
	nulegislatura NUMERIC,
	numano NUMERIC,
	numespecificacaosubcota NUMERIC,
	numlote NUMERIC,
	nummes NUMERIC,
	numparcela NUMERIC,
	numressarcimento NUMERIC,
	numsubcota NUMERIC,
	sgpartido VARCHAR(255),
	sguf VARCHAR(255),
	txnomeparlamentar VARCHAR(255),
	txtcnpjcpf VARCHAR(255),
	txtdescricao VARCHAR(255),
	txtdescricaoespecificacao VARCHAR(255),
	txtfornecedor VARCHAR(255),
	txtnumero VARCHAR(255),
	txtpassageiro VARCHAR(255),
	txttrecho VARCHAR(255),
	vlrdocumento NUMERIC,
	vlrglosa NUMERIC,
	vlrliquido NUMERIC,
	vlrrestituicao NUMERIC
)
	OPTION(filename 'D:\cota-parlamentar.csv' format 'csv', header 'true', delimiter ',');
	
SELECT * FROM dados LIMIT 100;

CREATE TABLE partido AS SELECT DISTINCT sgpartido FROM dados LIMIT 10;

SELECT * FROM partido;
ALTER TABLE partido ADD COLUMN idpartido SERIAL;

CREATE TABLE parlamentar AS SELECT DISTINCT nudeputadoid, txnomeparlamentar FROM dados LIMIT 10;
SELECT * FROM parlamentar;

CREATE TABLE fornecedor AS SELECT DISTINCT txtcnpjcpf, txtfornecedor FROM dados LIMIT 10;
SELECT * FROM fornecedor;
ALTER TABLE fornecedor ADD COLUMN idfornecedor SERIAL;


BEGIN;
	ALTER TABLE dados ADD COLUMN idpartido NUMERIC;
	UPDATE dados SET idpartido = partido.idpartido WHERE sgpartido = partido.sgpartido;
	SELECT * FROM dados LIMIT 10;
	ROLLBACK;
	