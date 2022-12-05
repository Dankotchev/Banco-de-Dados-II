DROP DATABASE sgdt;
CREATE DATABASE sgdt;


CREATE TABLE
    IF NOT EXISTS refeicao (
        id INT AUTO_INCREMENT NOT NULL,
        nome VARCHAR(45) NOT NULL,
        preco_unitario DECIMAL(10, 2) NOT NULL,
        quantidade INT NOT NULL DEFAULT 0,
        descricao VARCHAR(90) NOT NULL,
        lista_ingredientes TEXT NOT NULL,
        status BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (id)
    );
   
INSERT INTO refeicao (nome,preco_unitario, descricao, lista_ingredientes) 
    VALUES
        ('Refeição Barata A', 12.50, 'Uma refeição boa e barata', 'ingrediente 1, ingrediente 2, ingrediente 3'),
        ('Refeição Barata B', 11.50, 'Uma refeição boa e barata', 'ingrediente 1, ingrediente 2, ingrediente 3'),
        ('Refeição Especial Diferente', 19.99, 'Uma refeição especial', 'ingrediente 1, ingrediente 2, ingrediente 3'),
        ('Refeição Cara 1', 33.33, 'Uma refeição cara e otima', 'ingrediente 1, ingrediente 2, ingrediente 3'),
        ('Refeição Cara 2', 39.60, 'Uma refeição cara e otima', 'ingrediente 1, ingrediente 2, ingrediente 3'),
        ('Refeição Cara 3', 40.99, 'Uma refeição cara e otima', 'ingrediente 1, ingrediente 2, ingrediente 3');

CREATE TABLE
    IF NOT EXISTS produto (
        id INT AUTO_INCREMENT NOT NULL,
        nome VARCHAR(45) NOT NULL,
        preco_unitario DECIMAL(10, 2) NOT NULL,
        quantidade INT NOT NULL,
        descricao VARCHAR(90) NULL,
        status BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (id)
    );

INSERT INTO produto (nome, preco_unitario, quantidade, descricao)
	VALUES 
    ('Água Mineral', 1.20, 250, 'Água mineral'),
    ('Suco de Uva 300ml', 4.5, 100, 'Suco de uva em caixinha'),
    ('Coca-cola 600ml', 10.99, 200, 'Refrigerante Coca-cola'),
    ('Kit-kat 180g', 5.66, 125, 'Barra de chocolate kit-kat');

CREATE TABLE
    IF NOT EXISTS veiculo (
        id_veiculo INT AUTO_INCREMENT NOT NULL,
        placa VARCHAR(8) NOT NULL,
        status_veiculo BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (id_veiculo)
    );

INSERT INTO veiculo (placa)
	VALUES
	('ABC4F568'),
	('BCC5A658'),
	('BGH3D658'),
	('MJU5D475'),
	('RGT6D985');

CREATE TABLE
    IF NOT EXISTS funcionario (
        id_funcionario INT AUTO_INCREMENT NOT NULL,
        nome_funcionario VARCHAR(60) NOT NULL,
        cpf VARCHAR(11) NOT NULL,
        senha VARCHAR (16) NOT NULL,
        data_nascimento DATE NULL,
        cargo VARCHAR(11) NULL,
        estado_civil VARCHAR(14) NULL,
        status_funcionario BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (id_funcionario),
        UNIQUE (cpf, nome_funcionario)
    );
INSERT INTO funcionario (nome_funcionario, cpf, senha, data_nascimento, cargo, estado_civil)
	VALUES
	('Danilo Quirino', '45632598210', 'danilo123', '1996-06-27', 'GERENTE', 'SOLTEIRO'),
	('Tereza Domingues', '36598745230', 'tereza123', '1963-09-15', 'GERENTE', 'CASADO'),
	('Lucas Quirino', '10236502500', 'lucas123' , '1965-03-30', 'COZINHEIRO', 'CASADO'),
	('Dani Domingues Quirino', 'dani123' , '00014530266', '1999-08-24', 'ATENDENTE', 'SOLTEIRO'),
	('Giovana Perreira Dassie', '65430222255', 'giovana123' , '1999-01-01', 'ATENDENTE', 'CASADO');

