SET search_path TO professores;

INSERT INTO professores (nome) VALUES
('Vilson'), ('Ricardo F'), ('Andrea'), ('Melissa'), ('Paulo Rosa');

INSERT INTO integrado VALUES
(1, 'INT-1', 'Introdução à Informática', 2, 2, 'Andrea', 'Melissa'),
(1, 'ALP-1', 'Algoritmos e Programação', 4, 2, 'Vilson', 'Ricardo F');

INSERT INTO bcc VALUES
(1, 'IMPAR', 'ADMC1', 'Administração Geral', 'Administração', 2, 1, 'Paulo Rosa', null),
(1, 'IMPAR', 'AP1C1', 'Algoritmos e Programação I', 'Informática', 4, 2, 'Melissa', 'Ricardo F');

INSERT INTO outros VALUES 
('IMPAR', 'INFE1', 'Informática', 'Eletrotécnica', 2, 2, 'Ricardo F', 'Melissa');

SELECT * FROM professor;
SELECT * FROM integrado;
SELECT * FROM bcc;
SELECT * FROM outros;

-- Insersão de aulas com professores que não estão cadastrados ainda
INSERT INTO integrado VALUES
(1, 'xxx-1', 'Disciplina x1', 2, 1, 'Cláudio', null),
(2, 'xxx-2', 'Disciplina x2', 4, 2, 'César', 'Bruno');

INSERT INTO bcc VALUES
(1, 'IMPAR', 'ICCC1', 'Introdução a Ciência da Computação', 'Informática', 2, 1, 'Kleber', null),
(1, 'PAR', 'AP2C2', 'Algoritmos e Programação II', 'Informática', 4, 2, 'Andre', 'Ricardo S');

INSERT INTO outros VALUES 
('PAR', 'IFAC1', 'Introdução a Informática', 'Edificações', 2, 2, 'Donizete', 'Davi');

SELECT * FROM professor;
SELECT * FROM integrado;
SELECT * FROM bcc;
SELECT * FROM outros;

-- Alterando disciplinas com professores cadastrados
UPDATE integrado SET prof1 = 'Paulo Rosa', prof2 = 'Vilson' WHERE sigla = 'INT-1';
UPDATE bcc SET prof1 = 'Cláudio' WHERE sigla = 'ICCC1';
UPDATE outros SET prof2 = 'Andre' WHERE sigla = 'IFAC1';

SELECT * FROM professor;
SELECT * FROM integrado;
SELECT * FROM bcc;
SELECT * FROM outros;

-- Excluindo 
DELETE FROM integrado WHERE sigla = 'ALP-1';
DELETE FROM bcc WHERE sigla = 'ICCC1';
DELETE FROM outros WHERE sigla = 'INFE1';
