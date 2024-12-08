library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ip_servomoteur is
  port (
    clk        : in std_logic;                   
    position   : in std_logic_vector(7 downto 0); 
    reset_n    : in std_logic;                   
    commande   : out std_logic    
  );
end ip_servomoteur;

architecture RTL of ip_servomoteur is

signal div         : unsigned(31 downto 0) := to_unsigned(1000000, 32); --Periode de 20 ms
signal duty        : unsigned(31 downto 0);
signal counter     : unsigned(31 downto 0);
signal pwm_on      : std_logic := '0';

begin

  process(position)
  begin
	 --si position == 0 alors duree d'impulsion d'1 ms (50 000 ticks)
	 --si position == 128 alors duree d'impulsion d'1.5 ms (75 000 ticks)
	 --si position == 255 alors duree d'impulsion d'2 ms (100 000 ticks)
    duty <= to_unsigned(50000 + 50000*(to_integer(unsigned(position)))/255, 32);
  end process;

  process(clk, reset_n)
  begin
    if reset_n = '0' then
      counter <= (others => '0');
    elsif rising_edge(clk) then
      if counter >= div then
        counter <= (others => '0');
      else
        counter <= counter + 1;
      end if;
    end if;
  end process;

  process(clk, reset_n)
  begin
    if reset_n = '0' then
      pwm_on <= '0';
    elsif rising_edge(clk) then
      if counter < duty then
        pwm_on <= '1';
      else
        pwm_on <= '0';
      end if;
    end if;
  end process;


  commande <= pwm_on;

end RTL;
