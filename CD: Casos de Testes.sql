USE cd;

INSERT INTO itensvenda (idvenda, codcd, qtde, valor) VALUES (1, 5, 15, 36); -- Inserção de um item venda, na venda 1, do CD 5, com 15 unidades vendidas
UPDATE itensvenda SET qtde = 30 WHERE idvenda = 1 AND codcd = 5;  -- Alterando a quantidade vendida
DELETE FROM itensvenda WHERE idvenda = 1 AND codcd = 5;


UPDATE autor SET nomeaut = LOWER(nomeaut) WHERE codaut <= 5;