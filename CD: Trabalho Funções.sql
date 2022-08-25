USE cd;
-- DANILO DOMINGUES QUIRINO :: PE3008835
-- 1) abntextendido – Recebendo um nome retorna ele no formato ABNT Nome inteiro
DROP FUNCTION IF EXISTS ABNTEXTENDIDO;
DELIMITER $$
CREATE FUNCTION ABNTEXTENDIDO (texto VARCHAR (255)) RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
	DECLARE ultimoNome 	VARCHAR (255);
    DECLARE parteNome 	VARCHAR (255);
    
    SET ultimoNome = UPPER(SUBSTRING_INDEX(texto, ' ', -1));					-- Retirando o último nome
    SET parteNome = REPLACE(texto, substring_index(texto, ' ', -1), '');		-- Todo o restante do nome
    SET ultimoNome = CONCAT(ultimoNome, ', ', parteNome);
    RETURN ultimoNome;
END $$
DELIMITER ;

-- Teste:
SELECT ABNTEXTENDIDO("Afonso da Silva dos Alves de Santana Paraiba") AS ABNT_EXTENDIDO;
-- -----------------------------------------------------------------------------------

-- 2) abnt – Recebendo um nome retorna ele no formato ABNT nome abreviado
DROP FUNCTION IF EXISTS ABNT;
DELIMITER $$
CREATE FUNCTION ABNT (texto VARCHAR (255)) RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
	DECLARE ultimoNome 		VARCHAR (255);
    DECLARE primeiroNome 	VARCHAR (255);
    DECLARE meioNome 		VARCHAR (255);
    DECLARE aux 			VARCHAR (255);
    
    SET ultimoNome = UPPER(SUBSTRING_INDEX(texto, ' ', -1));							-- Reservo a info do último nome
    SET primeiroNome = CONCAT(SUBSTRING(SUBSTRING_INDEX(texto, ' ', 1), 1, 1), '. ');	-- Pego o primeiro nome e reduzo para uma letra e concat com '. '
    SET meioNome = REPLACE(texto, SUBSTRING_INDEX(texto, ' ', -1), ''); 				-- Coloco no meioNome o texto retirando o último nome
    SET meioNome = REPLACE(meioNome, SUBSTRING_INDEX(texto, ' ', 1), '');				-- Coloco no meioNome, removendo também o primeiro nome
    SET meioNome = INSERT(meioNome, LENGTH(meioNome), 1, '');							-- Remove o último caracter que é um ' '
    
    SET ultimoNome = CONCAT(ultimoNome, ', ', primeiroNome); 							-- ULTIMONOME, P.
    
	WHILE LENGTH(meioNome) > 1 DO										-- Enquanto houver caracteres dentro da string de nome     
        SET meioNome = SUBSTRING(meioNome, 2, LENGTH(meioNome));		-- Remover o ' ' que fica na primeira posição
		
        SET aux = SUBSTRING_INDEX(meioNome, ' ', 1);					-- Primeiro nome dentre os nomes do meio			
		IF (UPPER(aux) LIKE 'D_') OR (UPPER(aux) LIKE 'D_S') THEN		-- Verifica se é um dos artigos "DA, DE, DO, DAS, DOS"
			 SET aux = CONCAT(aux, ' ');
		ELSE
			SET aux = CONCAT(SUBSTRING(aux, 1, 1), '. ');				-- Se não for, abrevia o nome
       END IF;
    
		SET meioNome = REPLACE(meioNome, SUBSTRING_INDEX(meioNome, ' ', 1), '');		-- Removendo o primeiro nome dos nomes do meio
        
		SET ultimoNome = CONCAT(ultimoNome, aux);										-- ULTIMONOME, P. A. ...
    END WHILE;

    RETURN ultimoNome;
END $$
DELIMITER ;

-- Teste:
SELECT ABNT("Afonso da Silva dos Alves de Santana") AS ABNT;
-- -----------------------------------------------------------------------------------

-- 3) abrevia – Recebendo um nome retorna o nome abreviado
DROP FUNCTION IF EXISTS ABREVIA;
DELIMITER $$
CREATE FUNCTION ABREVIA (texto VARCHAR (255)) RETURNS VARCHAR (255) DETERMINISTIC
BEGIN
	DECLARE ultimoNome 		VARCHAR (255);
    DECLARE primeiroNome 	VARCHAR (255);
    DECLARE meioNome 		VARCHAR (255);
    DECLARE aux 			VARCHAR (255);
    
    SET ultimoNome = SUBSTRING_INDEX(texto, ' ', -1);				-- Reservo a info do último nome
    SET primeiroNome = SUBSTRING_INDEX(texto, ' ', 1);				-- Pego o primeiro nome
    SET meioNome = REPLACE(texto, ultimoNome, ''); 					-- Coloco no meioNome o texto retirando o último nome
    SET meioNome = REPLACE(meioNome, primeiroNome, '');				-- Coloco no meioNome, removendo também o primeiro nome
    SET meioNome = INSERT(meioNome, LENGTH(meioNome), 1, '');		-- Remove o último caracter que é um ' '
    
    SET primeiroNome = CONCAT(primeiroNome, ' ');
    
	WHILE LENGTH(meioNome) > 0 DO														-- Enquanto houver caracteres dentro da string de nome
		SET meioNome = SUBSTRING(meioNome, 2, LENGTH(meioNome));						-- Remover o ' ' que fica na primeira posição
		
        SET aux = SUBSTRING_INDEX(meioNome, ' ', 1);			-- Primeiro nome dentre os nomes do meio			
		IF (UPPER(aux) LIKE 'D_') OR (UPPER(aux) LIKE 'D_S') THEN		-- Verifica se não é um dos artigos "DA, DE, DO, DAS, DOS"
			 SET aux = CONCAT (aux, ' ');
		ELSE
			SET aux = CONCAT(SUBSTRING(aux, 1, 1), '. ');		-- Se não for, abrevia o nome
       END IF;
        
		SET meioNome = REPLACE(meioNome, SUBSTRING_INDEX(meioNome, ' ', 1), '');		-- Removendo o primeiro nome dos nomes do meio

		SET primeiroNome = CONCAT(primeiroNome, aux);										-- PrimeiroNome A. ...
    END WHILE;

	SET primeiroNome = CONCAT(primeiroNome, ultimoNome);	-- PrimeiroNome A. ... UltimoNome
    RETURN primeiroNome;
