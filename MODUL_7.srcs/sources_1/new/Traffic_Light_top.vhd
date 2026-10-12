----------------------------------------------------------------------------------
-- traffic_light_top.vhd
-- Top-level versi dasar: pulse_1s + traffic_light_fsm
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_top is
    Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
    Port ( clk  : in  STD_LOGIC;                        -- 100 MHz
           btnC : in  STD_LOGIC;                        -- reset
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_top;

architecture Structural of traffic_light_top is

    component pulse_1s is
        Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
        Port ( clk  : in  STD_LOGIC;
               rst  : in  STD_LOGIC;
               tick : out STD_LOGIC );
    end component;

    component traffic_light_fsm is
        Generic ( T_GREEN  : integer := 10;
                  T_YELLOW : integer := 3 );
        Port ( clk  : in  STD_LOGIC;
               rst  : in  STD_LOGIC;
               tick : in  STD_LOGIC;
               led  : out STD_LOGIC_VECTOR (5 downto 0) );
    end component;

    signal tick : STD_LOGIC;

begin

    u_tick : pulse_1s
        generic map ( CLK_FREQ_HZ => CLK_FREQ_HZ )
        port map ( clk => clk, rst => btnC, tick => tick );

    u_fsm : traffic_light_fsm
        generic map ( T_GREEN => 10, T_YELLOW => 3 )
        port map ( clk => clk, rst => btnC, tick => tick, led => led );

end Structural;