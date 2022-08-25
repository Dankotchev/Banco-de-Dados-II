DROP FUNCTION IF EXISTS RETORNANOME;
DELIMITER $$
CREATE FUNCTION RETORNANOME(posicao int, texto varchar(100)) RETURNS VARCHAR(100) DETERMINISTIC
BEGIN 
    DECLARE achou INT DEFAULT 0;
    DECLARE palavra varchar(30);
    DECLARE conta int default 0;
    DECLARE acheiem int default 0;

    set texto = concat(texto," ");
    set conta = 1;
    while achou = 0 do 
        set acheiem = locate(" ",texto);
        if acheiem <> 0 then
           if conta = posicao then 
              set palavra = substring(texto,1,acheiem); 
              set achou = 1;
		   end if;   
           set texto = substring(texto,acheiem+1,length(texto));
        else
           set achou = 1;
        end if;
        set conta=conta+1;
    end while;
    return palavra;
END $$
DELIMITER ;

DROP FUNCTION CONTALETRA;
DELIMITER $$
CREATE FUNCTION CONTALETRA (letra char, texto varchar(120))
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE tamanho INT DEFAULT 0;
    SET letra = UPPER(letra);
    SET texto = UPPER(texto);
    SET tamanho = LENGTH(texto) - LENGTH(REPLACE(texto, letra, ''));
    RETURN tamanho;
END $$
DELIMITER ;

DROP FUNCTION ABREVIANOME;
DELIMITER $$
CREATE FUNCTION ABREVIANOME (texto VARCHAR (120))
RETURNS VARCHAR (120) DETERMINISTIC
BEGIN
	
END $$
DELIMITER ;


SELECT RETORNANOME (2, "DANILO DOMINGUES QUIRINO") AS NOME;
SELECT CONTALETRA("D", "DANILO DOMINGUES QUIRINO") AS QTD;
SELECT ABREVIANOME("DANILO DOMINGUES QUIRINO") AS ABREVIADO;