END $$
DELIMITER ;

-- Teste:
SELECT ABREVIA("Afonso da Silva dos Alves de Santana Paraiba") AS NOME_ABREVIADO;
-- -----------------------------------------------------------------------------------

-- 4) retornanome – Recebendo uma posição e um nome, retorne a palavra correspondente a posição informada.
DROP FUNCTION IF EXISTS RETORNANOME;
DELIMITER $$
CREATE FUNCTION RETORNANOME (busca INT, texto VARCHAR(100)) RETURNS VARCHAR (40) DETERMINISTIC
BEGIN 
    DECLARE achou 	INT DEFAULT FALSE;
    DECLARE palavra VARCHAR(40);		-- Nome a ser retornado
    DECLARE conta 	INT DEFAULT 0;		-- Auxiliar na busca do nome desejado
    DECLARE posicao INT DEFAULT 0;		-- Posição dos ' ' dentro da string

    SET texto = CONCAT(texto,' ');
    SET conta = 1;
    WHILE achou = FALSE DO 
        SET posicao = LOCATE(' ',texto);
        
		IF posicao <> 0 THEN 			-- Se não for o ínicio da string
        
           IF conta = busca THEN		-- Posição buscada é igual a posição do ' ' encontrado
              SET palavra = SUBSTRING(texto, 1, posicao);	-- Retorna a substring entre a posição 1 e a posição encontrada
              set achou = TRUE;
		   END IF;
           SET texto = SUBSTRING(texto, posicao + 1, LENGTH((texto))); -- Retira do texto a parte não desejada
           
        ELSE
           SET achou = TRUE; -- Se não houver mais nomes, TRUE para sair
           SET palavra = 'Posição maior que a quantidade nomes.';
        END IF;
        
        SET conta = conta + 1;
	END WHILE;

    RETURN palavra;
END $$
DELIMITER ;

-- Teste:
SELECT RETORNANOME (4, "Afonso da Silva dos Alves de Santana Paraiba") AS NOME;
-- -----------------------------------------------------------------------------------

-- 5) contavogais – Recebendo um texto retorne a quantidade de vogais no texto.
DROP FUNCTION IF EXISTS CONTAVOGAL;
DELIMITER $$
CREATE FUNCTION CONTAVOGAL (texto VARCHAR(120)) RETURNS INT DETERMINISTIC
BEGIN
    DECLARE tamanho 		INT DEFAULT 0;
    DECLARE intermediario 	VARCHAR(120);
    
    SET texto = UPPER(texto);
    SET intermediario = (REPLACE(texto, 'A', ''));
    SET intermediario = (REPLACE(intermediario, 'E', ''));
    SET intermediario = (REPLACE(intermediario, 'I', ''));
    SET intermediario = (REPLACE(intermediario, 'O', ''));
    SET intermediario = (REPLACE(intermediario, 'U', ''));
    SET intermediario = (REPLACE(intermediario, 'U', ''));
    SET tamanho = LENGTH(texto) - LENGTH(intermediario);
    RETURN tamanho;
END $$
DELIMITER ;

-- Teste:
SELECT CONTAVOGAL("DANILO DOMINGUES QUIRINO") AS QTD_VOGAL;
-- -----------------------------------------------------------------------------------

-- 6) retornaautores – Uma função no banco de dados CD que ao receber o código de uma música mostre
-- Todos os autores dela em formato de uma STRING em letra MAIUSCULA
DROP FUNCTION IF EXISTS RETORNARAUTORES;
DELIMITER $$
CREATE FUNCTION RETORNARAUTORES (codigo INT) RETURNS VARCHAR(255) DETERMINISTIC
BEGIN
	DECLARE todosAutores 	VARCHAR(255);
    DECLARE auxiliar 		VARCHAR (100);
    DECLARE feito 			INT DEFAULT FALSE;
    
    DECLARE cur CURSOR FOR SELECT	a.nomeaut 	FROM musica m
												JOIN musicaautor ma ON (ma.codmus = m.codmus)
												JOIN autor a ON (ma.codaut = a.codaut)
							WHERE codigo = m.codmus;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET feito = TRUE;
    OPEN cur;
    
    SET todosAutores = '';
	lista: LOOP
		FETCH FROM cur INTO auxiliar;
		IF feito THEN LEAVE lista;
        END IF;
        SET todosAutores = CONCAT(auxiliar, ', ', todosAutores);
        END LOOP;
    
    CLOSE cur;
    
	RETURN UPPER(todosAutores);
END $$
DELIMITER ;

-- Teste:
SELECT RETORNARAUTORES(20) AS "AUTOR(ES)";
-- -----------------------------------------------------------------------------------