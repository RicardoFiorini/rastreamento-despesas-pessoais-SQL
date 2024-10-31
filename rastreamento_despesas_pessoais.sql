-- Criação do banco de dados
CREATE DATABASE RastreamentoDespesas;
USE RastreamentoDespesas;

-- Tabela para armazenar categorias de despesas
CREATE TABLE Categorias (
    categoria_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descricao TEXT,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para armazenar usuários
CREATE TABLE Usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela para armazenar despesas
CREATE TABLE Despesas (
    despesa_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    categoria_id INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL CHECK (valor >= 0),
    data_despesa DATE NOT NULL,
    descricao TEXT,
    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id) ON DELETE CASCADE,
    FOREIGN KEY (categoria_id) REFERENCES Categorias(categoria_id) ON DELETE CASCADE
);

-- Índices para melhorar a performance
CREATE INDEX idx_despesa_data ON Despesas(data_despesa);
CREATE INDEX idx_categoria_nome ON Categorias(nome);
CREATE INDEX idx_usuario_email ON Usuarios(email);

-- View para visualizar o total de despesas por categoria
CREATE VIEW ViewTotalDespesasPorCategoria AS
SELECT c.nome AS categoria, SUM(d.valor) AS total_despesas
FROM Despesas d
JOIN Categorias c ON d.categoria_id = c.categoria_id
GROUP BY c.nome;

-- View para visualizar despesas por usuário
CREATE VIEW ViewDespesasPorUsuario AS
SELECT u.nome AS usuario, d.valor, d.data_despesa, c.nome AS categoria, d.descricao
FROM Despesas d
JOIN Usuarios u ON d.usuario_id = u.usuario_id
JOIN Categorias c ON d.categoria_id = c.categoria_id
ORDER BY d.data_despesa DESC;

-- Função para calcular o total de despesas de um usuário em um determinado mês
DELIMITER //
CREATE FUNCTION CalcularTotalDespesasUsuario(usuario_id INT, mes INT, ano INT) RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total DECIMAL(10, 2);
    SELECT IFNULL(SUM(valor), 0) INTO total
    FROM Despesas
    WHERE usuario_id = usuario_id AND MONTH(data_despesa) = mes AND YEAR(data_despesa) = ano;
    RETURN total;
END //
DELIMITER ;

-- Trigger para garantir que não haja despesas negativas
DELIMITER //
CREATE TRIGGER Trigger_ValidaDespesa
BEFORE INSERT ON Despesas
FOR EACH ROW
BEGIN
    IF NEW.valor < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'O valor da despesa não pode ser negativo';
    END IF;
END //
DELIMITER ;

-- Inserção de exemplo de categorias
INSERT INTO Categorias (nome, descricao) VALUES 
('Alimentação', 'Despesas com comida e bebida'),
('Transporte', 'Despesas de transporte'),
('Lazer', 'Despesas de entretenimento e lazer'),
('Saúde', 'Despesas com saúde e medicamentos'),
('Educação', 'Despesas com educação e cursos');

-- Inserção de exemplo de usuários
INSERT INTO Usuarios (nome, email) VALUES 
('João Silva', 'joao.silva@example.com'),
('Maria Oliveira', 'maria.oliveira@example.com');

-- Inserção de exemplo de despesas
INSERT INTO Despesas (usuario_id, categoria_id, valor, data_despesa, descricao) VALUES 
(1, 1, 50.00, '2024-10-01', 'Almoço'),
(1, 2, 20.00, '2024-10-02', 'Transporte de ônibus'),
(2, 1, 15.00, '2024-10-03', 'Café da manhã'),
(1, 3, 100.00, '2024-10-04', 'Cinema');

-- Selecionar total de despesas por categoria
SELECT * FROM ViewTotalDespesasPorCategoria;

-- Selecionar despesas por usuário
SELECT * FROM ViewDespesasPorUsuario;

-- Calcular total de despesas do usuário 1 em outubro de 2024
SELECT CalcularTotalDespesasUsuario(1, 10, 2024) AS total_despesas;

-- Excluir uma despesa
DELETE FROM Despesas WHERE despesa_id = 1;

-- Excluir um usuário (isso falhará se o usuário tiver despesas)
DELETE FROM Usuarios WHERE usuario_id = 1;

-- Excluir uma categoria (isso falhará se a categoria tiver despesas associadas)
DELETE FROM Categorias WHERE categoria_id = 1;
