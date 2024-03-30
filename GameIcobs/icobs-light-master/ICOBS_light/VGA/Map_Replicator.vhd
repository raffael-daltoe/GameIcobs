library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Map_Replicator is
    Port ( clka : in  STD_LOGIC;
           addra : in  STD_LOGIC_VECTOR (15 downto 0);
           douta : out  STD_LOGIC_VECTOR (11 downto 0));
end Map_Replicator;

architecture Behavioral of Map_Replicator is
    -- Definição das constantes para as dimensões do fragmento do mapa
    constant MAP_WIDTH : integer := 320; -- Metade da largura total para 640x480
    constant MAP_HEIGHT : integer := 240; -- Metade da altura total para 640x480

    -- Sinais para coordenadas transformadas e endereço de memória
    signal transformed_x, transformed_y : integer;
    signal mem_address : STD_LOGIC_VECTOR (15 downto 0);
begin
    process(clka)
    begin
        if rising_edge(clka) then
            -- Conversão do vetor de endereço para valores inteiros X e Y
            transformed_x <= to_integer(unsigned(addra)) mod 640;
            transformed_y <= to_integer(unsigned(addra)) / 640;

            -- Lógica para determinar o quadrante e aplicar transformações
            if transformed_x < MAP_WIDTH then
                if transformed_y < MAP_HEIGHT then
                    -- Quadrante superior esquerdo (sem transformação)
                else
                    -- Quadrante inferior esquerdo (espelhar verticalmente)
                    transformed_y := (2 * MAP_HEIGHT) - transformed_y - 1;
                end if;
            else
                if transformed_y < MAP_HEIGHT then
                    -- Quadrante superior direito (espelhar horizontalmente)
                    transformed_x := (2 * MAP_WIDTH) - transformed_x - 1;
                else
                    -- Quadrante inferior direito (espelhar ambos)
                    transformed_x := (2 * MAP_WIDTH) - transformed_x - 1;
                    transformed_y := (2 * MAP_HEIGHT) - transformed_y - 1;
                end if;
            end if;

            -- Cálculo do endereço de memória baseado nas coordenadas transformadas
            mem_address <= std_logic_vector(to_unsigned((transformed_y * MAP_WIDTH) + transformed_x, mem_address'length));

            -- Leitura da memória (Simulada neste exemplo, substitua pela sua lógica de leitura real)
            -- Suponha que 'memory_block' seja o seu componente de memória mapeado
            -- douta <= memory_block(mem_address); -- Lembre-se de ajustar esta linha conforme sua implementação
        end if;
    end process;
end Behavioral;
