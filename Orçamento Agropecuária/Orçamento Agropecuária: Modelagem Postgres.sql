CREATE SCHEMA orcamento_agropecuaria;
SET search_path TO orcamento_agropecuaria;

CREATE TABLE cliente (
 	id_cliente 		SERIAL,
	cpf 			VARCHAR(16) NOT NULL,
 	nome 			VARCHAR(60) NOT NULL,
	telefone 		VARCHAR(16),
	endereco 		VARCHAR(45),
	PRIMARY KEY (id_cliente)
);

CREATE TABLE orcamento (
	id_orcamento 		SERIAL,
	valortotal 			DECIMAL(10,2) DEFAULT 0,
	validade_orcamento 	DATE NOT NULL,
	parcelas 			INT DEFAULT 1,
	data_aprovacao 		DATE,
	cpf VARCHAR(16) 	NOT NULL,
	nome VARCHAR(60) 	NOT NULL,
	PRIMARY KEY (id_orcamento)
);

CREATE TABLE produto (
	id_produto 			SERIAL,
	valor_produto 		DECIMAL(10,2) NOT NULL,
	descricao 			VARCHAR(100) NULL,
	PRIMARY KEY (id_produto)
);

CREATE TABLE itens_orcamento (
	orcamento_id 		INT,
	produto_id 			INT NOT NULL,
	quantidade 			INT NOT NULL,
	valor_unitario 		DECIMAL(10,2) DEFAULT 0,
	PRIMARY KEY (orcamento_id, produto_id),
	FOREIGN KEY (orcamento_id)	REFERENCES orcamento (id_orcamento),
	FOREIGN KEY (produto_id) 	REFERENCES produto (id_produto)
);

CREATE TABLE venda (
	id_venda 			SERIAL,
	cliente_id 			INT NOT NULL,
	data_venda 			DATE NOT NULL,
	valortotal 			DECIMAL(10,2) NOT NULL,
	parcelas 			INT NOT NULL,
	PRIMARY KEY (id_venda),
	FOREIGN KEY (cliente_id)	REFERENCES cliente (id_cliente)
);

CREATE TABLE itens_venda (
	venda_id 			INT NOT NULL,
  	produto_id 			INT NOT NULL,
	quantidade 			INT NOT NULL,
  	valor_unitario 		DECIMAL(10,2) NOT NULL,
  	PRIMARY KEY (venda_id, produto_id),
  	FOREIGN KEY (venda_id) 		REFERENCES venda (id_venda),
  	FOREIGN KEY (produto_id) 	REFERENCES produto (id_produto)
);

CREATE TABLE caixa (
  	data_caixa 			DATE NOT NULL,
  	estado 				BOOL NOT NULL,
  	abertura 			DECIMAL(10,2) DEFAULT 0,
  	entradas 			DECIMAL(10,2) DEFAULT 0,
  	saidas 				DECIMAL(10,2) DEFAULT 0,
  	saldo 				DECIMAL(10,2) DEFAULT 0,
  	PRIMARY KEY (data_caixa)
);

CREATE TABLE pagamento (
  	venda_id 			INT NOT NULL,
  	parcela_pagamento 	INT NOT NULL,
  	vencimento 			DATE NOT NULL,
  	valor_parcela 		DECIMAL(10,2) NOT NULL,
  	data_pagamento 		DATE NULL,
  	PRIMARY KEY (venda_id, parcela_pagamento),
	FOREIGN KEY (venda_id) 			REFERENCES venda (id_venda),
	FOREIGN KEY (data_pagamento) 	REFERENCES caixa (data_caixa)
);
-- ----------------------------------------------------------------------------

-- Atualizar o Valor Total do orçamento, após a incluir, atualizar ou remver de Itens Orçamento
CREATE OR REPLACE FUNCTION valor_total_orcamento()
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

CREATE TRIGGER atualizar_valor_total_orcamento
AFTER INSERT OR UPDATE OR DELETE  ON itens_orcamento
FOR EACH ROW EXECUTE PROCEDURE valor_total_orcamento();
-- ----------------------------------------------------------------------------


-- Função que ao aprovar um Orçamento, realizar um Venda:
--	# 1 - Verificar se o cliente está cadastrado no banco, se não, cadastrar
--	# 2 - Cria uma Venda, usando os dados do Orcçamento
--	# 3 - Cria os Itens Venda relacionados usando os Itens Orçamentos
--	# 4 - Cria os Pagamentos da Venda
CREATE OR REPLACE FUNCTION aprovar_orcamento()
RETURNS TRIGGER AS $$
DECLARE
	-- Ids necessário para buscas e inserções
	resultado_cliente 	RECORD;
	resultado_venda		RECORD;
	resultado 			RECORD;
	
	-- Para geração dos pagamentos
	valorparcelado 		DECIMAL(10,2);
	quantidade 			INT;
	data 				DATE;
	
	-- Para inserção dos Itens Vendidos
	cursorIV CURSOR FOR SELECT * FROM itens_orcamento
					WHERE orcamento_id = OLD.id_orcamento;
	
