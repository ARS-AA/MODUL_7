----------------------------------------------------------------------------------
-- traffic_light_fsm_ext.vhd
-- Versi lanjutan (Tugas 1 dan 2):
--   * 6 state, ada fase ALL_RED (jeda keselamatan) di antara pergantian arah
--   * Durasi hijau = 5 + sw (detik)  -> 5 s sampai 20 s
--   * sw dibaca saat state baru dimuat (perubahan sw berlaku di fase berikutnya)
-- Urutan: NS_HIJAU -> NS_KUNING -> ALL_RED_1 -> EW_HIJAU -> EW_KUNING -> ALL_RED_2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity traffic_light_fsm_ext is
    Generic ( T_YELLOW : integer := 3;     -- detik
              T_ALLRED : integer := 1 );   -- detik
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;
           sw   : in  STD_LOGIC_VECTOR (3 downto 0);
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_fsm_ext;

architecture Behavioral of traffic_light_fsm_ext is

    type state_t is (NS_HIJAU, NS_KUNING, ALL_RED_1,
                     EW_HIJAU, EW_KUNING, ALL_RED_2);
    signal state, next_state : state_t := NS_HIJAU;

    signal green_dur : integer range 5 to 20;
    signal timer     : integer range 0 to 31 := 9;
    signal next_dur  : integer range 1 to 31 := 10;

begin

    green_dur <= 5 + to_integer(unsigned(sw));   -- 5 .. 20

    ----------------------------------------------------------------------
    -- Process 1 : register state + timer
    ----------------------------------------------------------------------
    p_seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= NS_HIJAU;
                timer <= green_dur - 1;
            elsif tick = '1' then
                if timer = 0 then
                    state <= next_state;
                    timer <= next_dur - 1;
                else
                    timer <= timer - 1;
                end if;
            end if;
        end if;
    end process p_seq;

    ----------------------------------------------------------------------
    -- Process 2 : next-state, durasi state berikutnya, decode LED
    ----------------------------------------------------------------------
    p_comb : process(state, green_dur)
    begin
        next_state <= state;
        next_dur   <= T_ALLRED;
        led        <= "100100";

        case state is
            when NS_HIJAU =>
                led        <= "100001";
                next_state <= NS_KUNING;
                next_dur   <= T_YELLOW;

            when NS_KUNING =>
                led        <= "100010";
                next_state <= ALL_RED_1;
                next_dur   <= T_ALLRED;

            when ALL_RED_1 =>
                led        <= "100100";    -- kedua arah merah
                next_state <= EW_HIJAU;
                next_dur   <= green_dur;

            when EW_HIJAU =>
                led        <= "001100";
                next_state <= EW_KUNING;
                next_dur   <= T_YELLOW;

            when EW_KUNING =>
                led        <= "010100";
                next_state <= ALL_RED_2;
                next_dur   <= T_ALLRED;

            when ALL_RED_2 =>
                led        <= "100100";    -- kedua arah merah
                next_state <= NS_HIJAU;
                next_dur   <= green_dur;
        end case;
    end process p_comb;

end Behavioral;