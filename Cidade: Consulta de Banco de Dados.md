# Consulta de Banco de Dados: Cidade

1. Total de cidades do estado de Santa Catariana:

   ```sql
   SELECT COUNT(*) AS "Total de Municipios"
   	FROM cidade
       WHERE estado = "SC";
   ```

   ![Resultado da Consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_15-16-18.png)

2. Total de cidades por estado em ordem crescente de estado:

   ```sql
   SELECT COUNT(*) AS "Total de Municipios", estado AS "UF"
   	FROM cidade
       GROUP BY estado
       ORDER BY estado ASC;
   ```
   
   ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_15-21-12.png)

3. As 5 cidades mais populosas:

   ```sql
   SELECT populacao, municipio, estado
   	FROM cidade
       ORDER BY populacao DESC
       LIMIT 5;
   ```

   ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_15-25-59.png)

4. Os 5 estados com mais cidades:

   ```sql
   SELECT COUNT(*) AS total_cidades, estado
   	FROM cidade
       GROUP BY estado
       ORDER BY total_cidades DESC
       LIMIT 5;
   ```
   

![Resuldado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_15-29-43.png)

5. Os 5 estados mais populosos:

   ```sql
   SELECT SUM(populacao) AS populacao_total, estado
   	FROM cidade
       GROUP BY estado
       ORDER BY populacao_total DESC
       LIMIT 5;
   ```

   ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_15-32-11.png)

6. A média da população de homens e mulheres por estado:

   ```sql
   SELECT AVG(pctHomem) AS pctMediaHomens, AVG(pctMulher) AS pctMediaMulheres, estado
   	FROM cidade
       GROUP BY estado;
   ```

   ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_16-19-56.png)

7. Soma da população, média de homens e mulheres por estado dos 10 primeiros registros:

   ```sql
   SELECT SUM(populacao) AS populacao_total, AVG(pctHomem) AS pctMediaHomens, AVG(pctMulher) AS pctMediaMulheres, estado
   	FROM cidade
       GROUP BY estado
       LIMIT 10;
   ```

   ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_16-18-53.png)

8. Todos os estados em que a média do percentual de mulheres é acima de 50%:

   ```sql
   SELECT AVG(pctMulher) AS pctMediaMulheres, estado
   	FROM cidade
       GROUP BY estado
   		HAVING  pctMediaMulheres > 50;
   ```

   ![Resulado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_16-17-42.png)

9. Os estados em que o percentual de mulheres e maior que o percentual de homens:

   ```sql
   SELECT AVG(pctHomem) AS pctMediaHomens, AVG(pctMulher) AS pctMediaMulheres, estado
   	FROM cidade
       GROUP BY estado
       HAVING pctMediaMulheres > pctMediaHomens;
   ```

   ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_16-23-38.png)

10. A cidade com maior percentual de mulheres:

    ```sql
    SELECT pctMulher, municipio, estado
    	FROM cidade
        GROUP BY codigo
        ORDER BY pctMulher DESC
        LIMIT 1;
    ```

    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-06-27.png)

11. A cidade com menor percentual de mulheres e a diferença de percentual em relação aos homens:

    ```sql
    SELECT pctMulher, (pctHomem - pctMulher) as diferanca, municipio, estado
    	FROM cidade
        GROUP BY codigo
        ORDER BY pctMulher ASC
        LIMIT 1;
    ```

    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-08-37.png)

12. A cidade com a menor população por estado:

    ```sql
    SELECT estado, MIN(populacao) AS populacao, 
    		(SELECT municipio
    			FROM cidade
                WHERE (populacao = MIN(c.populacao)) AND (estado = c.estado)
    		) AS municipio
        FROM cidade c
        GROUP BY estado;
    ```

    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-14-55.png)

13. As cinco maiores cidades sendo uma de cada estado com a maior população:

    ```sql
    SELECT estado, MAX(populacao) AS populacao, 
    		(SELECT municipio
    			FROM cidade
                WHERE (populacao = MAX(c.populacao)) AND (estado = c.estado)
    		) AS municipio
        FROM cidade c
        GROUP BY estado
        ORDER BY populacao DESC
        LIMIT 5;
    ```

    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-19-13.png)

14. A quantidade de homens e mulheres por estado:

    ```sql
    SELECT SUM(populacao *pctHomem/100) AS "População de Homens",
    		SUM(populacao *pctMulher/100) AS "População de Mulheres", estado
    	FROM cidade
        GROUP BY estado;
    ```

    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-21-15.png)

15. A somatória da população pela inicial da cidade A, B, C, D:

    ```sql
    SELECT LEFT (municipio, 1) AS "Inicial", SUM(populacao) AS "População Total"
    	FROM cidade
    	GROUP BY LEFT (municipio,1)
        LIMIT 4;
    ```

    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-24-07.png)

16. A somatória da população por estado, somente para as cidades onde o percentual de homens é maior do que o percentual de mulheres:

    ```sql
    SELECT SUM(populacao) AS "Soma", estado 
    	FROM cidade
        WHERE pctHomem > pctMulher
        GROUP BY estado;
    ```
    
    ![Resultado da consulta](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-11_22-25-49.png)