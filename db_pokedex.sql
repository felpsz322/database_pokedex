CREATE DATABASE IF NOT EXISTS db_pokedex
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;

USE db_pokedex;

CREATE TABLE IF NOT EXISTS tb_regiao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT = 1;

CREATE TABLE IF NOT EXISTS tb_tipo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome_tipo VARCHAR(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT = 1;

CREATE TABLE IF NOT EXISTS tb_habilidade (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255)
) ENGINE=InnoDB AUTO_INCREMENT = 1;

CREATE TABLE IF NOT EXISTS tb_pokemon (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    numero_pokedex INT NOT NULL UNIQUE,
    altura DECIMAL(4,2) NOT NULL,
    peso DECIMAL(5,2) NOT NULL,
    hp TINYINT UNSIGNED NOT NULL,
    ataque TINYINT UNSIGNED NOT NULL,
    regiao_id INT NOT NULL,

    CONSTRAINT fk_tb_pokemon_regiao
        FOREIGN KEY (regiao_id)
        REFERENCES tb_regiao(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT = 1;

CREATE TABLE IF NOT EXISTS tb_pokemon_habilidade (
    pokemon_id INT NOT NULL,
    habilidade_id INT NOT NULL,

    PRIMARY KEY (pokemon_id, habilidade_id),

    CONSTRAINT fk_pokemon_habilidade_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES tb_pokemon(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_pokemon_habilidade_habilidade
        FOREIGN KEY (habilidade_id)
        REFERENCES tb_habilidade(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tb_pokemon_tipo (
    pokemon_id INT NOT NULL,
    tipo_id INT NOT NULL,

    PRIMARY KEY (pokemon_id, tipo_id),

    CONSTRAINT fk_pokemon_tipo_pokemon
        FOREIGN KEY (pokemon_id)
        REFERENCES tb_pokemon(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_pokemon_tipo_tipo
        FOREIGN KEY (tipo_id)
        REFERENCES tb_tipo(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tb_evolui (
    pokemon_base_id INT NOT NULL,
    pokemon_evolucao_id INT NOT NULL,
    nivel_min INT NOT NULL,
    item VARCHAR(100),
    condicao VARCHAR(255),

    PRIMARY KEY (pokemon_base_id, pokemon_evolucao_id),

    CONSTRAINT fk_evolui_base
        FOREIGN KEY (pokemon_base_id)
        REFERENCES tb_pokemon(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_evolui_evolucao
        FOREIGN KEY (pokemon_evolucao_id)
        REFERENCES tb_pokemon(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
) ENGINE=InnoDB;

INSERT INTO tb_regiao (nome) VALUES
('Kanto'),
('Johto'),
('Hoenn');

INSERT INTO tb_tipo (nome_tipo) VALUES
('Elétrico'),
('Fogo'),
('Água'),
('Planta'),
('Veneno'),
('Voador');

INSERT INTO tb_habilidade (nome, descricao) VALUES
('Static', 'Pode paralisar o oponente ao contato'),
('Overgrow', 'Aumenta golpes do tipo Planta com HP baixo'),
('Blaze', 'Aumenta golpes do tipo Fogo com HP baixo'),
('Torrent', 'Aumenta golpes do tipo Água com HP baixo');

INSERT INTO tb_pokemon 
(nome, numero_pokedex, altura, peso, hp, ataque, regiao_id) VALUES
('Bulbasaur', 1, 0.70, 6.90, 45, 49, 1),
('Charmander', 4, 0.60, 8.50, 39, 52, 1),
('Squirtle', 7, 0.50, 9.00, 44, 48, 1),
('Pikachu', 25, 0.40, 6.00, 35, 55, 1);

INSERT INTO tb_pokemon_tipo (pokemon_id, tipo_id) VALUES
(1, 4), -- Bulbasaur - Planta
(1, 5), -- Bulbasaur - Veneno
(2, 2), -- Charmander - Fogo
(3, 3), -- Squirtle - Água
(4, 1); -- Pikachu - Elétrico

INSERT INTO tb_pokemon_habilidade (pokemon_id, habilidade_id) VALUES
(1, 2), -- Bulbasaur - Overgrow
(2, 3), -- Charmander - Blaze
(3, 4), -- Squirtle - Torrent
(4, 1); -- Pikachu - Static

SELECT 
    p.nome AS pokemon,
    p.numero_pokedex,
    r.nome AS regiao
FROM tb_pokemon p
INNER JOIN tb_regiao r ON p.regiao_id = r.id;

SELECT 
    p.nome AS pokemon,
    t.nome_tipo AS tipo
FROM tb_pokemon p
INNER JOIN tb_pokemon_tipo pt ON p.id = pt.pokemon_id
INNER JOIN tb_tipo t ON pt.tipo_id = t.id
ORDER BY p.nome;

SELECT 
    p.nome AS pokemon,
    r.nome AS regiao,
    t.nome_tipo AS tipo,
    h.nome AS habilidade
FROM tb_pokemon p
INNER JOIN tb_regiao r ON p.regiao_id = r.id
INNER JOIN tb_pokemon_tipo pt ON p.id = pt.pokemon_id
INNER JOIN tb_tipo t ON pt.tipo_id = t.id
INNER JOIN tb_pokemon_habilidade ph ON p.id = ph.pokemon_id
INNER JOIN tb_habilidade h ON ph.habilidade_id = h.id
ORDER BY p.nome;

CREATE OR REPLACE VIEW vw_pokemon_completo AS
SELECT 
    p.id AS pokemon_id,
    p.nome AS pokemon,
    p.numero_pokedex,
    r.nome AS regiao,
    GROUP_CONCAT(DISTINCT t.nome_tipo ORDER BY t.nome_tipo SEPARATOR ', ') AS tipos,
    GROUP_CONCAT(DISTINCT h.nome ORDER BY h.nome SEPARATOR ', ') AS habilidades
FROM tb_pokemon p
INNER JOIN tb_regiao r ON p.regiao_id = r.id
LEFT JOIN tb_pokemon_tipo pt ON p.id = pt.pokemon_id
LEFT JOIN tb_tipo t ON pt.tipo_id = t.id
LEFT JOIN tb_pokemon_habilidade ph ON p.id = ph.pokemon_id
LEFT JOIN tb_habilidade h ON ph.habilidade_id = h.id
GROUP BY p.id, p.nome, p.numero_pokedex, r.nome;

SELECT * FROM vw_pokemon_completo;











