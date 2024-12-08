library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity tb_ip_servomoteur is
end entity;

architecture Behavioral of tb_ip_servomoteur is
    -- Définir une période pour l'horloge (50 MHz)
    constant Clock_Period : time := 20 ns;

    -- Signaux pour connecter le testbench au composant
    signal clk       : std_logic := '0';
    signal reset_n   : std_logic := '0';
    signal position  : std_logic_vector(7 downto 0) := (others => '0');
    signal commande  : std_logic;


    signal OK : boolean := TRUE;

begin
    -- Instanciation de l'IP Servomoteur
    inst_ip_servomoteur: entity work.ip_servomoteur
        port map (
            clk       => clk,
            reset_n   => reset_n,
            position  => position,
            commande  => commande
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for Clock_Period / 2;
            clk <= '1';
            wait for Clock_Period / 2;
        end loop;
    end process;

    -- Banc de test principal
    process
        -- Variable pour vérifier la durée de l'impulsion
        variable pulse_start, pulse_end : time := 0 ns;
    begin
        report "Debut de la simulation";

        -- Étape 1 : Reset du système
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 100 ns;

       
        -- Étape 3 : Tester position à 45° (1.5 ms)
        report "Test 2 : Position 45° (1.5 ms)";
        position <= "00101101"; -- Environ 45°
        wait until commande = '1';
        pulse_start := now;
        wait until commande = '0';
        pulse_end := now;
        report "Durée mesurée : " & time'image(pulse_end - pulse_start);
        assert (pulse_end - pulse_start) = 1.5 ms
            report "Erreur : Durée incorrecte pour 45° !" severity failure;
        wait for 2 ms;

        -- Étape 4 : Tester position à 90° (2 ms)
        report "Test 3 : Position 90° (2 ms)";
        position <= "01011010"; -- Environ 90°
        wait until commande = '1';
        pulse_start := now;
        wait until commande = '0';
        pulse_end := now;
        report "Durée mesurée : " & time'image(pulse_end - pulse_start);
        assert (pulse_end - pulse_start) = 2 ms
            report "Erreur : Durée incorrecte pour 90° !" severity failure;
        wait for 2 ms;

        -- Étape 5 : Tester une position intermédiaire (1.25 ms)
        report "Test 4 : Position intermédiaire (1.25 ms)";
        position <= "00011110"; -- Environ 22.5°
        wait until commande = '1';
        pulse_start := now;
        wait until commande = '0';
        pulse_end := now;
        report "Durée mesurée : " & time'image(pulse_end - pulse_start);
        assert (pulse_end - pulse_start) = 1.25 ms
            report "Erreur : Durée incorrecte pour 22.5° !" severity failure;
        wait for 2 ms;

        -- Résultat final
        if OK then
            report "Simulation complète : Tous les tests réussis !" severity note;
        else
            report "Simulation complète : Certains tests ont échoué." severity error;
        end if;

        report "Fin de la simulation";
        wait;
    end process;

end Behavioral;
