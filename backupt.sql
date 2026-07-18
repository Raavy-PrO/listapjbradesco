-- ===== CRIAR BANCO DE DADOS =====
CREATE DATABASE IF NOT EXISTS cnpj_system;
USE cnpj_system;

-- ===== TABELA DE FUNCIONÁRIOS =====
CREATE TABLE funcionarios (
  id INT PRIMARY KEY AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ===== TABELA DE LISTAS =====
CREATE TABLE listas (
  id INT PRIMARY KEY AUTO_INCREMENT,
  funcionario_id INT NOT NULL,
  nome_lista VARCHAR(100),
  data_envio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id) ON DELETE CASCADE
);

-- ===== TABELA DE CNPJs =====
CREATE TABLE cnpjs (
  id INT PRIMARY KEY AUTO_INCREMENT,
  lista_id INT NOT NULL,
  cnpj VARCHAR(18) NOT NULL,
  razao_social VARCHAR(200),
  cpf VARCHAR(14),
  nome_pessoa VARCHAR(150),
  ag VARCHAR(10),
  cc VARCHAR(20),
  nascimento VARCHAR(10),
  idade INT,
  renda VARCHAR(20),
  email VARCHAR(100),
  endereco VARCHAR(255),
  telefones TEXT,
  criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lista_id) REFERENCES listas(id) ON DELETE CASCADE,
  UNIQUE KEY unique_cnpj_lista (cnpj, lista_id),
  INDEX idx_lista_id (lista_id),
  INDEX idx_cnpj (cnpj)
);

-- ===== TABELA DE HISTÓRICO =====
CREATE TABLE historico (
  id INT PRIMARY KEY AUTO_INCREMENT,
  cnpj_id INT NOT NULL,
  funcionario_id INT NOT NULL,
  acao ENUM('visualizado', 'excluido') NOT NULL,
  data_acao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cnpj_id) REFERENCES cnpjs(id) ON DELETE CASCADE,
  FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id) ON DELETE CASCADE,
  INDEX idx_funcionario_id (funcionario_id),
  INDEX idx_cnpj_id (cnpj_id),
  INDEX idx_data_acao (data_acao)
);

-- ===== DADOS INICIAIS (FUNCIONÁRIOS EXEMPLO) =====
INSERT INTO funcionarios (nome) VALUES
('Funcionário 1'),
('Funcionário 2'),
('Funcionário 3'),
('Funcionário 4');

-- ===== VIEWS ÚTEIS =====

-- View: CNPJs pendentes por funcionário
CREATE VIEW v_cnpjs_pendentes AS
SELECT 
  l.id as lista_id,
  l.funcionario_id,
  f.nome as funcionario_nome,
  COUNT(c.id) as total_cnpjs
FROM listas l
JOIN funcionarios f ON l.funcionario_id = f.id
LEFT JOIN cnpjs c ON l.id = c.lista_id
LEFT JOIN historico h ON c.id = h.cnpj_id AND h.acao = 'visualizado'
WHERE h.id IS NULL
GROUP BY l.id, l.funcionario_id, f.nome;

-- View: Histórico de ações
CREATE VIEW v_historico_resumo AS
SELECT 
  f.nome as funcionario_nome,
  COUNT(CASE WHEN h.acao = 'visualizado' THEN 1 END) as total_visualizados,
  COUNT(CASE WHEN h.acao = 'excluido' THEN 1 END) as total_excluidos,
  MAX(h.data_acao) as ultima_acao
FROM funcionarios f
LEFT JOIN historico h ON f.id = h.funcionario_id
GROUP BY f.id, f.nome;
