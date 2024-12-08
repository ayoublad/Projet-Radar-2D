library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity tb_ip_telemetre is
end entity;

architecture Behavioral of tb_ip_telemetre is
    constant Pulse : time := 10 us; 

    signal Clk : std_logic := '0';
    signal Rst_n : std_logic := '0';
    signal trig : std_logic;
    signal echo : std_logic := '0';
    signal dist_cm : std_logic_vector(9 downto 0);
    signal OK : boolean := TRUE; 

begin
    -- Instanciation du module `telemetre_us`
    D1: entity work.ip_telemetre
        port map (
            clk      => Clk,
            rst_n    => Rst_n,
            trig     => trig,
            echo     => echo,
            Dist_cm  => dist_cm
        );

    -- Génération de l'horloge
    Clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
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

        -- Simuler un écho de 1 ms
        wait for 100 ns; -- Pause avant Echo
        echo <= '1'; -- Activer Echo
        wait for 340 us; -- Durée de l'écho
        echo <= '0'; -- Désactiver Echo
        -- Vérification de la distance calculée
        wait for 20 ms;
        if dist_cm = "0000000101" then -- 100 en binaire
            report "Distance correcte pour Echo de 340 us : 5 cm" severity note;
        else
            report "Erreur : Distance incorrecte pour Echo de 20 ms" severity error;
            OK <= FALSE;
        end if;

        wait until trig = '1';
        wait until trig = '0';

        -- Simuler un écho de 1 ms
        wait for 100 ns; -- Pause avant Echo
        echo <= '1'; -- Activer Echo
        wait for 640 us; -- Durée de l'écho
        echo <= '0'; -- Désactiver Echo
        -- Vérification de la distance calculée
        wait for 20 ms;
        if dist_cm = "0000001010" then -- 100 en binaire
            report "Distance correcte pour Echo de 640 us : 10 cm" severity note;
        else
            report "Erreur : Distance incorrecte pour Echo de 10 ms" severity error;
            OK <= FALSE;
        end if;
        
        wait for 1 ms;
        -- Résultat final
        if OK then
            report "Simulation complete : Tous les tests reussis !" severity note;
        else
            report "Simulation complete : Certains tests ont echoue." severity error;
        end if;

        report "Fin de la simulation";
        wait;
    end process;
end architecture;
