library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity ip_telemetre is
    Port (
        clk      : in  std_logic;                     
        rst_n    : in  std_logic;                     
        echo     : in  std_logic;                  
        trig     : out std_logic;                  
        Dist_cm  : out std_logic_vector(9 downto 0)     
    );
end ip_telemetre;

architecture Behavioral of ip_telemetre is
    --Constantes
    constant TRIG_DURATION  : integer := 500;       
    constant TIMEOUT_TICKS  : integer := 1_000_000;    
    constant WAIT_TICKS     : integer := 5_000_000;    
    constant DIVISOR        : integer := 3000;        

    --Signaux internes
    signal count_trig     : unsigned(8 downto 0) := (others => '0');
    signal cnt_echo_ticks  : integer := 0;
    signal count_timeout  : unsigned(20 downto 0) := (others => '0');
    signal count_100ms     : unsigned(22 downto 0) := (others => '0'); 
    signal distance_cm      : integer := 0;

    type state_type is (IDLE, TRIGGER, MEASURE, WAIT100MS);
    signal state : state_type := IDLE;

begin
    Dist_cm <= std_logic_vector(to_unsigned(distance_cm,10));

    process(clk, rst_n)
    begin
        if rst_n = '0' then
            trig <= '0';
            distance_cm <= 0;
            cnt_echo_ticks <= 0;
            count_timeout <= (others => '0');
            count_trig <= (others => '0');
            count_100ms <= (others => '0');
            state <= IDLE;
        elsif rising_edge(clk) then
            case state is
                --Reinitialisation des signaux pour preparer la mesure
                when IDLE =>
                    trig <= '0';
                    cnt_echo_ticks <= 0;
                    count_timeout <= (others => '0');
                    count_trig <= (others => '0');
                    count_100ms <= (others => '0');
                    state <= TRIGGER;

                --Generation d'une impulsion a l'etat haut pendant au moins 10 μs sur l’entrée Trig
                when TRIGGER =>
                    if count_trig < TRIG_DURATION then
                        count_trig <= count_trig + 1;
                        trig <= '1';
                    else
                        trig <= '0'; 
                        count_trig <= (others => '0');
                        state <= MEASURE; 
                    end if;

                --On va compter le nombre de ticks pendant la duree du signal echo a l'etat haut
                when MEASURE =>
                    if echo = '1' then
                        cnt_echo_ticks <= cnt_echo_ticks + 1; 
                    elsif count_timeout < TIMEOUT_TICKS then
                        count_timeout <= count_timeout + 1; 
                    else
                        distance_cm <= cnt_echo_ticks / DIVISOR;
                        state <= WAIT100MS; 
                    end if;

                --Attente de 100 ms avant de revenir à IDLE
                when WAIT100MS =>
                    if count_100ms < WAIT_TICKS then
                        count_100ms <= count_100ms + 1;
                    else
                        count_100ms <= (others => '0');
                        state <= IDLE;
                    end if;
                    
                when others =>
                    state <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;