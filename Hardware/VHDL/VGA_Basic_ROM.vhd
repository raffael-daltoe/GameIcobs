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
        Register_Foods             : in STD_LOGIC_VECTOR(31 DOWNTO 0); 

        win                        : IN STD_LOGIC;
        lose                       : IN STD_LOGIC;

        -- ROM ADDRESSES
        romAddressMap               : OUT vector16;       -- MAP ADDRESS
        romAddressPacmanClosed      : OUT vector10;
        romAddressPacmanOpened      : OUT vector10;
        romAddressGhost             : OUT vector10;
        romAddressFood              : OUT vector7;
        romAddressLoser             : OUT vector12; 
        romAddressWinner            : OUT vector11;
  

        -- ROM DATA INPUT
        romMap                  : IN vector12;       -- MAP    
        romPacmanClosed         : IN vector12;
        romPacmanOpened         : IN vector12;
        romGhost                : IN vector12;
        romFood                 : IN vector12;
        romLoser                : IN vector12;
        romWinner               : IN vector12;
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

    SIGNAL spriteFood0             : STD_LOGIC := '0';
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
    
    SIGNAL spriteGhost1             : STD_LOGIC := '0';
    SIGNAL spriteGhost2             : STD_LOGIC := '0';
    SIGNAL spriteGhost3             : STD_LOGIC := '0';
    SIGNAL spriteGhost4             : STD_LOGIC := '0';

    SIGNAL spriteLoser              : STD_LOGIC := '0';
    SIGNAL spriteWinner             : STD_LOGIC := '0';

    -- DECLARATION OF SIGNALS COORDINATES AND ADDRESS OF ROM
    SIGNAL xpix, ypix               : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Pac, ypix_Pac       : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Food,ypix_Food      : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost1,ypix_Ghost1  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost2,ypix_Ghost2  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost3,ypix_Ghost3  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Ghost4,ypix_Ghost4  : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Winner, ypix_Winner : UNSIGNED(9 DOWNTO 0);
    SIGNAL xpix_Loser, ypix_Loser   : UNSIGNED(9 DOWNTO 0);

    SIGNAL romAddressMap_s          : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressPacmanClosed_s : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressPacmanOpened_s : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressFood_s         : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressGhost_s        : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressLoser_s        : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL romAddressWinner_s        : STD_LOGIC_VECTOR(19 DOWNTO 0);
    
