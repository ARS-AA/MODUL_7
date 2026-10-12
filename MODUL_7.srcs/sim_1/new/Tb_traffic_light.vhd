----------------------------------------------------------------------------------
-- tb_traffic_light.vhd
-- Testbench versi dasar. CLK_FREQ_HZ dikecilkan menjadi 10 agar 1 "detik"
-- = 10 siklus clock (100 ns), sehingga simulasi singkat.
-- 1 siklus penuh = (10+3+10+3) = 26 "detik" = 2,6 us. Jalankan simulasi >= 6 us.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_traffic_light is
end tb_traffic_light;

architecture sim of tb_traffic_light is

    component traffic_light_top is
        Generic ( CLK_FREQ_HZ : integer := 100_000_000 );
        Port ( clk  : in  STD_LOGIC;
               btnC : in  STD_LOGIC;
               led  : out STD_LOGIC_VECTOR (5 downto 0) );
    end component;

    signal clk  : STD_LOGIC := '0';
    signal btnC : STD_LOGIC := '1';
    signal led  : STD_LOGIC_VECTOR (5 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    function onehot(v : STD_LOGIC_VECTOR(2 downto 0)) return boolean is
    begin
        return v = "001" or v = "010" or v = "100";
    end function;

begin

    uut : traffic_light_top
        generic map ( CLK_FREQ_HZ => 10 )
        port map ( clk => clk, btnC => btnC, led => led );

    clk <= not clk after CLK_PERIOD / 2;

    stim : process
    begin
        btnC <= '1';
        wait for 50 ns;
        btnC <= '0';
        wait for 6 us;
        report "Simulasi selesai" severity note;
        wait;
    end process;

    -- Pengecekan: tiap arah tepat 1 LED menyala, dan kedua arah tak pernah hijau bersamaan
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