BEGIN
	valorparcelado = round(NEW.valortotal / NEW.parcelas, 2);
	quantidade := 0;
	
	IF(TG_OP = 'UPDATE') THEN
		IF(NEW.data_aprovacao IS NOT NULL) THEN
			IF (NEW.data_aprovacao < OLD.validade_orcamento) THEN
				
				SELECT * INTO resultado_cliente
					FROM cliente WHERE cpf = OLD.cpf;
			
				-- Caso o cliente não esteja cadastrado ainda
				IF (resultado_cliente.cpf IS NULL) THEN
					INSERT INTO cliente (cpf, nome) VALUES (OLD.cpf, OLD.nome);
				END IF;
				
				-- Criar uma venda nova
				SELECT * INTO resultado_cliente
						FROM cliente WHERE cpf = OLD.cpf;
				INSERT INTO venda (cliente_id, data_venda, valortotal, parcelas)
					VALUES (resultado_cliente.id_cliente, NEW.data_aprovacao, OLD.valortotal, OLD.parcelas);
			
				-- Criar os Pagamentos da Venda
				SELECT * INTO resultado_venda
					FROM venda WHERE cliente_id = resultado_cliente.id_cliente AND data_venda = NEW.data_aprovacao;
				data := NEW.data_aprovacao;
		
				FOR i IN 1 .. OLD.parcelas LOOP
					INSERT INTO pagamento VALUES (resultado_venda.id_venda, i,data, valorparcelado, null);
					quantidade := quantidade + 30;
					data := NEW.data_aprovacao + quantidade;
				END LOOP;
			
				-- Inserir item_venda
				OPEN cursorIV;
				LOOP
					FETCH cursorIV INTO resultado;
					EXIT WHEN NOT FOUND;
				
					-- AQUI ACONTECE O DEVE ACONTECER
					INSERT INTO itens_venda VALUES 
						(resultado_venda.id_venda, resultado.produto_id, resultado.quantidade, resultado.valor_unitario);
				
				END LOOP;
			ELSE
				RAISE EXCEPTION 'Orçamento não pode ser aprovado. Data da aprovação superior a data de validade';
			END IF;	
		END IF;	
		RETURN NEW;
	END IF;
	RETURN TRUE;
	
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER aprovar_orcamento_criar_venda
BEFORE UPDATE OR DELETE  ON orcamento
FOR EACH ROW EXECUTE PROCEDURE aprovar_orcamento();
-- ----------------------------------------------------------------------------

-- Função que Atualiza os Pagamentos pagos, gerando entradas no caixa:
--	# 1 - Caso o caixa não exista, cria um novo caixa na data de pagamento
--	# 2 - Caso o caixa esteja fechado, não pode realizar o pagamento
CREATE OR REPLACE FUNCTION realizar_pagamento()
RETURNS TRIGGER AS $$
DECLARE
	-- Ids necessário para buscas e inserções
	record_caixa	RECORD;
	
BEGIN
	-- Apenas atualiza se não hover uma data anterior de pagamento
	IF (OLD.data_pagamento IS NULL) THEN
		
		IF (TG_OP = 'UPDATE') THEN
			SELECT * INTO record_caixa
				FROM caixa WHERE data_caixa = NEW.data_pagamento;
		
		
			-- Caso haja um caixa na data, mas fechado, encerrar a transação
			IF (record_caixa.data_caixa IS NOT NULL AND record_caixa.estado = FALSE) THEN
				RAISE EXCEPTION 'Pagamento não realizado. Caixa Fechado';
			END IF;
	
			-- Caso haja um Caixa na data, e está aberto
			IF (record_caixa.data_caixa IS NOT NULL AND record_caixa.estado = TRUE) THEN
				UPDATE caixa SET entradas = entradas + NEW.valor_parcela, saldo = saldo + NEW.valor_parcela
							WHERE data_caixa = NEW.data_pagamento;
			END IF;		
	
			-- Caso não haja um caixa na data de pagamento
			-- E atualiza o Caixa
			IF (record_caixa.data_caixa IS NULL) THEN
				INSERT INTO caixa (data_caixa, estado, entradas) VALUES (NEW.data_pagamento, TRUE, NEW.valor_parcela);
				UPDATE caixa SET saldo = saldo + NEW.valor_parcela
							WHERE data_caixa = NEW.data_pagamento;
			END IF;
		RETURN NEW;
		END IF;
	
	IF(TG_OP = 'DELETE') THEN
		IF (OLD.data_pagamento IS NOT NULL) THEN
			RAISE EXCEPTION 'Pagamento já efetuado. Não é possivel deleta';
		END IF;
	RETURN OLD;
	END IF;
	
	ELSE
		RAISE EXCEPTION 'Pagamento já efetuado. Não é possivel alterar';
	END IF;	
	RETURN TRUE;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER pagamentos_acoes
BEFORE UPDATE OR DELETE  ON pagamento
FOR EACH ROW EXECUTE PROCEDURE realizar_pagamento();
-- ----------------------------------------------------------------------------
