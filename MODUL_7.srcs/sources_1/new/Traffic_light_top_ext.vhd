----------------------------------------------------------------------------------
-- traffic_light_top_ext.vhd
-- Top-level versi lanjutan (all-red + durasi hijau via switch)
-- Gunakan SALAH SATU top: traffic_light_top (dasar) ATAU traffic_light_top_ext
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_top_ext is
    Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
    Port ( clk  : in  STD_LOGIC;
           btnC : in  STD_LOGIC;
           sw   : in  STD_LOGIC_VECTOR (3 downto 0);
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_top_ext;

architecture Structural of traffic_light_top_ext is

    component pulse_1s is
        Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
        Port ( clk  : in  STD_LOGIC;
               rst  : in  STD_LOGIC;
               tick : out STD_LOGIC );
    end component;

    component traffic_light_fsm_ext is
        Generic ( T_YELLOW : integer := 3;
                  T_ALLRED : integer := 1 );
        Port ( clk  : in  STD_LOGIC;
               rst  : in  STD_LOGIC;
               tick : in  STD_LOGIC;
               sw   : in  STD_LOGIC_VECTOR (3 downto 0);
               led  : out STD_LOGIC_VECTOR (5 downto 0) );
    end component;

    signal tick : STD_LOGIC;

begin

    u_tick : pulse_1s
        generic map ( CLK_FREQ_HZ => CLK_FREQ_HZ )
        port map ( clk => clk, rst => btnC, tick => tick );

    u_fsm : traffic_light_fsm_ext
        generic map ( T_YELLOW => 3, T_ALLRED => 1 )
        port map ( clk => clk, rst => btnC, tick => tick, sw => sw, led => led );

end Structural;