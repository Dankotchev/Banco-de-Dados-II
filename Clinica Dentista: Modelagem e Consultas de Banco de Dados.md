# Consulta de Banco de Dados: Clinica de Dentistas

O Dr. Ciro Jõao Dentista, tem uma clinica e deseja informatiza-la para isso, ele entrou em contato com você e contratou o seu trabalho de Analista. Ele precisa de um projeto onde possa controlar as consultas, ele precisa de uma agenda, controle de consultas onde possa informar o que foi discutido com paciente, remédios e tratamentos efetuados, forma de pagamento do tratamento e despesa da clinica, produtos utilizados nos tratamentos, compra de material e pagamento a fornecedor., orçamento ao paciente.

Na clinica 3 médicos atendem e as despesas devem ser controladas em separado tanto o pagamento de consulta como despesas geradas por cada um.

Crie uma modelagem para atender o problema. Especifique os atributos de cada entidade.

**Além do escopo vc deve atender a estas pesquisas**

- Quais os débitos de um determinado paciente

- Total gasto por cada paciente

- Qual o tratamento mais caro

  ## Modelagem

  <img src="/home/daniloquirino/Imagens/modelagem_clinica.png" alt="Modelagem" style="zoom: 200%;" />

## Script

```sql
DROP DATABASE IF EXISTS `clinica_dentista` ;
CREATE SCHEMA IF NOT EXISTS `clinica_dentista` ;
USE `clinica_dentista` ;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`paciente` (
  `id_paciente` INT NOT NULL AUTO_INCREMENT,
  `nome_pac` VARCHAR(50) NOT NULL,
  `cpf_pac` VARCHAR(11) NULL,
  `data_nasc_pac` DATE NOT NULL,
  PRIMARY KEY (`id_paciente`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`contato` (
  `id_contato` INT NOT NULL AUTO_INCREMENT,
  `telefone` VARCHAR(14) NULL,
  `logradouro` VARCHAR(30) NULL,
  `numero_log` VARCHAR(8) NULL,
  `email` VARCHAR(50) NULL,
  PRIMARY KEY (`id_contato`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`medico` (
  `id_medico` INT NOT NULL AUTO_INCREMENT,
  `crm_med` VARCHAR(10) NOT NULL,
  `nome_med` VARCHAR(50) NOT NULL,
  `especialidade` VARCHAR(30) NULL,
  PRIMARY KEY (`id_medico`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`agenda` (
  `id_agenda` INT NOT NULL AUTO_INCREMENT,
  `id_medico` INT NOT NULL,
  `data_agenda` DATE NOT NULL,
  PRIMARY KEY (`id_agenda`, `id_medico`),
  INDEX `fk_agenda_medico1_idx` (`id_medico` ASC),
  CONSTRAINT `fk_agenda_medico1`
    FOREIGN KEY (`id_medico`)
    REFERENCES `clinica_dentista`.`medico` (`id_medico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`detalhamento` (
  `id_detalhamento` INT NOT NULL AUTO_INCREMENT,
  `descricao` VARCHAR(255) NULL,
  PRIMARY KEY (`id_detalhamento`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`consulta` (
  `id_agenda_consulta` INT NOT NULL,
  `hora_consulta` TIME NOT NULL,
  `id_paciente_consulta` INT NOT NULL,
  `id_detalhamento_consulta` INT NOT NULL,
  `valor_consulta` DECIMAL(8,2) NULL,
  `pago` TINYINT NULL,
  `forma_pgto` VARCHAR(30) NULL,
  PRIMARY KEY (`id_agenda_consulta`, `hora_consulta`),
  INDEX `fk_agenda_has_paciente_paciente1_idx` (`id_paciente_consulta` ASC),
  INDEX `fk_agenda_has_paciente_agenda1_idx` (`id_agenda_consulta` ASC),
  INDEX `fk_consulta_detalhamento1_idx` (`id_detalhamento_consulta` ASC),
  CONSTRAINT `fk_agenda_has_paciente_agenda1`
    FOREIGN KEY (`id_agenda_consulta`)
    REFERENCES `clinica_dentista`.`agenda` (`id_agenda`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_agenda_has_paciente_paciente1`
    FOREIGN KEY (`id_paciente_consulta`)
    REFERENCES `clinica_dentista`.`paciente` (`id_paciente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_consulta_detalhamento1`
    FOREIGN KEY (`id_detalhamento_consulta`)
    REFERENCES `clinica_dentista`.`detalhamento` (`id_detalhamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`tratamento` (
  `id_tratamento` INT NOT NULL AUTO_INCREMENT,
  `nome_trat` VARCHAR(50) NOT NULL,
  `valor_trat` DECIMAL(8,2) NULL,
  `descricao` VARCHAR(50) NULL,
  PRIMARY KEY (`id_tratamento`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`produto` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `nome_prod` VARCHAR(50) NOT NULL,
  `custo` DECIMAL(8,2) NOT NULL,
  `estoque` INT NULL,
  `descricao` VARCHAR(50) NULL,
  PRIMARY KEY (`id_produto`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`fornecedor` (
  `id_fornecedor` INT NOT NULL AUTO_INCREMENT,
  `nome_forn` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_fornecedor`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`fornecedor_contato` (
  `id_fornecedor` INT NOT NULL,
  `id_contato` INT NOT NULL,
  `nome_contato` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id_fornecedor`, `id_contato`),
  INDEX `fk_fornecedor_has_contato_contato1_idx` (`id_contato` ASC),
  INDEX `fk_fornecedor_has_contato_fornecedor1_idx` (`id_fornecedor` ASC),
  CONSTRAINT `fk_fornecedor_has_contato_fornecedor1`
    FOREIGN KEY (`id_fornecedor`)
    REFERENCES `clinica_dentista`.`fornecedor` (`id_fornecedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fornecedor_has_contato_contato1`
    FOREIGN KEY (`id_contato`)
    REFERENCES `clinica_dentista`.`contato` (`id_contato`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`paciente_contato` (
  `id_paciente` INT NULL,
  `id_contato` INT NOT NULL,
  PRIMARY KEY (`id_contato`, `id_paciente`),
  INDEX `fk_paciente_has_contato_contato2_idx` (`id_contato` ASC),
  INDEX `fk_paciente_has_contato_paciente2_idx` (`id_paciente` ASC),
  CONSTRAINT `fk_paciente_has_contato_paciente2`
    FOREIGN KEY (`id_paciente`)
    REFERENCES `clinica_dentista`.`paciente` (`id_paciente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_paciente_has_contato_contato2`
    FOREIGN KEY (`id_contato`)
    REFERENCES `clinica_dentista`.`contato` (`id_contato`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`compra_produto` (
  `id_produto` INT NULL,
  `id_fornecedor` INT NULL,
  `data_compra` DATE NOT NULL,
  `quantidade_compra` INT NOT NULL,
  PRIMARY KEY (`id_produto`, `id_fornecedor`),
  INDEX `fk_produto_has_fornecedor_fornecedor1_idx` (`id_fornecedor` ASC),
  INDEX `fk_produto_has_fornecedor_produto1_idx` (`id_produto` ASC),
  CONSTRAINT `fk_produto_has_fornecedor_produto1`
    FOREIGN KEY (`id_produto`)
    REFERENCES `clinica_dentista`.`produto` (`id_produto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_produto_has_fornecedor_fornecedor1`
    FOREIGN KEY (`id_fornecedor`)
    REFERENCES `clinica_dentista`.`fornecedor` (`id_fornecedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`tratamento_produto` (
  `id_tratamento` INT NULL,
  `id_produto` INT NOT NULL,
  `qtd_uso` INT NOT NULL,
  PRIMARY KEY (`id_tratamento`, `id_produto`),
  INDEX `fk_tratamento_has_produto_produto1_idx` (`id_produto` ASC),
  INDEX `fk_tratamento_has_produto_tratamento1_idx` (`id_tratamento` ASC),
  CONSTRAINT `fk_tratamento_has_produto_tratamento1`
    FOREIGN KEY (`id_tratamento`)
    REFERENCES `clinica_dentista`.`tratamento` (`id_tratamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tratamento_has_produto_produto1`
    FOREIGN KEY (`id_produto`)
    REFERENCES `clinica_dentista`.`produto` (`id_produto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`medicamento` (
  `id_medicamento` INT NOT NULL AUTO_INCREMENT,
  `composto_ativo_medicamento` VARCHAR(50) NOT NULL,
  `nome_comercial_medicamento` VARCHAR(50) NULL,
  PRIMARY KEY (`id_medicamento`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`receita_medicamento` (
  `id_agenda_receita` INT NULL,
  `hora_consulta_receita` TIME NULL,
  `id_medicamento` INT NOT NULL,
  `utilizacao` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`id_agenda_receita`, `hora_consulta_receita`, `id_medicamento`),
  INDEX `fk_consulta_has_medicamento_medicamento1_idx` (`id_medicamento` ASC),
  INDEX `fk_consulta_has_medicamento_consulta1_idx` (`id_agenda_receita` ASC, `hora_consulta_receita` ASC),
  CONSTRAINT `fk_consulta_has_medicamento_consulta1`
    FOREIGN KEY (`id_agenda_receita` , `hora_consulta_receita`)
    REFERENCES `clinica_dentista`.`consulta` (`id_agenda_consulta` , `hora_consulta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_consulta_has_medicamento_medicamento1`
    FOREIGN KEY (`id_medicamento`)
    REFERENCES `clinica_dentista`.`medicamento` (`id_medicamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`consulta_tratamento` (
  `id_agenda_consulta` INT NULL,
  `hora_consulta` TIME NULL,
  `id_tratamento` INT NOT NULL,
  `detalhamento` VARCHAR(100) NULL,
  PRIMARY KEY (`id_agenda_consulta`, `hora_consulta`, `id_tratamento`),
  INDEX `fk_consulta_has_tratamento_tratamento1_idx` (`id_tratamento` ASC),
  INDEX `fk_consulta_has_tratamento_consulta1_idx` (`id_agenda_consulta` ASC, `hora_consulta` ASC),
  CONSTRAINT `fk_consulta_has_tratamento_consulta1`
    FOREIGN KEY (`id_agenda_consulta` , `hora_consulta`)
    REFERENCES `clinica_dentista`.`consulta` (`id_agenda_consulta` , `hora_consulta`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_consulta_has_tratamento_tratamento1`
    FOREIGN KEY (`id_tratamento`)
    REFERENCES `clinica_dentista`.`tratamento` (`id_tratamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`despesa` (
  `id_despesa` INT NOT NULL,
  `id_medico_desp` INT NULL,
  `valor_desp` DECIMAL(8,2) NOT NULL,
  `data_desp` DATE NULL,
  `descricao` VARCHAR(45) NULL,
  PRIMARY KEY (`id_despesa`, `id_medico_desp`),
  INDEX `fk_despesa_medico1_idx` (`id_medico_desp` ASC),
  CONSTRAINT `fk_despesa_medico1`
    FOREIGN KEY (`id_medico_desp`)
    REFERENCES `clinica_dentista`.`medico` (`id_medico`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`orcamento` (
  `id_orcamento` INT NOT NULL,
  `paciente_id_paciente` INT NOT NULL,
  `status_orc` TINYINT NOT NULL,
  PRIMARY KEY (`id_orcamento`),
  INDEX `fk_orcamento_paciente1_idx` (`paciente_id_paciente` ASC),
  CONSTRAINT `fk_orcamento_paciente1`
    FOREIGN KEY (`paciente_id_paciente`)
    REFERENCES `clinica_dentista`.`paciente` (`id_paciente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `clinica_dentista`.`orcamento_tratamento` (
  `id_orcamento` INT NOT NULL,
  `id_tratamento` INT NOT NULL,
  PRIMARY KEY (`id_orcamento`, `id_tratamento`),
  INDEX `fk_orcamento_has_tratamento_tratamento1_idx` (`id_tratamento` ASC),
  INDEX `fk_orcamento_has_tratamento_orcamento1_idx` (`id_orcamento` ASC),
  CONSTRAINT `fk_orcamento_has_tratamento_orcamento1`
    FOREIGN KEY (`id_orcamento`)
    REFERENCES `clinica_dentista`.`orcamento` (`id_orcamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orcamento_has_tratamento_tratamento1`
    FOREIGN KEY (`id_tratamento`)
    REFERENCES `clinica_dentista`.`tratamento` (`id_tratamento`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;
```