BEGIN


    PROCESS (vc,hc,R_SW0,C_SW0,xpix,ypix,romAddressMap_s,romAddressPacmanOpened_s,
    ypix_Pac,xpix_Pac, romAddressFood_s, ypix_Food, xpix_Food,xpix_Ghost1,ypix_Ghost1,
    xpix_Ghost2,ypix_Ghost2, xpix_Ghost3,ypix_Ghost3,xpix_Ghost4,ypix_Ghost4,romAddressGhost_s,
    xpix_Loser, ypix_Loser, romAddressLoser_s)
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
        IF (unsigned(hc) >= X_INIT_FOOD0 + hbp AND unsigned(hc) < X_INIT_FOOD0 + hbp + WFood AND
            unsigned(vc) >= Y_INIT_FOOD0 + vbp AND unsigned(vc) < Y_INIT_FOOD0 + vbp + HFood) THEN
            xpix_Food <= unsigned(hc) - (hbp + X_INIT_FOOD0);      
            ypix_Food <= unsigned(vc) - (vbp + Y_INIT_FOOD0);    
            romAddressFood_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Food, WFood) + xpix_Food);
            romAddressFood <= romAddressFood_s(6 downto 0);
            spriteFood0 <= '1';
        ELSE
            spriteFood0 <= '0';
        END IF;

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

    --                                      LOSER && WINNER
    --  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        IF (unsigned(hc) >= X_INIT_WINNER + hbp AND unsigned(hc) < X_INIT_WINNER + hbp + WWINNER AND
            unsigned(vc) >= Y_INIT_WINNER + vbp AND unsigned(vc) < Y_INIT_WINNER + vbp + HWINNER) THEN
            xpix_Winner <= unsigned(hc) - (hbp + X_INIT_WINNER);      
            ypix_Winner <= unsigned(vc) - (vbp + Y_INIT_WINNER);    
            romAddressWinner_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Winner, WWINNER) + xpix_Winner);
            romAddressWinner <= romAddressWinner_s(10 downto 0);
            spriteWinner <= '1';
        ELSE
            spriteWinner <= '0';
        END IF;

        IF (unsigned(hc) >= X_INIT_LOSER + hbp AND unsigned(hc) < X_INIT_LOSER + hbp + WLOSER AND
            unsigned(vc) >= Y_INIT_LOSER + vbp AND unsigned(vc) < Y_INIT_LOSER + vbp + HLOSER) THEN
            xpix_Loser <= unsigned(hc) - (hbp + X_INIT_LOSER);      
            ypix_Loser <= unsigned(vc) - (vbp + Y_INIT_LOSER);    
            romAddressLoser_s <= STD_LOGIC_VECTOR(TotalPixels(ypix_Loser, WLOSER) + xpix_Loser);
            romAddressLoser <= romAddressLoser_s(11 downto 0);
            spriteLoser <= '1';
        ELSE
            spriteLoser <= '0';
        END IF;

    END PROCESS;

    PROCESS (spriteOnLeftTop, spriteOnRightTop, spriteOnLeftDown, spriteOnRightDown, 
            spritePacmanOpen, spritePacmanClose, vidon, sw, romMap, romPacmanOpened,
            romPacmanClosed, romFood,spriteFood0, spriteFood1, spriteFood2, spriteFood3, spriteFood4,
            spriteFood5, spriteFood6, spriteFood7, spriteFood8, spriteFood9, spriteFood10,
            spriteFood11, spriteFood12, spriteFood13, spriteFood14, spriteFood15, spriteFood16,
            spriteFood17, spriteFood18, spriteFood19, spriteFood20, spriteGhost1,
            spriteGhost2, spriteGhost3, spriteGhost4, romGhost, Register_Foods,win,spriteWinner,
            lose,spriteLoser)
    BEGIN
         red <= (OTHERS => '0');
         green <= (OTHERS => '0');
         blue <= (OTHERS => '0');

        IF win = '1' AND spriteWinner = '1' AND vidon = '1' THEN
            red   <= romWinner(11 DOWNTO 8);
            green <= romWinner(7 DOWNTO 4);
            blue  <= romWinner(3 DOWNTO 0);
        ELSIF lose = '1' AND spriteLoser = '1' AND vidon = '1'  THEN
            red   <= romLoser(11 DOWNTO 8);
            green <= romLoser(7 DOWNTO 4);
            blue  <= romLoser(3 DOWNTO 0);
        ELSIF lose = '0' AND win = '0' THEN
            IF vidon = '1' AND spritePacmanOpen = '1' AND changePacman = '1' THEN
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

            ELSIF vidon = '1' AND spriteFood0 = '1' THEN
                IF Register_Foods(0) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood1 = '1' THEN
                IF Register_Foods(1) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood2 = '1' THEN
                IF Register_Foods(2) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood3 = '1' THEN
                IF Register_Foods(3) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood4 = '1' THEN
                IF Register_Foods(4) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood5 = '1' THEN
                IF Register_Foods(5) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood6 = '1' THEN
                IF Register_Foods(6) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood7 = '1' THEN
                IF Register_Foods(7) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood8 = '1' THEN
                IF Register_Foods(8) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood9 = '1' THEN
                IF Register_Foods(9) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood10 = '1' THEN
                IF Register_Foods(10) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood11 = '1' THEN
                IF Register_Foods(11) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood12 = '1' THEN
                IF Register_Foods(12) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood13 = '1' THEN
                IF Register_Foods(13) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood14 = '1' THEN
                IF Register_Foods(14) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood15 = '1' THEN
                IF Register_Foods(15) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood16 = '1'  THEN
                IF Register_Foods(16) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood17 = '1' THEN
                IF Register_Foods(17) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood18 = '1' THEN
                IF Register_Foods(18) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood19 = '1' THEN
                IF Register_Foods(19) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                END IF;
            ELSIF vidon = '1' AND spriteFood20 = '1'  THEN
                IF Register_Foods(20) = '0' THEN 
                    red   <= romFood(11 DOWNTO 8);
                    green <= romFood(7 DOWNTO 4);
                    blue  <= romFood(3 DOWNTO 0);
                ELSE
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
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
                    red   <= romGhost(11 DOWNTO 8) OR "0100"; -- Increase the red
                    green <= romGhost(7 DOWNTO 4);
                    blue  <= romGhost(3 DOWNTO 0) AND "0111"; -- Decrease the blue
                END IF;
            ELSIF vidon = '1' AND spriteGhost3 = '1' THEN       -- PINK
                IF romGhost = x"FFF" THEN
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                ELSE
                    red   <= "1111"; -- Max of red
                    green <= romGhost(7 DOWNTO 4); 
                    blue  <= "1011"; -- High value of blue 

                END IF;
            ELSIF vidon = '1' AND spriteGhost4 = '1' THEN           -- GREEN
                IF romGhost = x"FFF" THEN
                    red   <= romMap(11 DOWNTO 8);
                    green <= romMap(7 DOWNTO 4);
                    blue  <= romMap(3 DOWNTO 0);
                ELSE
                    red   <= romGhost(11 DOWNTO 8);
                    green <= "0111"; -- Increase the green
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
        END IF;
    END PROCESS;

END Behavioral;