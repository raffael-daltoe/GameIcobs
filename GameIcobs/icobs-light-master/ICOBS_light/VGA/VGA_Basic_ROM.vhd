library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.packages.all;

ENTITY VGA_Basic_ROM IS
    PORT (
        vidon                   : IN STD_LOGIC;
        hc                      : IN vector10;
        vc                      : IN vector10;               
        sw                      : IN vector12;   -- SWITCH OF FPGA
        changePacman            : IN STD_LOGIC;
        rst                     : IN STD_LOGIC;
        clk                     : IN STD_LOGIC;
        --  REGISTERS
        R_SW0                      : in unsigned(9 downto 0);  -- CONTROL OF PACMAN HORIZONTAL
        C_SW0                      : in unsigned(9 downto 0);  -- CONTROL OF PACMAN VERITICAL

        R_SW1                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST1
        C_SW1                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST1
        R_SW2                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST2
        C_SW2                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST2
        R_SW3                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST3
        C_SW3                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST3
        R_SW4                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST4
        C_SW4                      : in unsigned(9 downto 0);  -- CONTROL OF GHOST4
        Eats                       : out std_logic_vector(31 downto 0);

        -- ROM ADDRESSES
        romAddressMap               : OUT vector16;       -- MAP ADDRESS
        romAddressPacmanClosed      : OUT vector10;
        romAddressPacmanOpened      : OUT vector10;
        romAddressGhost             : OUT vector10;
        romAddressFood              : OUT vector7;


        -- ROM DATA INPUT
        romMap                  : IN vector12;       -- MAP    
        romPacmanClosed         : IN vector12;
        romPacmanOpened         : IN vector12;
        romGhost                : IN vector12;
        romFood                 : IN vector12;

        --OUTPUT VGA
        red                     : OUT vector4;
        green                   : OUT vector4;
        blue                    : OUT vector4
);           
END VGA_Basic_ROM;

