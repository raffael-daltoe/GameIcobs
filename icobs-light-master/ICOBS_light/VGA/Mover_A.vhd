LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.packages.ALL;

ENTITY Mover_A IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        btnU, btnD, btnL, btnR : IN STD_LOGIC;
        R1 : OUT unsigned(9 DOWNTO 0);
        C1 : OUT unsigned(9 DOWNTO 0)
    );
END Mover_A;

ARCHITECTURE archi OF Mover_A IS
    SIGNAL x, y : unsigned(9 DOWNTO 0) := (others => '0');
    CONSTANT max_width : unsigned(9 DOWNTO 0) := TO_UNSIGNED(400, 10); -- Supondo uma largura de tela de 480 pixels
    CONSTANT max_height : unsigned(9 DOWNTO 0) := TO_UNSIGNED(320, 10); -- Supondo uma altura de tela de 320 pixels
BEGIN
    R1 <= y;
    C1 <= x;

    -- Processo para controlar a movimentação
    control : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                x <= TO_UNSIGNED(320, 10);
                y <= TO_UNSIGNED(240, 10);
            ELSE
                -- Movimentação para a direita
                IF btnR = '1' AND x < max_width THEN
                    x <= x + 1;
                END IF;

                -- Movimentação para a esquerda
                IF btnL = '1' AND x > 0 THEN
                    x <= x - 1;
                END IF;

                -- Movimentação para cima
                IF btnU = '1' AND y > 0 THEN
                    y <= y - 1;
                END IF;

                -- Movimentação para baixo
                IF btnD = '1' AND y < max_height THEN
                    y <= y + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS control;
END archi;
