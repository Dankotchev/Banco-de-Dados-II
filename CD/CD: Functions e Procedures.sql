USE cd;

-- Processo que altera todos os preços dos cd a partir de uma porcentagem
DROP PROCEDURE IF EXISTS AJUSTAPRECO;
DELIMITER $$
CREATE PROCEDURE AJUSTAPRECO (IN valor FLOAT )
	BEGIN
		UPDATE cd SET preco = (preco * (1 + valor / 100))
			WHERE codcd >= 1;
	END $$
DELIMITER ;

-- Função que conta a quantidade de musicas por CD
DROP FUNCTION IF EXISTS CONTAMUSICACD;
DELIMITER $$
CREATE FUNCTION CONTAMUSICACD (cd int) RETURNS INT DETERMINISTIC
BEGIN
	DECLARE qtd INT DEFAULT 0;
    SELECT COUNT(*) FROM faixa WHERE codcd = cd INTO qtd;
	RETURN qtd;
END $$
DELIMITER ;

-- Retorna o valor de cada música dentro de cada CD
DROP FUNCTION IF EXISTS PRECOPORCD;
DELIMITER $$
CREATE FUNCTION PRECOPORCD (cd int) RETURNS FLOAT DETERMINISTIC
BEGIN
	DECLARE valorcd FLOAT DEFAULT 0;
    SELECT preco FROM cd WHERE codcd = cd INTO valorcd;
    RETURN ROUND(valorcd/CONTAMUSICACD(cd),2);
END $$
DELIMITER ;

-- Processo que automatiza a criação e inserção de diversas vendas em CD
DROP PROCEDURE IF EXISTS CRIAVENDA;
DELIMITER $$
CREATE PROCEDURE CRIAVENDA()
BEGIN
	DECLARE contador	INT DEFAULT 0; 	-- CONTA CLIENTE
    DECLARE qtdvenda	INT DEFAULT 0;
    DECLARE cliente 	INT DEFAULT 1;
    DECLARE datavenda	DATE;
    
    SET contador = 1;
    SET cliente = 1;
    
    criavenda: LOOP
		-- Loop, com 1000 vendas
		SET qtdvenda = qtdvenda+1;
        IF qtdvenda >= 1000 THEN
			LEAVE criavenda;
		END IF;
        
        SET datavenda = date_add(now(), interval -contador day);
        INSERT INTO venda VALUES (null, datavenda, 0, cliente);
        SET cliente = cliente + 1;
        SET contador = contador + 1;
        
        if contador >= 125 THEN
			SET contador = 1;
		END IF;
        
        IF cliente >= 100 THEN
			SET cliente = 1;
		END IF;
	END LOOP;
END $$
DELIMITER ;

-- Função que retorna nomes dos Autores por cd em uma única string, separados por virgula
DROP FUNCTION IF EXISTS AUTORESCD;
DELIMITER $$
CREATE FUNCTION AUTORESCD (texto VARCHAR(120)) RETURNS VARCHAR(300) DETERMINISTIC
	BEGIN
	-- Usar cursor para resolver	
    RETURN 'AJHHHH';
    END $$
DELIMITER ;

CALL CRIAVENDA(); -- Para utilizar os Triggers abaixo
-- ----------------------------------------------------------
-- Triggers : Acontece quando se insere, altera ou apaga informações em uma tabela
-- ----------------------------------------------------------

-- Trigger após a inserção de um novo item
-- Foi utilzado a ferramenta gráfica do MySQL
DROP TRIGGER IF EXISTS `cd`.`itensvenda_AFTER_INSERT`;
DELIMITER $$
USE `cd`$$
CREATE DEFINER = CURRENT_USER TRIGGER `cd`.`itensvenda_AFTER_INSERT` AFTER INSERT ON `itensvenda` FOR EACH ROW
BEGIN
	-- Atualiza na tabela CD a quantidade, reduzindo a quantidade vendida
	UPDATE cd SET qtde = qtde - NEW.qtde WHERE codcd = NEW.codcd;
END$$
DELIMITER ;


-- Trigger após atualizalção na tabela de itensvenda
DROP TRIGGER IF EXISTS `cd`.`itensvenda_AFTER_UPDATE`;
DELIMITER $$
USE `cd`$$
CREATE DEFINER = CURRENT_USER TRIGGER `cd`.`itensvenda_AFTER_UPDATE` AFTER UPDATE ON `itensvenda` FOR EACH ROW
BEGIN
	-- Atualiza a tabela cd, adicionando o quantidade antiga e removendo a quantidade nova
	UPDATE cd SET qtde = qtde + OLD.qtde - NEW.qtde WHERE codcd = NEW.codcd;
END$$
DELIMITER ;

-- Trigger após a remoção de um registro na tabela itensvenda
DROP TRIGGER IF EXISTS `cd`.`itensvenda_AFTER_DELETE`;
DELIMITER $$
USE `cd`$$
CREATE DEFINER = CURRENT_USER TRIGGER `cd`.`itensvenda_AFTER_DELETE` AFTER DELETE ON `itensvenda` FOR EACH ROW
BEGIN
	-- Adiciona a quantidade antiga ao registro correspondente na tabela cd
	UPDATE cd SET qtde = qtde + OLD.qtde WHERE codcd = OLD.codcd;
END$$
DELIMITER ;

-- Trigger de Inclusão de log, alterações na tabela autor
DROP TRIGGER IF EXISTS `cd`.`autor_AFTER_UPDATE`;

DELIMITER $$
USE `cd`$$
CREATE DEFINER = CURRENT_USER TRIGGER `cd`.`autor_AFTER_UPDATE` AFTER UPDATE ON `autor` FOR EACH ROW
BEGIN
	DECLARE usuario VARCHAR (60);
    SELECT CURRENT_USER() INTO usuario;
    INSERT INTO log VALUES (null, usuario, OLD.nomeaut, NEW.nomeaut);
END$$
DELIMITER ;