ARCHITECTURE Behavioral OF VGA_Basic_ROM IS

    -- DECLARATION OF SIGNALS OF SPRITE
    SIGNAL spriteOnLeftTop          : STD_LOGIC := '0';    
    SIGNAL spriteOnRightTop         : STD_LOGIC := '0';
    SIGNAL spriteOnLeftDown         : STD_LOGIC := '0';
    SIGNAL spriteOnRightDown        : STD_LOGIC := '0'; 

    SIGNAL spritePacmanClose        : STD_LOGIC := '0';   
    SIGNAL spritePacmanOpen         : STD_LOGIC := '0';

    SIGNAL spriteFood1              : STD_LOGIC := '0';
    SIGNAL spriteFood2              : STD_LOGIC := '0';
    SIGNAL spriteFood3              : STD_LOGIC := '0';
    SIGNAL spriteFood4              : STD_LOGIC := '0';
    SIGNAL spriteFood5              : STD_LOGIC := '0';
    SIGNAL spriteFood6              : STD_LOGIC := '0';
    SIGNAL spriteFood7              : STD_LOGIC := '0';
    SIGNAL spriteFood8              : STD_LOGIC := '0';
    SIGNAL spriteFood9              : STD_LOGIC := '0';
    SIGNAL spriteFood10             : STD_LOGIC := '0';
    SIGNAL spriteFood11             : STD_LOGIC := '0';
    SIGNAL spriteFood12             : STD_LOGIC := '0';
    SIGNAL spriteFood13             : STD_LOGIC := '0';
    SIGNAL spriteFood14             : STD_LOGIC := '0';
    SIGNAL spriteFood15             : STD_LOGIC := '0';
    SIGNAL spriteFood16             : STD_LOGIC := '0';
    SIGNAL spriteFood17             : STD_LOGIC := '0';
    SIGNAL spriteFood18             : STD_LOGIC := '0';
    SIGNAL spriteFood19             : STD_LOGIC := '0';
    SIGNAL spriteFood20             : STD_LOGIC := '0';
    SIGNAL spriteFood21             : STD_LOGIC := '0';
    
    SIGNAL spriteGhost1             : STD_LOGIC := '0';
    SIGNAL spriteGhost2             : STD_LOGIC := '0';
    SIGNAL spriteGhost3             : STD_LOGIC := '0';
    SIGNAL spriteGhost4             : STD_LOGIC := '0';

    -- FLAGS EATED FOOD
    SIGNAL EATED1                  : STD_LOGIC := '0';
    SIGNAL EATED2                  : STD_LOGIC := '0';
    SIGNAL EATED3                  : STD_LOGIC := '0';
    SIGNAL EATED4                  : STD_LOGIC := '0';
    SIGNAL EATED5                  : STD_LOGIC := '0';
    SIGNAL EATED6                  : STD_LOGIC := '0';
    SIGNAL EATED7                  : STD_LOGIC := '0';
    SIGNAL EATED8                  : STD_LOGIC := '0';
    SIGNAL EATED9                  : STD_LOGIC := '0';
    SIGNAL EATED10                 : STD_LOGIC := '0';   
    SIGNAL EATED11                 : STD_LOGIC := '0';
    SIGNAL EATED12                 : STD_LOGIC := '0';
    SIGNAL EATED13                 : STD_LOGIC := '0';
    SIGNAL EATED14                 : STD_LOGIC := '0';
    SIGNAL EATED15                 : STD_LOGIC := '0';
    SIGNAL EATED16                 : STD_LOGIC := '0';
    SIGNAL EATED17                 : STD_LOGIC := '0';
    SIGNAL EATED18                 : STD_LOGIC := '0';
    SIGNAL EATED19                 : STD_LOGIC := '0';
    SIGNAL EATED21                 : STD_LOGIC := '0';
    SIGNAL EATED20                 : STD_LOGIC := '0';

    -- DECLARATION OF SIGNALS COORDINATES AND ADDRESS OF ROM
    SIGNAL xpix, ypix               : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Pac, ypix_Pac       : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Food,ypix_Food      : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost1,ypix_Ghost1  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost2,ypix_Ghost2  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost3,ypix_Ghost3  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost4,ypix_Ghost4  : UNSIGNED(9 DOWNTO 0);
    SIGNAL romAddressMap_s          : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressPacmanClosed_s : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressPacmanOpened_s : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressFood_s         : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressGhost_s        : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL EATS_s                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    process(clk, rst)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                Eats <= (others => '0');
            else
                Eats <= EATS_s;
            end if;
        end if;
    end process;
       
    
    
    PROCESS (xpix_Pac, ypix_Pac, EATED1, EATED2, EATED3, 
            EATED4, EATED5, EATED6, EATED7, EATED8, EATED9, EATED10, EATED11, EATED12, 
            EATED13, EATED14, EATED15, EATED16, EATED17, EATED18, EATED19, EATED20, EATED21,rst)
    BEGIN
        IF rst = '1' THEN
            EATS_s <= (others => '0');
        ELSE
            -- IF (xpix_Pac + 60 = X_INIT_FOOD1 OR xpix_Pac - 60 = X_INIT_FOOD1)  AND (ypix_Pac + 60 = Y_INIT_FOOD1 OR ypix_Pac - 60 = Y_INIT_FOOD1 ) AND EATED1 = '0' THEN
            --     EATS_s <= EATS_s + 1 ;
            --     EATED1 <= '1';
            -- END IF;

            -- IF (C_SW0 + 60 = X_INIT_FOOD1 OR C_SW0 - 60 = X_INIT_FOOD1)  AND (R_SW0 + 60 = Y_INIT_FOOD1 OR R_SW0 - 60 = Y_INIT_FOOD1 ) AND EATED1 = '0' THEN
                -- EATS_s <= EATS_s + 1 ;
                -- EATED1 <= '1';
            -- END IF;

            -- IF (ypix_Pac + 50 = X_INIT_FOOD1 OR ypix_Pac - 50 = X_INIT_FOOD1)  AND (xpix_Pac + 50 = Y_INIT_FOOD1 OR xpix_Pac - 50 = Y_INIT_FOOD1 ) AND EATED1 = '0' THEN
            --     EATS_s <= EATS_s + 1 ;
            --     EATED1 <= '1';
            -- END IF;

            IF (R_SW0 + 60 >= X_INIT_FOOD1 OR R_SW0 - 60 <= X_INIT_FOOD1)  AND (C_SW0 + 60 >= Y_INIT_FOOD1 OR C_SW0 - 60 <= Y_INIT_FOOD1 ) AND EATED1 = '0' THEN
                EATS_s <= EATS_s + 1 ;
                EATED1 <= '1';
            END IF;

            IF (C_SW0 + 50 = X_INIT_FOOD1 OR C_SW0 - 50 = X_INIT_FOOD1)  AND (R_SW0 + 50 = Y_INIT_FOOD1 OR R_SW0 - 50 = Y_INIT_FOOD1 ) AND EATED1 = '0' THEN
                EATS_s <= EATS_s + 1 ;
                EATED1 <= '1';
            END IF;

            -- IF (C_SW0 + 20 = X_INIT_FOOD2 OR C_SW0 - 20 = X_INIT_FOOD2)  AND (R_SW0 + 20 = Y_INIT_FOOD2 OR R_SW0 - 20 = Y_INIT_FOOD2 ) AND EATED2 = '0' THEN
            --     EATS_s <= EATS_s + 1 ;
            --     EATED2 <= '1';
            -- END IF;

            IF (xpix_Pac + 30 = X_INIT_FOOD2 OR xpix_Pac - 30 = X_INIT_FOOD2)  AND (ypix_Pac + 30 = Y_INIT_FOOD2 OR ypix_Pac - 30 = Y_INIT_FOOD2 ) AND EATED2 = '0' THEN
                EATS_s <= EATS_s + 1 ;
                EATED2 <= '1';
            END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD3 OR xpix_Pac - 20 = X_INIT_FOOD3)  AND (ypix_Pac + 20 = Y_INIT_FOOD3 OR ypix_Pac - 20 = Y_INIT_FOOD3 ) AND EATED3 = '0' THEN
            --     EATS_s <= EATS_s + 1 ;
            --     EATED3 <= '1';
            -- END IF;

            -- IF (R_SW0 + 20 = X_INIT_FOOD3 OR R_SW0 - 20 = X_INIT_FOOD3)  AND (C_SW0 + 20 = Y_INIT_FOOD3 OR C_SW0 - 20 = Y_INIT_FOOD3 ) AND EATED3 = '0' THEN
            --     EATS_s <= EATS_s + 1 ;
            --     EATED3 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD4 OR xpix_Pac - 20 = X_INIT_FOOD4)  AND (ypix_Pac + 20 = Y_INIT_FOOD4 OR ypix_Pac - 20 = Y_INIT_FOOD4 ) AND EATED4 = '0' THEN
            --     EATS_s <= EATS_s + 1 ;
            --     EATED4 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD5 OR xpix_Pac - 20 = X_INIT_FOOD5) AND (ypix_Pac + 20 = Y_INIT_FOOD5 OR ypix_Pac - 20 = Y_INIT_FOOD5) AND EATED5 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED5 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD6 OR xpix_Pac - 20 = X_INIT_FOOD6) AND (ypix_Pac + 20 = Y_INIT_FOOD6 OR ypix_Pac - 20 = Y_INIT_FOOD6) AND EATED6 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED6 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD7 OR xpix_Pac - 20 = X_INIT_FOOD7) AND (ypix_Pac + 20 = Y_INIT_FOOD7 OR ypix_Pac - 20 = Y_INIT_FOOD7) AND EATED7 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED7 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD8 OR xpix_Pac - 20 = X_INIT_FOOD8) AND (ypix_Pac + 20 = Y_INIT_FOOD8 OR ypix_Pac - 20 = Y_INIT_FOOD8) AND EATED8 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED8 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD9 OR xpix_Pac - 20 = X_INIT_FOOD9) AND (ypix_Pac + 20 = Y_INIT_FOOD9 OR ypix_Pac - 20 = Y_INIT_FOOD9) AND EATED9 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED9 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD10 OR xpix_Pac - 20 = X_INIT_FOOD10) AND (ypix_Pac + 20 = Y_INIT_FOOD10 OR ypix_Pac - 20 = Y_INIT_FOOD10) AND EATED10 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED10 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD11 OR xpix_Pac - 20 = X_INIT_FOOD11) AND (ypix_Pac + 20 = Y_INIT_FOOD11 OR ypix_Pac - 20 = Y_INIT_FOOD11) AND EATED11 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED11 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD12 OR xpix_Pac - 20 = X_INIT_FOOD12) AND (ypix_Pac + 20 = Y_INIT_FOOD12 OR ypix_Pac - 20 = Y_INIT_FOOD12) AND EATED12 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED12 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD13 OR xpix_Pac - 20 = X_INIT_FOOD13) AND (ypix_Pac + 20 = Y_INIT_FOOD13 OR ypix_Pac - 20 = Y_INIT_FOOD13) AND EATED13 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED13 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD14 OR xpix_Pac - 20 = X_INIT_FOOD14) AND (ypix_Pac + 20 = Y_INIT_FOOD14 OR ypix_Pac - 20 = Y_INIT_FOOD14) AND EATED14 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED14 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD15 OR xpix_Pac - 20 = X_INIT_FOOD15) AND (ypix_Pac + 20 = Y_INIT_FOOD15 OR ypix_Pac - 20 = Y_INIT_FOOD15) AND EATED15 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED15 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD16 OR xpix_Pac - 20 = X_INIT_FOOD16) AND (ypix_Pac + 20 = Y_INIT_FOOD16 OR ypix_Pac - 20 = Y_INIT_FOOD16) AND EATED16 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED16 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD17 OR xpix_Pac - 20 = X_INIT_FOOD17) AND (ypix_Pac + 20 = Y_INIT_FOOD17 OR ypix_Pac - 20 = Y_INIT_FOOD17) AND EATED17 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED17 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD18 OR xpix_Pac - 20 = X_INIT_FOOD18) AND (ypix_Pac + 20 = Y_INIT_FOOD18 OR ypix_Pac - 20 = Y_INIT_FOOD18) AND EATED18 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED18 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD19 OR xpix_Pac - 20 = X_INIT_FOOD19) AND (ypix_Pac + 20 = Y_INIT_FOOD19 OR ypix_Pac - 20 = Y_INIT_FOOD19) AND EATED19 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED19 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD20 OR xpix_Pac - 20 = X_INIT_FOOD20) AND (ypix_Pac + 20 = Y_INIT_FOOD20 OR ypix_Pac - 20 = Y_INIT_FOOD20) AND EATED20 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED20 <= '1';
            -- END IF;

            -- IF (xpix_Pac + 20 = X_INIT_FOOD21 OR xpix_Pac - 20 = X_INIT_FOOD21) AND (ypix_Pac + 20 = Y_INIT_FOOD21 OR ypix_Pac - 20 = Y_INIT_FOOD21) AND EATED21 = '0' THEN
            --     EATS_s <= EATS_s + 1;
            --     EATED21 <= '1';
            -- END IF;
        END IF;



        -- IF (xpix_Pac + 20 = X_INIT_FOOD1 OR xpix_Pac - 20 = X_INIT_FOOD1)  AND (ypix + 20 = Y_INIT_FOOD1 OR ypix + 20 = Y_INIT_FOOD1 ) AND EATED1 = '0' THEN
        --     EATS_s <= EATS_s + 1 ;
        --     EATED1 <= '1';
        -- END IF;

        -- IF R_SW0 = X_INIT_FOOD1 AND C_SW0 = Y_INIT_FOOD1 AND EATED1 = '0' THEN
        --     EATS_s <= EATS_s + 1 ;
        --     EATED1 <= '1';
        -- END IF;
    END PROCESS;



    PROCESS (vc,hc,R_SW0,C_SW0,xpix,ypix,romAddressMap_s,romAddressPacmanOpened_s,
    ypix_Pac,xpix_Pac, romAddressFood_s, ypix_Food, xpix_Food,xpix_Ghost1,ypix_Ghost1,
    xpix_Ghost2,ypix_Ghost2, xpix_Ghost3,ypix_Ghost3,xpix_Ghost4,ypix_Ghost4,romAddressGhost_s)
    BEGIN
    --                                      PACMANS
    --  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        IF (unsigned(hc) >= R_SW0 + hbp AND unsigned(hc) < R_SW0 + hbp + WPacmanOpen AND
            unsigned(vc) >= C_SW0 + vbp AND unsigned(vc) < C_SW0 + vbp + HPacmanOpen) THEN
            xpix_Pac <= unsigned(hc) - (hbp + R_SW0);   
            ypix_Pac <= unsigned(vc) - (vbp + C_SW0);      
            romAddressPacmanOpened_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Pac, WPacmanOpen) + xpix_Pac);
            romAddressPacmanOpened <= romAddressPacmanOpened_s(9 downto 0);
            spritePacmanOpen <= '1';
        ELSE
            spritePacmanOpen <= '0';
        END IF;
    
        IF (unsigned(hc) >= R_SW0 + hbp AND unsigned(hc) < R_SW0 + hbp + WPacmanClose AND
            unsigned(vc) >= C_SW0 + vbp AND unsigned(vc) < C_SW0 + vbp + HPacmanClose) THEN
            xpix_Pac <= unsigned(hc) - (hbp + R_SW0);      
            ypix_Pac <= unsigned(vc) - (vbp + C_SW0);    
            romAddressPacmanClosed_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Pac, WPacmanClose) + xpix_Pac);
            romAddressPacmanClosed <= romAddressPacmanClosed_s(9 downto 0);
            spritePacmanClose <= '1';
        ELSE
            spritePacmanClose <= '0';
        END IF;
    --                                      FOODS
    --  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        IF (unsigned(hc) >= X_INIT_FOOD1 + hbp AND unsigned(hc) < X_INIT_FOOD1 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD1 + vbp AND unsigned(vc) < Y_INIT_FOOD1 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD1);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD1);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood1 <= '1';
        ELSE
            spriteFood1 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD2 + hbp AND unsigned(hc) < X_INIT_FOOD2 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD2 + vbp AND unsigned(vc) < Y_INIT_FOOD2 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD2);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD2);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood2 <= '1';
        ELSE
            spriteFood2 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD3 + hbp AND unsigned(hc) < X_INIT_FOOD3 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD3 + vbp AND unsigned(vc) < Y_INIT_FOOD3 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD3);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD3);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood3 <= '1';
        ELSE
            spriteFood3 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD4 + hbp AND unsigned(hc) < X_INIT_FOOD4 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD4 + vbp AND unsigned(vc) < Y_INIT_FOOD4 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD4);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD4);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood4 <= '1';
        ELSE
            spriteFood4 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD5 + hbp AND unsigned(hc) < X_INIT_FOOD5 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD5 + vbp AND unsigned(vc) < Y_INIT_FOOD5 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD5);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD5);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood5 <= '1';
        ELSE
            spriteFood5 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD6 + hbp AND unsigned(hc) < X_INIT_FOOD6 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD6 + vbp AND unsigned(vc) < Y_INIT_FOOD6 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD6);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD6);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood6 <= '1';
        ELSE
            spriteFood6 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD7 + hbp AND unsigned(hc) < X_INIT_FOOD7 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD7 + vbp AND unsigned(vc) < Y_INIT_FOOD7 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD7);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD7);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood7 <= '1';
        ELSE
            spriteFood7 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD8 + hbp AND unsigned(hc) < X_INIT_FOOD8 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD8 + vbp AND unsigned(vc) < Y_INIT_FOOD8 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD8);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD8);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood8 <= '1';
        ELSE
            spriteFood8 <= '0';
        END IF;


        IF (unsigned(hc) >= X_INIT_FOOD9 + hbp AND unsigned(hc) < X_INIT_FOOD9 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD9 + vbp AND unsigned(vc) < Y_INIT_FOOD9 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD9);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD9);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood9 <= '1';
        ELSE
            spriteFood9 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD10 + hbp AND unsigned(hc) < X_INIT_FOOD10 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD10 + vbp AND unsigned(vc) < Y_INIT_FOOD10 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD10);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD10);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood10 <= '1';
        ELSE
            spriteFood10 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD11 + hbp AND unsigned(hc) < X_INIT_FOOD11 + hbp +WFood AND
            unsigned(vc) >= Y_INIT_FOOD11 + vbp AND unsigned(vc) < Y_INIT_FOOD11 + vbp +HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD11);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD11);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood11 <= '1';
        ELSE
            spriteFood11 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD12 + hbp AND unsigned(hc) < X_INIT_FOOD12 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD12 + vbp AND unsigned(vc) < Y_INIT_FOOD12 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD12);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD12);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood12 <= '1';
        ELSE
            spriteFood12 <= '0';
        END IF;


        IF (unsigned(hc) >= X_INIT_FOOD13 + hbp AND unsigned(hc) < X_INIT_FOOD13 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD13 + vbp AND unsigned(vc) < Y_INIT_FOOD13 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD13);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD13);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood13 <= '1';
        ELSE
            spriteFood13 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD14 + hbp AND unsigned(hc) < X_INIT_FOOD14 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD14 + vbp AND unsigned(vc) < Y_INIT_FOOD14 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD14);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD14);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood14 <= '1';
        ELSE
            spriteFood14 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD15 + hbp AND unsigned(hc) < X_INIT_FOOD15 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD15 + vbp AND unsigned(vc) < Y_INIT_FOOD15 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD15);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD15);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood15 <= '1';
        ELSE
            spriteFood15 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD16 + hbp AND unsigned(hc) < X_INIT_FOOD16 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD16 + vbp AND unsigned(vc) < Y_INIT_FOOD16 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD16);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD16);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood16 <= '1';
        ELSE
            spriteFood16 <= '0';
        END IF;
        IF (unsigned(hc) >= X_INIT_FOOD17 + hbp AND unsigned(hc) < X_INIT_FOOD17 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD17 + vbp AND unsigned(vc) < Y_INIT_FOOD17 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD17);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD17);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood17 <= '1';
        ELSE
            spriteFood17 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD18 + hbp AND unsigned(hc) < X_INIT_FOOD18 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD18 + vbp AND unsigned(vc) < Y_INIT_FOOD18 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD18);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD18);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood18 <= '1';
        ELSE
            spriteFood18 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD19 + hbp AND unsigned(hc) < X_INIT_FOOD19 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD19 + vbp AND unsigned(vc) < Y_INIT_FOOD19 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD19);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD19);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood19 <= '1';
        ELSE
            spriteFood19 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD20 + hbp AND unsigned(hc) < X_INIT_FOOD20 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD20 + vbp AND unsigned(vc) < Y_INIT_FOOD20 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD20);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD20);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood20 <= '1';
        ELSE
            spriteFood20 <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_FOOD21 + hbp AND unsigned(hc) < X_INIT_FOOD21 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD21 + vbp AND unsigned(vc) < Y_INIT_FOOD21 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD21);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD21);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood21 <= '1';
        ELSE
            spriteFood21 <= '0';
        END IF;

    --                                      GHOSTS
    --  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        IF (unsigned(hc) >= R_SW1 + hbp AND unsigned(hc) < R_SW1 + hbp + WGhost AND
            unsigned(vc) >= C_SW1 + vbp AND unsigned(vc) < C_SW1 + vbp + HGhost) THEN
            xpix_Ghost1 <= unsigned(hc) - (hbp + R_SW1);   
            ypix_Ghost1 <= unsigned(vc) - (vbp + C_SW1);      
            romAddressGhost_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Ghost1, WGhost) + xpix_Ghost1);
            romAddressGhost <= romAddressGhost_s(9 downto 0);
            spriteGhost1 <= '1';
        ELSE
            spriteGhost1 <= '0';
        END IF;

        IF (unsigned(hc) >= R_SW2 + hbp AND unsigned(hc) < R_SW2 + hbp + WGhost AND
            unsigned(vc) >= C_SW2 + vbp AND unsigned(vc) < C_SW2 + vbp + HGhost) THEN
            xpix_Ghost2 <= unsigned(hc) - (hbp + R_SW2);   
            ypix_Ghost2 <= unsigned(vc) - (vbp + C_SW2);      
            romAddressGhost_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Ghost2, WGhost) + xpix_Ghost2);
            romAddressGhost <= romAddressGhost_s(9 downto 0);
            spriteGhost2 <= '1';
        ELSE
            spriteGhost2 <= '0';
        END IF;

        IF (unsigned(hc) >= R_SW3 + hbp AND unsigned(hc) < R_SW3 + hbp + WGhost AND
            unsigned(vc) >= C_SW3 + vbp AND unsigned(vc) < C_SW3 + vbp + HGhost) THEN
            xpix_Ghost3 <= unsigned(hc) - (hbp + R_SW3);   
            ypix_Ghost3 <= unsigned(vc) - (vbp + C_SW3);      
            romAddressGhost_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Ghost3, WGhost) + xpix_Ghost3);
            romAddressGhost <= romAddressGhost_s(9 downto 0);
            spriteGhost3 <= '1';
        ELSE
            spriteGhost3 <= '0';
        END IF;

        IF (unsigned(hc) >= R_SW4 + hbp AND unsigned(hc) < R_SW4 + hbp + WGhost AND
            unsigned(vc) >= C_SW4 + vbp AND unsigned(vc) < C_SW4 + vbp + HGhost) THEN
            xpix_Ghost4 <= unsigned(hc) - (hbp + R_SW4);   
            ypix_Ghost4 <= unsigned(vc) - (vbp + C_SW4);      
            romAddressGhost_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Ghost4, WGhost) + xpix_Ghost4);
            romAddressGhost <= romAddressGhost_s(9 downto 0);
            spriteGhost4 <= '1';
        ELSE
            spriteGhost4 <= '0';
        END IF;

    --                                      MAP
    --  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        IF (unsigned(hc) >= X_INIT_MAP + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap AND
            unsigned(vc) >= Y_INIT_MAP + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + HMap) THEN
            xpix <= unsigned(hc) - (hbp + X_INIT_MAP);   
            ypix <= unsigned(vc) - (vbp + Y_INIT_MAP);      
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnLeftTop <= '1';
        ELSE
            spriteOnLeftTop <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_MAP + WMap + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap + WMap AND
            unsigned(vc) >= Y_INIT_MAP + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + HMap) THEN
            xpix <= (WMap - 1) - (unsigned(hc) - (hbp + X_INIT_MAP + WMap));   
            ypix <= unsigned(vc) - (vbp + Y_INIT_MAP);                      
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnRightTop <= '1';
        ELSE
            spriteOnRightTop <= '0';
        END IF; 
        
        IF (unsigned(hc) >= X_INIT_MAP + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap AND
            unsigned(vc) >= Y_INIT_MAP + HMap + vbp AND unsigned(vc) < Y_INIT_MAP + vbp + HMap + HMap ) THEN
            xpix <= unsigned(hc) - (hbp + X_INIT_MAP);
            ypix <= HMap - 1 - (unsigned(vc) - (vbp + Y_INIT_MAP) - HMap);  
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnLeftDown <= '1';
        ELSE
            spriteOnLeftDown <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_MAP + WMap + hbp AND unsigned(hc) < X_INIT_MAP + hbp + WMap + WMap AND
            unsigned(vc) >= Y_INIT_MAP + HMap + vbp  AND unsigned(vc) < Y_INIT_MAP + vbp + HMap + HMap ) THEN
            xpix <= WMap - 1 - (unsigned(hc) - (X_INIT_MAP + WMap + hbp));
            ypix <= HMap - 1 - (unsigned(vc) - (Y_INIT_MAP + HMap + vbp));        
            romAddressMap_s <= STD_LOGIC_VECTOR(TotalPixels(ypix, WMap) + xpix);
            romAddressMap <= romAddressMap_s(15 downto 0);
            spriteOnRightDown <= '1';
        ELSE
            spriteOnRightDown <= '0';
        END IF;
    END PROCESS;

    PROCESS (spriteOnLeftTop, spriteOnRightTop, spriteOnLeftDown, spriteOnRightDown, 
            spritePacmanOpen, spritePacmanClose, vidon, sw, romMap, romPacmanOpened,
            romPacmanClosed, romFood, spriteFood1, spriteFood2, spriteFood3, spriteFood4,
            spriteFood5, spriteFood6, spriteFood7, spriteFood8, spriteFood9, spriteFood10,
            spriteFood11, spriteFood12, spriteFood13, spriteFood14, spriteFood15, spriteFood16,
            spriteFood17, spriteFood18, spriteFood19, spriteFood20, spriteFood21, spriteGhost1,
            spriteGhost2, spriteGhost3, spriteGhost4, romGhost, EATED1, EATED2, EATED3, 
            EATED4, EATED5, EATED6, EATED7, EATED8, EATED9, EATED10, EATED11, EATED12, 
            EATED13, EATED14, EATED15, EATED16, EATED17, EATED18, EATED19, EATED20, EATED21)
    BEGIN
        red <= (OTHERS => '0');
        green <= (OTHERS => '0');
        blue <= (OTHERS => '0');

        IF vidon = '1' AND spriteFood1 = '1' AND EATED1 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood2 = '1' AND EATED2 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood3 = '1' AND EATED3 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood4 = '1' AND EATED4 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood5 = '1' AND EATED5 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood6 = '1' AND EATED6 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood7 = '1' AND EATED7 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood8 = '1' AND EATED8 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood9 = '1' AND EATED9 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood10 = '1' AND EATED10 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood11 = '1' AND EATED11 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood12 = '1' AND EATED12 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood13 = '1' AND EATED13 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood14 = '1' AND EATED14 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood15 = '1' AND EATED15 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood16 = '1' AND EATED16 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood17 = '1' AND EATED17 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood18 = '1' AND EATED18 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood19 = '1' AND EATED19 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
            ELSIF vidon = '1' AND spriteFood20 = '1' AND EATED20 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteFood21 = '1' AND EATED21 = '0' THEN
            red   <= romFood(11 DOWNTO 8);
            green <= romFood(7 DOWNTO 4);
            blue  <= romFood(3 DOWNTO 0);

        ELSIF vidon = '1' AND spritePacmanOpen = '1' AND changePacman = '1' THEN
            IF romPacmanOpened = x"FFF" THEN
                red   <= romMap(11 DOWNTO 8);
                green <= romMap(7 DOWNTO 4);
                blue  <= romMap(3 DOWNTO 0);
            ELSE
                red   <= romPacmanOpened(11 DOWNTO 8);
                green <= romPacmanOpened(7 DOWNTO 4);
                blue  <= romPacmanOpened(3 DOWNTO 0);
            END IF;
        ELSIF vidon='1' AND spritePacmanClose = '1' AND changePacman = '0' THEN
            IF romPacmanClosed = x"FFF" THEN                    
                red   <= romMap(11 DOWNTO 8);
                green <= romMap(7 DOWNTO 4);
                blue  <= romMap(3 DOWNTO 0);
            ELSE
                red   <= romPacmanClosed(11 DOWNTO 8);
                green <= romPacmanClosed(7 DOWNTO 4);
                blue  <= romPacmanClosed(3 DOWNTO 0);
            END IF;
        ELSIF vidon = '1' AND spriteGhost1 = '1' THEN       -- BLUE
            IF romGhost = x"FFF" THEN       
                red   <= romMap(11 DOWNTO 8);
                green <= romMap(7 DOWNTO 4);
                blue  <= romMap(3 DOWNTO 0);
            ELSE
                red   <= romGhost(11 DOWNTO 8) ;
                green <= romGhost(7 DOWNTO 4);
                blue  <= romGhost(3 DOWNTO 0);
            END IF;
        ELSIF vidon = '1' AND spriteGhost2 = '1' THEN       -- RED
            IF romGhost = x"FFF" THEN
                red   <= romMap(11 DOWNTO 8);
                green <= romMap(7 DOWNTO 4);
                blue  <= romMap(3 DOWNTO 0);
            ELSE
                red   <= romGhost(11 DOWNTO 8) OR "0100"; -- Aumenta o vermelho adicionando um valor
                green <= romGhost(7 DOWNTO 4);
                blue  <= romGhost(3 DOWNTO 0) AND "0111"; -- Diminui o azul removendo um valor
            END IF;
        ELSIF vidon = '1' AND spriteGhost3 = '1' THEN       -- PINK
            IF romGhost = x"FFF" THEN
                red   <= romMap(11 DOWNTO 8);
                green <= romMap(7 DOWNTO 4);
                blue  <= romMap(3 DOWNTO 0);
            ELSE
                red   <= "1111"; -- Máximo de vermelho
                green <= romGhost(7 DOWNTO 4); -- Mantém o valor original de verde, ajuste conforme necessário
                blue  <= "1011"; -- Alto valor de azul, mas não o máximo, para dar uma tonalidade rosa

            END IF;
        ELSIF vidon = '1' AND spriteGhost4 = '1' THEN           -- GREEN
            IF romGhost = x"FFF" THEN
                red   <= romMap(11 DOWNTO 8);
                green <= romMap(7 DOWNTO 4);
                blue  <= romMap(3 DOWNTO 0);
            ELSE
                red   <= romGhost(11 DOWNTO 8);
                green <= "0111"; -- Aumenta o verde
                blue  <= romGhost(3 DOWNTO 0);
            END IF;
            
        ELSIF vidon = '1' AND spriteOnLeftTop = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnRightTop = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnLeftDown = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' AND spriteOnRightDown = '1' THEN
            red   <= romMap(11 DOWNTO 8);
            green <= romMap(7 DOWNTO 4);
            blue  <= romMap(3 DOWNTO 0);
        ELSIF vidon = '1' THEN
            red   <= sw(11 downto 8) ;
		    green <= sw(7 downto 4);
		    blue  <= sw(3 downto 0); 

        END IF;
    END PROCESS;

END Behavioral;