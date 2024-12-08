library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity tb_telemetre_us_avalon is
end entity;

architecture Behavioral of tb_telemetre_us_avalon is
    constant Pulse : time := 10 us; 

    signal Clk        : std_logic := '0';
    signal Rst_n      : std_logic := '0';
    signal trig       : std_logic;
    signal echo       : std_logic := '0';
    signal dist_cm    : std_logic_vector(9 downto 0);
    signal chipselect : std_logic := '0';
    signal Read_n     : std_logic := '1';
    signal readdata   : std_logic_vector(31 downto 0);
    signal OK         : boolean := TRUE; 

begin
    -- Instanciation du module `Telemetre_us_Avalon`
    DUT: entity work.Telemetre_us_Avalon
        port map (
            clk        => Clk,
            rst_n      => Rst_n,
            echo       => echo,
            trig       => trig,
            Read_n     => Read_n,
            chipselect => chipselect,
            readdata   => readdata,
            Dist_cm    => dist_cm
        );

    -- Génération de l'horloge
    Clk_process : process
    begin
        Clk <= '0';
        wait for 10 ns;
        Clk <= '1';
        wait for 10 ns;
    end process;

    -- Banc de test principal
    process
        -- Variables pour mesurer les temps
        variable t1, t2 : time := 0 ns;
    begin
        report "Debut de la simulation";

        -- Reset du système
        Rst_n <= '0';
        wait for 100 ns;
        Rst_n <= '1'; -- Relâcher le reset
        wait for 100 ns;

        report "Test : Verification de Trig et Echo pour 1 ms";

        wait until trig = '1';
        t1 := now;
        wait until trig = '0';
        t2 := now;

        -- Vérification de la durée de Trig
        report "Duree mesuree pour Trig : " & time'image(t2 - t1);
        assert (t2 - t1) = Pulse
            report "Erreur : Duree de l'impulsion Trig incorrecte !" severity failure;

        -- Simuler un écho pour une distance de 5 cm
        wait for 100 ns; -- Pause avant Echo
        echo <= '1'; -- Activer Echo
        wait for 340 us; -- Durée de l'écho
        echo <= '0'; -- Désactiver Echo
        -- Vérification de la distance calculée
        wait for 20 ms;

        chipselect <= '1'; -- Activer le périphérique
        Read_n <= '0'; -- Demande de lecture
        wait for 10 ns;
        if readdata = std_logic_vector(to_unsigned(5, 32)) then -- 5 cm en entier 32 bits
            report "Distance correcte pour Echo de 340 us : 5 cm (32 bits)" severity note;
        else
            report "Erreur : Distance incorrecte pour Echo de 340 us, readdata = " severity error;
            OK <= FALSE;
        end if;

        chipselect <= '0'; -- Désactiver le périphérique
        Read_n <= '1'; -- Relâcher la lecture

        -- Simuler un écho pour une distance de 10 cm
        wait until trig = '1';
        wait until trig = '0';

        wait for 100 ns; -- Pause avant Echo
        echo <= '1'; -- Activer Echo
        wait for 640 us; -- Durée de l'écho
        echo <= '0'; -- Désactiver Echo
        -- Vérification de la distance calculée
        wait for 20 ms;

        chipselect <= '1'; -- Activer le périphérique
        Read_n <= '0'; -- Demande de lecture
        wait for 10 ns;
        if readdata = std_logic_vector(to_unsigned(10, 32)) then -- 10 cm en entier 32 bits
            report "Distance correcte pour Echo de 640 us : 10 cm (32 bits)" severity note;
        else
            report "Erreur : Distance incorrecte pour Echo de 640 us, readdata = " severity error;
            OK <= FALSE;
        end if;

        chipselect <= '0'; -- Désactiver le périphérique
        Read_n <= '1'; -- Relâcher la lecture

        wait for 1 ms;
        -- Résultat final
        if OK then
            report "Tous les tests ont ete reussis !" severity note;
        else
            report "Certains tests ont echoue." severity error;
        end if;

        report "Fin de la simulation";
        wait;
    end process;
end architecture;