CREATE TABLE
    IF NOT EXISTS caixa (
        id_caixa INT AUTO_INCREMENT NOT NULL,
        data DATE NOT NULL,
        funcionario_id INT NOT NULL,
        estado VARCHAR(8) NOT NULL,
        abertura DECIMAL(10, 2) NOT NULL,
        entradas DECIMAL(10, 2) NOT NULL DEFAULT 0,
        saidas DECIMAL(10, 2) NOT NULL DEFAULT 0,
        status_caixa BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (id_caixa),
        FOREIGN KEY (funcionario_id) REFERENCES funcionario (id_funcionario)
    );
INSERT INTO caixa (data, funcionario_id, estado, abertura, entradas, saidas)
	VALUES 
	('2022-11-01', 1, 'FECHADO', 0, 3650, 1100),
	('2022-11-01', 2, 'FECHADO', 0, 2580, 850),
	('2022-11-02', 4, 'FECHADO', 0, 5600, 630),
	('2022-11-03', 4, 'FECHADO', 65, 1250, 0),
	('2022-11-03', 5, 'FECHADO', 80, 8350, 155),
	('2022-11-04', 4, 'FECHADO', 100, 3254, 120),
	('2022-11-05', 5, 'FECHADO', 0, 3000, 0);

CREATE TABLE
    IF NOT EXISTS pedido (
        id_pedido INT NOT NULL,
        veiculo_id INT NOT NULL,
        caixa_id INT NOT NULL,
        forma_pagamento VARCHAR(45) NOT NULL,
        data_pagamento DATE NOT NULL,
        estado_pedido VARCHAR(45) NOT NULL DEFAULT 'ABERTO',
        status_pedido BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (id_pedido),
        FOREIGN KEY (veiculo_id) REFERENCES veiculo (id_veiculo),
        FOREIGN KEY (caixa_id) REFERENCES caixa (id_caixa)
    );
INSERT INTO pedido (veiculo_id, caixa_id, forma_pagamento, data_pagamento)
	VALUES 
	(1, 1, 'PIX', '2022-11-01'),
	(2, 2, 'PIX', '2022-11-01'),
	(5, 3, 'PIX', '2022-11-02'),
	(4, 4, 'PIX', '2022-11-03'),
	(3, 4, 'PIX', '2022-11-03'),
	(1, 5, 'PIX', '2022-11-04'),
	(2, 5, 'PIX', '2022-11-05');
UPDATE pedido SET estado_pedido = 'ENTREGUE' WHERE  id > 0;

CREATE TABLE
    IF NOT EXISTS pedido_produto (
        produto_id INT NOT NULL,
        pedido_id INT NOT NULL,
        quantidade_pedido_produto INT NOT NULL,
        preco_unitario_produto DECIMAL(10, 2) NOT NULL,
        status_pedido_produto BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (pedido_id, produto_id),
        FOREIGN KEY (produto_id) REFERENCES produto (id),
        FOREIGN KEY (pedido_id) REFERENCES pedido (id_pedido)
    );
INSERT INTO pedido_produto (produto_id, pedidio_id, quantidade_pedido_produto , preco_unitario_produto)
	VALUES 
	(2, 1, 2, 4.75),
	(1, 1, 2, 1.25),
	(4, 4, 2, 6.50),
	(4, 1, 2, 1.25),
	(5, 1, 2, 1.25),
	(5, 3, 2, 12.00);

CREATE TABLE
    IF NOT EXISTS pedido_refeicao (
        refeicao_id INT NOT NULL,
        pedido_id INT NOT NULL,
        quantidade_pedido_refeicao INT NOT NULL,
        preco_unitario_refeicao DECIMAL(10, 2) NOT NULL,
        status_pedido_refeicao BOOLEAN NOT NULL DEFAULT TRUE,
        PRIMARY KEY (refeicao_id, pedido_id),
        FOREIGN KEY (refeicao_id) REFERENCES refeicao (id),
        FOREIGN KEY (pedido_id) REFERENCES pedido (id_pedido)
    );
 INSERT INTO pedido_refeicao  (refeicao_id, pedido_id , quantidade_pedido_refeicao, preco_unitario_refeicao)
	VALUES 
	(3, 1, 2, 12.75),
	(3, 2, 2, 11.25),
	(6, 4, 2, 33.33),
	(6, 1, 2, 12.75),
	(7, 1, 2, 12.25),
	(7, 5, 1, 40.00),
	(7, 6, 1, 42.00);

