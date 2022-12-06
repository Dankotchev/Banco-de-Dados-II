SET search_path TO correcaoprovabim1;
-- inclusão inicial		

INSERT INTO curso (nome_curso, total_horas, valor_curso)
	VALUES ('curso 1', 300, 2000), ('curso 2', 250, 1350);
INSERT INTO turma (curso_idcurso) VALUES (1), (2), (1);
INSERT INTO materia (nome, carga_horaria)
	VALUES ('materia 1', 60), ('materia 2', 60), ('materia 3', 80);
INSERT INTO curso_tem_materia VALUES (1,1), (1,3), (2,2), (2,3);
INSERT INTO participante (cpf, nome)
	VALUES ('123.456.789-00', 'Participante 1'), ('123.258.789-00', 'Participante 2'),
	('000.456.789-00', 'Participante 3'), ('658.999.789-00', 'Participante 4');
INSERT INTO matricula (participante_idparticipante, turma_idturma, parcelas, situacao)
	VALUES (1, 1, 3, 'P'), (2, 2, 6, 'P'), (3, 1, 3, 'P');
INSERT INTO caixa VALUES ('2022-10-05'), ('2022-10-04');
INSERT INTO gastos (turma_idturma, descricao, valor, caixa_data_gasto)
	VALUES (1, 'gasto 1', 600, '2022-10-04'), (2, 'gasto 1', 700, '2022-10-04'),
	(3, 'gasto 1', 1000, '2022-10-04');

SELECT * FROM MATRICULA;
UPDATE MATRICULA SET SITUACAO = 'A' WHERE SITUACAO = 'P';
select * from pagamentos;
SELECT * FROM notas;

SELECT * FROM view_turmas;


update notas set nota1 = 2, nota2 =3, nota3 = 4, nota4 = 5 where matricula_idmatricula =1 and materia_idmateria = 1;
update notas set nota1 = 2, nota2 =3, nota3 = 4, nota4 = 5 where matricula_idmatricula =1 and materia_idmateria = 2;

SELECT * FROM view_aluno_aprovacao;

delete from matricula where idmatricula = 1;
select * from matricula;
select * from pagamentos;
select * from notas where matricula_idmatricula = 1;

