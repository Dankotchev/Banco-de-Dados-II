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

<img src="/home/daniloquirino/Imagens/ScreenShots/screenshot_2022-08-09_14-36-58.png" alt="Diagrama do modelo do banco de dados da locadora" style="zoom:200%;" />

```sql

DROP DATABASE IF EXISTS `locadora`;
CREATE DATABASE IF NOT EXISTS `locadora` DEFAULT CHARACTER SET utf8mb4 ;
USE `locadora` ;

CREATE TABLE IF NOT EXISTS `locadora`.`cliente` (
  `id_cliente` INT(11) NOT NULL AUTO_INCREMENT,
  `nome_cliente` VARCHAR(45) NULL DEFAULT NULL,
  `contato_cliente` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id_cliente`))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS `locadora`.`genero` (
  `id_genero` INT NOT NULL AUTO_INCREMENT,
  `descricao_genero` VARCHAR(45) NULL,
  PRIMARY KEY (`id_genero`),
  UNIQUE INDEX `descricao_genero_UNIQUE` (`descricao_genero` ASC) )
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `locadora`.`filme` (
  `id_filme` INT(11) NOT NULL AUTO_INCREMENT,
  `titulo_filme` VARCHAR(45) NOT NULL,
  `id_genero_filme` INT NOT NULL,
  `qtd_disp_filme` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id_filme`),
  UNIQUE INDEX `titulo_obra_UNIQUE` (`titulo_filme` ASC),
  INDEX `fk_filme_genero1_idx` (`id_genero_filme` ASC),
  CONSTRAINT `fk_filme_genero1`
    FOREIGN KEY (`id_genero_filme`)
    REFERENCES `locadora`.`genero` (`id_genero`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS `locadora`.`midia` (
  `id_midia` INT(11) NOT NULL AUTO_INCREMENT,
  `id_filme_midia` INT(11) NOT NULL,
  `disponibilidade` TINYINT(4) NULL DEFAULT 1,
  PRIMARY KEY (`id_midia`),
  INDEX `fk_acervo_obras_idx` (`id_filme_midia` ASC),
  CONSTRAINT `fk_acervo_obras`
    FOREIGN KEY (`id_filme_midia`)
    REFERENCES `locadora`.`filme` (`id_filme`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 35
DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS `locadora`.`midia_alugada` (
  `id_midia_alugada` INT(11) NOT NULL AUTO_INCREMENT,
  `id_midia_ma` INT(11) NOT NULL,
  PRIMARY KEY (`id_midia_alugada`),
  INDEX `fk_midia_alugada_midia1_idx` (`id_midia_ma` ASC),
  CONSTRAINT `fk_midia_alugada_midia1`
    FOREIGN KEY (`id_midia_ma`)
    REFERENCES `locadora`.`midia` (`id_midia`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 18
DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS `locadora`.`aluguel` (
  `id_aluguel` INT(11) NOT NULL AUTO_INCREMENT,
  `id_ma_aluguel` INT(11) NOT NULL,
  `data_locado` DATE NOT NULL,
  `id_cliente_aluguel` INT(11) NOT NULL,
  PRIMARY KEY (`id_aluguel`),
  INDEX `fk_aluguel_cliente1_idx` (`id_cliente_aluguel` ASC),
  INDEX `fk_aluguel_midia_alugada1_idx` (`id_ma_aluguel` ASC),
  CONSTRAINT `fk_aluguel_cliente1`
    FOREIGN KEY (`id_cliente_aluguel`)
    REFERENCES `locadora`.`cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_aluguel_midia_alugada1`
    FOREIGN KEY (`id_ma_aluguel`)
    REFERENCES `locadora`.`midia_alugada` (`id_midia_alugada`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS `locadora`.`caixa` (
  `id_caixa` INT(11) NOT NULL AUTO_INCREMENT,
  `data_pgto` DATE NOT NULL,
  `id_aluguel_caixa` INT(11) NOT NULL,
  `valor` DECIMAL(8,2) NULL DEFAULT NULL,
  `forma_pgto` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`id_caixa`, `data_pgto`),
  INDEX `fk_caixa_aluguel1_idx` (`id_aluguel_caixa` ASC),
  CONSTRAINT `fk_caixa_aluguel1`
    FOREIGN KEY (`id_aluguel_caixa`)
    REFERENCES `locadora`.`aluguel` (`id_aluguel`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 9
DEFAULT CHARACTER SET = utf8mb4;

CREATE TABLE IF NOT EXISTS `locadora`.`reserva` (
  `id_reserva` INT(11) NOT NULL AUTO_INCREMENT,
  `id_cliente_reserva` INT(11) NOT NULL,
  `reserva_ativa` TINYINT(4) NOT NULL,
  `id_filme_reserva` INT(11) NOT NULL,
  PRIMARY KEY (`id_reserva`, `id_cliente_reserva`),
  INDEX `fk_reserva_cliente1_idx` (`id_cliente_reserva` ASC),
  INDEX `fk_reserva_filme1_idx` (`id_filme_reserva` ASC),
  CONSTRAINT `fk_reserva_cliente1`
    FOREIGN KEY (`id_cliente_reserva`)
    REFERENCES `locadora`.`cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_reserva_filme1`
    FOREIGN KEY (`id_filme_reserva`)
    REFERENCES `locadora`.`filme` (`id_filme`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4;
```
