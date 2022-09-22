SET search_path TO orcamento_agropecuaria;

INSERT INTO cliente (cpf, nome) VALUES
('123.456.789-00', 'Carlos'), 	('009.876.543-21', 'Marta'),
('000.111.222-33', 'Peixoto');

INSERT INTO orcamento (validade_orcamento, cpf, nome, parcelas) VALUES
('2022-09-18', '654.098.123-66', 'Danilo',	3),
('2022-09-14', '767.098.123-45', 'Daniele',	5),
('2022-09-15', '123.456.789-00', 'Carlos',	2),
('2022-09-16', '009.876.543-21', 'Marta', 	10),
('2022-09-01', '000.111.222-33', 'Peixoto',	7);

INSERT INTO produto (valor_produto, descricao) VALUES 
(125.20, 'Item A'), 	(120.20, 'Item B'), 	(147.20, 'Item C'),
(88.66, 'Item D'), 		(44.55, 'Item E'), 		(77.60, 'Item F');

INSERT INTO itens_orcamento VALUES
(1, 1, 10, 125.20), (1, 4, 8, 88.99), 	(1, 6, 6, 70.99),
(2, 3, 5, 150.00), 	(2, 5, 3, 45.00), 	(2, 6, 2, 79.00),
(3, 4, 2, 80.00), 	(3, 6, 2, 77.60),	(3, 3, 1, 145.80),
(4, 1, 1, 123.45),	(4, 5, 7, 44.70),	(4, 2, 2, 130.00),
(5, 1, 2, 135.00),	(5, 2, 5, 134.00), 	(5, 4, 1, 44.00);


INSERT INTO caixa (data_caixa, estado, abertura, saldo) VALUES
('2022-09-13', TRUE, 40.00, 40.00), ('2022-09-14', FALSE, 35.00, 35.00);

SELECT * FROM cliente;
SELECT * FROM orcamento;
SELECT * FROM produto;
SELECT * FROM itens_orcamento;
SELECT * FROM cliente WHERE cpf = '123.456.789-00';
SELECT * FROM venda;
SELECT * FROM pagamento;
SELECT * FROM caixa;


-- Transformando um Orçamento em uma Venda Válida
	-- Orçamentos na validade
		-- Cliente já cadastrado
UPDATE orcamento SET data_aprovacao = '2022-09-13' WHERE id_orcamento = 3;
UPDATE orcamento SET data_aprovacao = '2022-09-14' WHERE id_orcamento = 4;
		-- Cliente não cadastrado
UPDATE orcamento SET data_aprovacao = '2022-09-13' WHERE id_orcamento = 1;


	-- Orçamentos vencidos
		-- Cliente já cadastrado
UPDATE orcamento SET data_aprovacao = '2022-09-14' WHERE id_orcamento = 5;
		-- Cliente não cadastrado
UPDATE orcamento SET data_aprovacao = '2022-09-18' WHERE id_orcamento = 2;


-- Pagamentos
	-- Pagamentos com o Caixa aberto
UPDATE pagamento SET data_pagamento = '2022-09-13' WHERE venda_id = 1 AND parcela_pagamento = 1;
UPDATE pagamento SET data_pagamento = '2022-09-13' WHERE venda_id = 2 AND parcela_pagamento = 1;

	-- Pagamentos com o caixa fechado
UPDATE pagamento SET data_pagamento = '2022-09-14' WHERE venda_id = 3 AND parcela_pagamento = 1;

	-- Pagamentos com o caixa inexistênte
UPDATE pagamento SET data_pagamento = '2022-10-13' WHERE venda_id = 1 AND parcela_pagamento = 2;
UPDATE pagamento SET data_pagamento = '2022-10-10' WHERE venda_id = 2 AND parcela_pagamento = 2;

-- Fechar caixas abertos
UPDATE caixa SET estado = FALSE WHERE estado = TRUE;






