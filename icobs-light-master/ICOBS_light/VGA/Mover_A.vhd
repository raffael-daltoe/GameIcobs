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
	--signal dx, dy : std_logic;
	SIGNAL x, y : unsigned(9 DOWNTO 0);
	-- W =LARGURA Do sprite
	-- H = ALTURA Do sprite
	CONSTANT w : unsigned(9 DOWNTO 0) := to_unsigned(240, 10);--10 é tamanho padrão para esta resolução paraconseguir calcular com as outras medias
	CONSTANT h : unsigned(9 DOWNTO 0) := to_unsigned(160, 10);
	SIGNAL rom_addr_s : std_logic_vector(19 DOWNTO 0);
	SIGNAL flag : std_logic;
BEGIN
	R1 <= y;
	C1 <= x;
	-- combinatoire pour reduir le clock
	control : PROCESS (clk, rst)
	BEGIN
		-- para usar o rst e o clk tem q colocar if rst elsif clock
		-- se não ele só executa dentro do rst.

		IF rst = '1' THEN
			--Defines the image in the center
			x <= TO_UNSIGNED(320, 10);
			y <= TO_UNSIGNED(240, 10);
			-- verifica a borda de subida do clock para fazer as mudanças
		ELSIF clk'EVENT AND clk = '1' THEN
 
			IF flag = '0' THEN
				IF btnU = '1' AND btnL = '1' THEN           -- diagonal direita pra baixo
					x <= x + 1;
					y <= y + 1;
				ELSIF btnU = '1' AND btnR = '1' THEN         -- diagonal esquerda pra baixo
					x <= x - 1;
					y <= y + 1;
			    ELSIF btnR = '1' THEN                        -- direita
			        x <= x + 1;
			    ELSIF btnL = '1' THEN                        -- esquerda
			        x <= x - 1;
				ELSIF btnU = '1' THEN                        -- vai pra cima
					y <= y - 1;
				END IF;
 
				IF btnD = '1' AND btnL = '1' THEN            -- diagonal direita pra cima
					y <= y - 1;
					x <= x + 1;
				ELSIF btnD = '1' AND btnR = '1' THEN         -- diagonal esquerda pra cima
					y <= y - 1;
					x <= x - 1;
				ELSIF btnD = '1' THEN                        -- vai pra baixo
					y <= y + 1;    
				END IF;
			END IF;
		END IF;
	END PROCESS;
	
	process(clk, rst)
	begin
	   if rst = '1' then
	       flag <= '0';
	   elsif rising_edge(clk) then
	       IF (x + w)/2 > 320 THEN
				flag <= '0';
			ELSIF (y + h)/2 > 240 THEN
				flag <= '0';
			END IF;
			
			IF x + w > 6
			 THEN
				flag <= '1';
			ELSIF y + h > 480 THEN
				flag <= '1';
			END IF;
	   end if;
	end process;
END archi;