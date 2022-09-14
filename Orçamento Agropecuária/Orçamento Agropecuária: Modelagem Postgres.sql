CREATE SCHEMA orcamento_agropecuaria;
SET search_path TO orcamento_agropecuaria;

CREATE TABLE OR REPLACE cliente (
 	id_cliente NOT NULL SERIAL,
 	nome VARCHAR(60) NOT NULL,
	telefone VARCHAR(16) NOT NULL,
	cpf VARCHAR(16),
	endereco VARCHAR(45),
	PRIMARY KEY (`id_cliente`)
);

CREATE TABLE OR REPLACE orcamento (
	id_orcamento SERIAL,
	cliente_id INT NOT NULL,
	valortotal DECIMAL(10,2) NOT NULL,
	validade_orcamento DATE NOT NULL,
	parcelas INT NOT NULL,
	data_aprovacao DATE,
	PRIMARY KEY (id_orcamento),
	FOREIGN KEY (cliente_id) REFERENCES cliente (id_cliente)
);

CREATE TABLE OR REPLACE produto (
	id_produto SERIAL,
	valor_produto DECIMAL(10,2) NOT NULL,
	nome VARCHAR(60),
	descricao VARCHAR(100) NULL,
	PRIMARY KEY (id_produto)
);

CREATE TABLE OR REPLACE itens_orcamento (
	orcamento_id SERIAL,
	produto_id INT NOT NULL,
	valor_unitario DECIMAL(10,2) NOT NULL,
	PRIMARY KEY (orcamento_id, produto_id),
	FOREIGN KEY (orcamento_id) REFERENCES orcamento (id_orcamento)
	FOREIGN KEY (produto_id) REFERENCES produto (id_produto)
);

CREATE TABLE OR REPLACE venda (
	id_venda SERIAL,
	cliente_id INT NOT NULL,
	data_venda DATE NOT NULL,
	valortotal DECIMAL(10,2) NOT NULL,
	parcelas INT NOT NULL,
	PRIMARY KEY (id_venda),
	FOREIGN KEY (cliente_id) REFERENCES cliente (id_cliente)
);

CREATE TABLE OR REPLACE itens_venda (
	venda_id INT NOT NULL,
  	produto_id INT NOT NULL,
  	valor_unitario DECIMAL(10,2) NOT NULL,
  	PRIMARY KEY (venda_id, produto_id),
  	FOREIGN KEY (venda_id) REFERENCES venda (id_venda),
  	FOREIGN KEY (produto_id) REFERENCES produto (id_produto)
);

CREATE TABLE OR REPLACE caixa (
  	data_caixa DATE NOT NULL,
  	estado BOOL NOT NULL,
  	saldo DECIMAL(10,2) NOT NULL DEFAULT 0,
  	PRIMARY KEY (data_caixa)
);

CREATE TABLE OR REPLACE pagamento (
  	venda_id INT NOT NULL,
  	parcela_pagamento INT NOT NULL,
  	vencimento DATE NOT NULL,
  	valor_parcela DECIMAL(10,2) NOT NULL,
  	data_pagamento DATE NULL,
  	PRIMARY KEY (venda_id, parcela_pagamento),
	FOREIGN KEY (venda_id) REFERENCES venda (id_venda)
);

CREATE TABLE OR REPLACE  movimentacao (
  	caixa_data DATE NOT NULL,
  	pagamento_venda_id INT NOT NULL,
 	pagamento_parcela INT NOT NULL,
  	PRIMARY KEY (caixa_data, pagamento_venda_id, pagamento_parcela),
    FOREIGN KEY (caixa_data) REFERENCES caixa (data_caixa)
    FOREIGN KEY (pagamento_venda_id , pagamento_parcela) REFERENCES pagamento (venda_id , parcela_pagamento)
);




