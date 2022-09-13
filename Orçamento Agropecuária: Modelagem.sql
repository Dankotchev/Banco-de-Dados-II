CREATE SCHEMA IF NOT EXISTS `orcamento_agropecuaria` ;
USE `orcamento_agropecuaria` ;


CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`cliente` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(60) NOT NULL,
  `telefone` VARCHAR(16) NOT NULL,
  `cpf` VARCHAR(16) NULL,
  `endereco` VARCHAR(45) NULL,
  PRIMARY KEY (`id_cliente`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`orcamento` (
  `id_orcamento` INT NOT NULL AUTO_INCREMENT,
  `cliente_id` INT NOT NULL,
  `valortotal` DECIMAL(10,2) NULL,
  `validade_orcamento` DATE NOT NULL,
  `parcelas` INT NOT NULL,
  `data_aprovacao` DATE NULL,
  PRIMARY KEY (`id_orcamento`),
  INDEX `fk_orcamento_cliente1_idx` (`cliente_id` ASC) VISIBLE,
  CONSTRAINT `fk_orcamento_cliente1`
    FOREIGN KEY (`cliente_id`)
    REFERENCES `orcamento_agropecuaria`.`cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`produto` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `valor_produto` DECIMAL(10,2) NOT NULL,
  `nome` VARCHAR(60) NULL,
  `descricao` VARCHAR(100) NULL,
  PRIMARY KEY (`id_produto`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`itens_orcamento` (
  `orcamento_id` INT NOT NULL,
  `produto_id` INT NOT NULL,
  `valor_unitario` DECIMAL(10,2) NULL,
  PRIMARY KEY (`orcamento_id`, `produto_id`),
  INDEX `fk_itens_orcamento_produto1_idx` (`produto_id` ASC) VISIBLE,
  CONSTRAINT `fk_itens_orcamento_orcamento`
    FOREIGN KEY (`orcamento_id`)
    REFERENCES `orcamento_agropecuaria`.`orcamento` (`id_orcamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_itens_orcamento_produto1`
    FOREIGN KEY (`produto_id`)
    REFERENCES `orcamento_agropecuaria`.`produto` (`id_produto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`venda` (
  `id_venda` INT NOT NULL AUTO_INCREMENT,
  `cliente_id` INT NOT NULL,
  `data_venda` DATE NOT NULL,
  `valortotal` DECIMAL(10,2) NOT NULL,
  `parcelas` INT NULL,
  PRIMARY KEY (`id_venda`),
  INDEX `fk_venda_cliente1_idx` (`cliente_id` ASC) VISIBLE,
  CONSTRAINT `fk_venda_cliente1`
    FOREIGN KEY (`cliente_id`)
    REFERENCES `orcamento_agropecuaria`.`cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`itens_venda` (
  `venda_id` INT NOT NULL,
  `produto_id` INT NOT NULL,
  `valor_unitario` DECIMAL(10,2) NULL,
  PRIMARY KEY (`venda_id`, `produto_id`),
  INDEX `fk_itens_venda_produto1_idx` (`produto_id` ASC) VISIBLE,
  CONSTRAINT `fk_itens_venda_venda1`
    FOREIGN KEY (`venda_id`)
    REFERENCES `orcamento_agropecuaria`.`venda` (`id_venda`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_itens_venda_produto1`
    FOREIGN KEY (`produto_id`)
    REFERENCES `orcamento_agropecuaria`.`produto` (`id_produto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`caixa` (
  `data_caixa` DATE NOT NULL,
  `estado` TINYINT NOT NULL,
  `saldo` DECIMAL(10,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (`data_caixa`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`pagamento` (
  `venda_id` INT NOT NULL,
  `parcela_pagamento` INT NOT NULL,
  `vencimento` DATE NOT NULL,
  `valor_parcela` DECIMAL(10,2) NOT NULL,
  `data_pagamento` DATE NULL,
  PRIMARY KEY (`venda_id`, `parcela_pagamento`),
  CONSTRAINT `fk_pagamento_venda1`
    FOREIGN KEY (`venda_id`)
    REFERENCES `orcamento_agropecuaria`.`venda` (`id_venda`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `orcamento_agropecuaria`.`movimentacao` (
  `caixa_data` DATE NOT NULL,
  `pagamento_venda_id` INT NOT NULL,
  `pagamento_parcela` INT NOT NULL,
  PRIMARY KEY (`caixa_data`, `pagamento_venda_id`, `pagamento_parcela`),
  INDEX `fk_movimentacao_pagamento1_idx` (`pagamento_venda_id` ASC, `pagamento_parcela` ASC) VISIBLE,
  CONSTRAINT `fk_movimentacao_caixa1`
    FOREIGN KEY (`caixa_data`)
    REFERENCES `orcamento_agropecuaria`.`caixa` (`data_caixa`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_movimentacao_pagamento1`
    FOREIGN KEY (`pagamento_venda_id` , `pagamento_parcela`)
    REFERENCES `orcamento_agropecuaria`.`pagamento` (`venda_id` , `parcela_pagamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
