----------------------------------------------------------------------------------
-- traffic_light_fsm.vhd
-- FSM lampu lalu lintas 2 arah (4 state), gaya 2-process
--   NS_HIJAU -> NS_KUNING -> EW_HIJAU -> EW_KUNING -> NS_HIJAU ...
-- Pemetaan LED (1 = menyala):
--   led(0)=NS hijau, led(1)=NS kuning, led(2)=NS merah
--   led(3)=EW hijau, led(4)=EW kuning, led(5)=EW merah
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity traffic_light_fsm is
    Generic ( T_GREEN  : integer := 10;   -- durasi hijau (detik)
              T_YELLOW : integer := 3 );  -- durasi kuning (detik)
    Port ( clk  : in  STD_LOGIC;
           rst  : in  STD_LOGIC;
           tick : in  STD_LOGIC;          -- pulsa 1 detik
           led  : out STD_LOGIC_VECTOR (5 downto 0) );
end traffic_light_fsm;

architecture Behavioral of traffic_light_fsm is

    type state_t is (NS_HIJAU, NS_KUNING, EW_HIJAU, EW_KUNING);
    signal state, next_state : state_t := NS_HIJAU;

    signal timer    : integer range 0 to 63 := T_GREEN - 1;
    signal next_dur : integer range 1 to 63 := T_GREEN;

begin

    ----------------------------------------------------------------------
    -- Process 1 : register state + timer (sekuensial)
    -- timer dikurangi tiap tick='1'; transisi saat timer = 0
    ----------------------------------------------------------------------
    p_seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= NS_HIJAU;
                timer <= T_GREEN - 1;
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
    -- Process 2 : next-state, durasi state berikutnya, dan decode keluaran
    -- (kombinasional)
    ----------------------------------------------------------------------
    p_comb : process(state)
    begin
        -- nilai default
        next_state <= state;
        next_dur   <= T_GREEN;
        led        <= "100100";            -- semua merah (aman)

        case state is
            when NS_HIJAU =>
                led        <= "100001";    -- NS hijau, EW merah
                next_state <= NS_KUNING;
                next_dur   <= T_YELLOW;

            when NS_KUNING =>
                led        <= "100010";    -- NS kuning, EW merah
                next_state <= EW_HIJAU;
                next_dur   <= T_GREEN;

            when EW_HIJAU =>
                led        <= "001100";    -- NS merah, EW hijau
                next_state <= EW_KUNING;
                next_dur   <= T_YELLOW;

            when EW_KUNING =>
                led        <= "010100";    -- NS merah, EW kuning
                next_state <= NS_HIJAU;
                next_dur   <= T_GREEN;
        end case;
    end process p_comb;

end Behavioral;