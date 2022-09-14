# Revisão de SQL: Consulta na base de dados de CD

### Para cada solicitação, criar duas query, uma podendo utilizar JOIN e outra sem o uso de JOIN

1. Os 5 autores com a maior quantidade de musicas. 

   ```sql
   SELECT a.nomeaut, COUNT(*) AS qtd FROM musicaautor ma
   	JOIN autor a on (a.codaut = ma.codaut)
       JOIN musica m on (ma.codmus = m.codmus)
       GROUP BY a.codaut
       ORDER BY qtd DESC
       LIMIT 5;
       
   -- ------------------------------------
   
   SELECT a.nomeaut, COUNT(*) AS qtd
   	FROM musicaautor ma, autor a , musica m
       WHERE (ma.codaut = a.codaut) AND (ma.codmus = m.codmus)
       GROUP BY a.codaut
       ORDER BY qtd DESC
       LIMIT 5;
   ```

2. A somatória da duração das musica de cada CD, mostre o nome do CD e a DURACAO.

   ```sql
   SELECT c.nomecd, COUNT(m.duracao) as duracao_total FROM faixa f
   	JOIN cd c ON (f.codcd = c.codcd)
       JOIN musica m ON (f.codmus = m.codmus)
       GROUP BY c.codcd;  
       
   -- ------------------------------------
     
   SELECT c.nomecd, COUNT(m.duracao) AS duracao_total
   	FROM faixa f, cd c, musica m
       WHERE (f.codcd = c.codcd) AND (f.codmus = m.codmus)
       GROUP BY c.codcd;
   ```

3. Mostrar todas as durações que possuem mais de 3 musicas.

   ```sql
   SELECT duracao, COUNT(*) AS qtd
   	FROM musica
       WHERE qtd > 3
       GROUP BY duracao;
   ```

### Faça da melhor forma possivel as seguintes queries

1. Crie uma query que mostre o nome do autor, nome da musica e nome do CD ordenado pelo nome do autor.

   ```sql
   CREATE VIEW autor_cd AS
   	SELECT a.nomeaut, m.nomemus, c.nomecd
   		FROM cd c
   			JOIN faixa f ON (c.codcd = f.codcd)
   			JOIN musica m ON (f.codmus = m.codmus)
   			JOIN musicaautor ma ON (m.codmus = ma.codmus)
   			JOIN autor a ON (ma.codaut = a.codaut)
   		ORDER BY a.nomeaut ASC;
   
   SELECT * FROM autor_cd;
   ```

2. Quais CDs e preços dos mesmos que estão sendo vendido acima da media de preços.

   ```sql
   SELECT c.nomecd, c.preco FROM cd c
   	WHERE c.preco > (SELECT AVG(c.preco) FROM cd c);
   ```

3. Qual a media de preços por gravadora.

   ```sql
   SELECT g.nomegrav, AVG(c.preco)
   	FROM gravadora g 
   		JOIN cd c ON (g.codgrav = c.codgrav)
   	GROUP BY g.codgrav;
   ```

4. Qual gravadora possui o CD mais caro.

   ```SQL
   SELECT g.nomegrav, MAX(c.preco)
   	FROM gravadora g JOIN cd c ON (g.codgrav = c.codgrav)
       GROUP BY g.codgrav
       LIMIT 1;
   ```

5. Sabendo-se que cada CD tem um preco e uma quantidade de musica, calcule quanto custa cada musica no CD em seguida verique qual o autor recebeu mais, somando-se as musicas de cada CD que ele aparece. Coloque o nome do autor e o total em ordem decrescente de valor.

   ```SQL
   -- Obter uma tabela que relacione CDs e seus valores por faixa
   DROP VIEW IF EXISTS valor_por_faixa;
   CREATE VIEW valor_por_faixa AS
   	SELECT c.codcd, (c.preco / COUNT(f.codcd)) AS valor_faixa
   		FROM cd c JOIN faixa f ON (c.codcd = f.codcd)
           GROUP BY c.codcd;
           
   SELECT * FROM valor_por_faixa;
           
   -- Tentativa 1 de obter algo parecido com o numeros de faixa de cada autor em cada CD
   DROP VIEW IF EXISTS autores_faixa_cd;
   CREATE VIEW autores_faixa_cd AS
   	SELECT a.codaut, COUNT(*) AS qtd_faixa, c.codcd
   		FROM musicaautor ma
   			JOIN autor a ON (ma.codaut = a.codaut)
               JOIN musica m ON (ma.codmus = m.codmus)
               JOIN faixa f ON (m.codmus = f.codmus), cd c;
   
   -- Tentativa 2 de obter algo parecido com o numeros de faixa de cada autor em cada CD
   DROP VIEW IF EXISTS autores_faixa;
   CREATE VIEW autores_faixa AS
   	SELECT distinct a.codaut, f.codcd, COUNT(*) AS qtd_faixa
   		FROM musicaautor ma
   			JOIN autor a ON (ma.codaut = a.codaut)
               JOIN musica m ON (ma.codmus = m.codmus)
               JOIN faixa f ON (m.codmus = f.codmus);
               
   SELECT * FROM autores_faixa;
   
   -- Iria existir algo que ligasse as duas primeira visões, resultando em uma tabela que teria como atributos o autor, o cd, e o faturamento naquele cd
   -- Se a visão autores_faixa funcionar, essa visão vai calcular o faturamento de cada autor
   DROP VIEW IF EXISTS autor_faturamento;
   CREATE VIEW autor_faturamento AS
   	SELECT a.codaut, SUM((af.qtd_faixa * vf.valor_faixa)) AS faturamento_autor
   		FROM autor a JOIN autores_faixa af ON (a.codaut = af.codaut),
   			cd c JOIN valor_por_faixa vf ON (c.codcd = vf.codcd)
   		GROUP BY a.codaut;
       
   -- Apresentar o nome do autor e seu faturamento   
   SELECT a.nomeaut, f.faturamento_autor
   	FROM autor a
   		JOIN autor_faturamento f ON (a.codaut = f.codaut)
       ORDER BY f.faturamento_autor DESC;
   
   ```
   
   
