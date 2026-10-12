----------------------------------------------------------------------------------
-- tb_traffic_light_ext.vhd
-- Testbench untuk traffic_light_top_ext (all-red + durasi hijau via switch).
-- CLK_FREQ_HZ = 10 -> 1 "detik" = 10 siklus clock = 100 ns.
-- Skenario:
--   0     - 1 us : sw = "0101" (hijau 10 s), satu siklus penuh = 28 tick = 2,8 us
--   1 us          : sw diubah ke "0000" (hijau 5 s); berlaku di fase hijau berikutnya
-- Jalankan simulasi minimal 8 us.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_traffic_light_ext is
end tb_traffic_light_ext;

architecture sim of tb_traffic_light_ext is

    component traffic_light_top_ext is
        Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
        Port ( clk  : in  STD_LOGIC;
               btnC : in  STD_LOGIC;
               sw   : in  STD_LOGIC_VECTOR (3 downto 0);
               led  : out STD_LOGIC_VECTOR (5 downto 0) );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal btnC : STD_LOGIC := '1';
    signal sw   : STD_LOGIC_VECTOR (3 downto 0) := "0101";
    signal led  : STD_LOGIC_VECTOR (5 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    function onehot(v : STD_LOGIC_VECTOR(2 downto 0)) return boolean is
    begin
        return v = "001" or v = "010" or v = "100";
    end function;

begin

    uut : traffic_light_top_ext
        generic map ( CLK_FREQ_HZ => 10 )
        port map ( clk => clk, btnC => btnC, sw => sw, led => led );

    clk <= not clk after CLK_PERIOD / 2;

    stim : process
    begin
        btnC <= '1';
        wait for 50 ns;
        btnC <= '0';
        wait for 950 ns;          -- t = 1 us
        sw <= "0000";             -- hijau menjadi 5 s (berlaku di fase hijau berikutnya)
        wait for 7 us;
        report "Simulasi selesai" severity note;
        wait;
    end process;

    -- Tiap arah tepat 1 LED menyala; kedua arah tak pernah hijau bersamaan
    check : process(led)
    begin
        if btnC = '0' then
            assert onehot(led(2 downto 0))
                report "Arah NS: tidak tepat satu LED menyala" severity error;
            assert onehot(led(5 downto 3))
                report "Arah EW: tidak tepat satu LED menyala" severity error;
            assert not (led(0) = '1' and led(3) = '1')
                report "BAHAYA: kedua arah hijau bersamaan" severity failure;
        end if;
    end process;

end sim;