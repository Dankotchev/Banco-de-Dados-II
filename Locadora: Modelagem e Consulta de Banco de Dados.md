# Modelagem e Consulta de Banco de Dados: Locadora

Você foi contemplado com uma locadora de filmes de presente, porem a mesma não tem nenhum tipo de software para controle, utiliza atualmente somente fichas.
Monte uma base de dados que permita a você gerenciar o controle da locadora. A mesma deve conter os filmes, as mídias, quais locações foram feitas por um cliente, quais foram pagas, os gêneros do filmes e reservas de um determinado cliente.
Faça os seguintes relatórios:

- Gere consultas para todos os filmes de um determinado gênero;
- Todos os filmes locados por um determinado cliente;
- Quanto foi pago em locação por um determinado cliente;
- Quanto foi recebido em dinheiro em um determinado dia;
- **Observação:** Defina os atributos necessários para cada entidade de acordo com a sua visão de necessidade.

## Diagrama 

![Diagrama do modelo do banco de dados da locadora](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-05_20-29-50.png)

```sql
DROP DATABASE IF EXISTS `locadora`;
CREATE DATABASE `locadora`;
USE `locadora`;

DROP TABLE IF EXISTS `cliente`;
CREATE TABLE `cliente` (
  `id_cliente` int(11) NOT NULL AUTO_INCREMENT,
  `nome_cliente` varchar(45) DEFAULT NULL,
  `contato_cliente` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `cliente` WRITE;
INSERT INTO `cliente` VALUES (1,'Danilo Quirino','18 981-234-455'),(2,'Daniele Quirino','18 934-000-223'),(3,'Lucas Quirino','18 933-235-643'),(4,'Tereza Quirino','18 944-342-567'),(5,'Arnaldo Jabor','18 934-252-767');
UNLOCK TABLES;

DROP TABLE IF EXISTS `aluguel`;
CREATE TABLE `aluguel` (
  `id_aluguel` int(11) NOT NULL AUTO_INCREMENT,
  `data_locado` date NOT NULL,
  `id_cliente_aluguel` int(11) NOT NULL,
  PRIMARY KEY (`id_aluguel`),
  KEY `fk_aluguel_cliente1_idx` (`id_cliente_aluguel`),
  CONSTRAINT `fk_aluguel_cliente1` FOREIGN KEY (`id_cliente_aluguel`) REFERENCES `cliente` (`id_cliente`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `aluguel` WRITE;
INSERT INTO `aluguel` VALUES (1,'2022-01-01',1),(2,'2022-01-01',3),(3,'2022-01-01',5),(4,'2022-01-03',2),(5,'2022-01-04',4),(6,'2022-01-07',1),(7,'2022-01-08',3),(8,'2022-01-10',3);
UNLOCK TABLES;

DROP TABLE IF EXISTS `caixa`;
CREATE TABLE `caixa` (
  `id_caixa` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente_caixa` int(11) NOT NULL,
  `id_aluguel_caixa` int(11) NOT NULL,
  `valor` decimal(8,2) DEFAULT NULL,
  `data_pgto` date NOT NULL,
  `forma_pgto` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id_caixa`,`data_pgto`),
  KEY `fk_caixa_cliente1_idx` (`id_cliente_caixa`),
  KEY `fk_caixa_aluguel1_idx` (`id_aluguel_caixa`),
  CONSTRAINT `fk_caixa_aluguel1` FOREIGN KEY (`id_aluguel_caixa`) REFERENCES `aluguel` (`id_aluguel`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_caixa_cliente1` FOREIGN KEY (`id_cliente_caixa`) REFERENCES `cliente` (`id_cliente`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `caixa` WRITE;
INSERT INTO `caixa` VALUES (1,1,1,25.70,'2022-01-08','dinheiro'),(2,3,2,13.50,'2022-01-08','dinheiro'),(3,5,3,33.80,'2022-01-08','pix'),(4,2,4,12.90,'2022-01-04','c credito'),(5,5,5,14.90,'2022-01-06','pix'),(6,1,6,39.20,'2022-01-12','dinheiro'),(7,3,7,10.00,'2022-01-10','dinheiro'),(8,3,8,14.50,'2022-01-18','pix');
UNLOCK TABLES;

DROP TABLE IF EXISTS `filme`;
CREATE TABLE `filme` (
  `id_filme` int(11) NOT NULL AUTO_INCREMENT,
  `titulo_filme` varchar(45) NOT NULL,
  `genero_filme` varchar(45) DEFAULT NULL,
  `quantidade_disponivel` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_filme`),
  UNIQUE KEY `titulo_obra_UNIQUE` (`titulo_filme`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `filme` WRITE;
INSERT INTO `filme` VALUES (1,'Um Espião e Meio','Ação',4),(4,'Benedetta','Drama',1),(5,'Tico e Teco: Defensores da Lei','Animação',3),(6,'007: Contra o Satânico Dr. No','Ação',4),(7,'Encanto','Animação',4),(8,'Desconhecido','Ação',2),(9,'O Esquadrão Suicida','Ação',1),(10,'Jungle Cruise','Aventura',1),(11,'Em um Bairro de Nova York','Musical',2),(12,'Scott Pilgrim Contra o Mundo','Comédia',5),(13,'Hamilton','Musical',2),(14,'Como Treinar o Seu Dragão','Animação',5);
UNLOCK TABLES;

DROP TABLE IF EXISTS `midia`;
CREATE TABLE `midia` (
  `id_midia` int(11) NOT NULL AUTO_INCREMENT,
  `id_filme_midia` int(11) NOT NULL,
  `disponibilidade` tinyint(4) DEFAULT 1,
  PRIMARY KEY (`id_midia`),
  KEY `fk_acervo_obras_idx` (`id_filme_midia`),
  CONSTRAINT `fk_acervo_obras` FOREIGN KEY (`id_filme_midia`) REFERENCES `filme` (`id_filme`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `midia` WRITE;
INSERT INTO `midia` VALUES (1,1,1),(2,1,1),(3,1,1),(4,1,1),(5,4,1),(6,5,1),(7,5,1),(8,5,1),(9,6,1),(10,6,1),(11,6,1),(12,6,1),(13,7,1),(14,7,1),(15,7,1),(16,7,1),(17,8,1),(18,8,1),(19,9,1),(20,10,1),(21,11,1),(22,11,1),(23,12,1),(24,12,1),(25,12,1),(26,12,1),(27,12,1),(28,13,1),(29,13,1),(30,14,1),(31,14,1),(32,14,1),(33,14,1),(34,14,1);
UNLOCK TABLES;

DROP TABLE IF EXISTS `midia_alugada`;
CREATE TABLE `midia_alugada` (
  `id_midia_alugada` int(11) NOT NULL AUTO_INCREMENT,
  `id_aluguel_ma` int(11) NOT NULL,
  `id_midia_ma` int(11) NOT NULL,
  PRIMARY KEY (`id_midia_alugada`),
  KEY `fk_midia_alugada_aluguel_idx` (`id_aluguel_ma`),
  KEY `fk_midia_alugada_midia1_idx` (`id_midia_ma`),
  CONSTRAINT `fk_midia_alugada_aluguel` FOREIGN KEY (`id_aluguel_ma`) REFERENCES `aluguel` (`id_aluguel`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_midia_alugada_midia1` FOREIGN KEY (`id_midia_ma`) REFERENCES `midia` (`id_midia`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4;

LOCK TABLES `midia_alugada` WRITE;
INSERT INTO `midia_alugada` VALUES (1,1,1),(2,1,21),(3,1,6),(4,2,10),(5,2,8),(6,3,9),(7,3,5),(8,4,2),(9,4,13),(10,5,34),(11,5,7),(12,6,16),(13,6,19),(14,7,21),(15,7,15),(16,8,31),(17,8,20);
UNLOCK TABLES;

DROP TABLE IF EXISTS `reserva`;
CREATE TABLE `reserva` (
  `reserva_ativa` tinyint(4) NOT NULL,
  `id_reserva` int(11) NOT NULL AUTO_INCREMENT,
  `id_cliente_reserva` int(11) NOT NULL,
  `id_filme_reserva` int(11) NOT NULL,
  PRIMARY KEY (`id_reserva`,`id_cliente_reserva`),
  KEY `fk_reserva_obra1_idx` (`id_filme_reserva`),
  KEY `fk_reserva_cliente1_idx` (`id_cliente_reserva`),
  CONSTRAINT `fk_reserva_cliente1` FOREIGN KEY (`id_cliente_reserva`) REFERENCES `cliente` (`id_cliente`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_reserva_obra1` FOREIGN KEY (`id_filme_reserva`) REFERENCES `filme` (`id_filme`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

## Consultas ao banco

1. Gere consultas para todos os filmes de um determinado gênero;

   ```sql
   SELECT * FROM filme
   	WHERE genero_filme = "Ação";
   ```

   ![Consulta e Resultado](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-05_19-24-28.png)

2. Todos os filmes locados por um determinado cliente;

   ```sql
   SELECT titulo_filme, nome_cliente, id_midia "exemplar" FROM midia_alugada
   	JOIN aluguel ON (id_aluguel_ma = id_aluguel)
       JOIN cliente ON (id_cliente_aluguel = id_cliente)
       JOIN midia ON (id_midia_ma = id_midia)
       JOIN filme ON (id_filme_midia = id_filme)
       WHERE id_cliente = 1;
   ```

   ![Consulta e Resultado](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-05_19-34-08.png)

3. Quanto foi pago em locação por um determinado cliente;

   ```sql
   SELECT nome_cliente, SUM(valor) AS total FROM caixa
   	JOIN cliente ON (id_cliente_caixa = id_cliente)
       WHERE id_cliente = 2
       GROUP BY id_cliente;
   ```

   ![Consulta e Resultado](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-05_19-41-02.png)

4. Quanto foi recebido em dinheiro em um determinado dia;

   ```sql
   SELECT data_pgto, SUM(valor) AS total FROM caixa
       WHERE forma_pgto = "dinheiro"
   		AND data_pgto = "2022-01-08";
   ```
   
   ![Consulta e Resultado](/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-05_19-43-42.png)