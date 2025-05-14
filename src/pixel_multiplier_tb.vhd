library ieee;
use ieee.std_logic_1164.all;

entity pixel_multiplier_tb is
end;

architecture behavior of pixel_multiplier_tb is
    signal clk, rst : std_logic := '0';
    signal weight : std_logic_vector(7 downto 0) := (others => '0');
    signal pixel : std_logic_vector(23 downto 0) := (others => '0');
    signal r_result, g_result, b_result : std_logic_vector(15 downto 0);

    signal clk_count : integer := 0;
    constant clk_period : time := 10 ns;
begin
    uut: entity work.pixel_multiplier
        port map (
            clk => clk,
            rst => rst,
            weight => weight,
            pixel => pixel,
            r_result => r_result,
            g_result => g_result,
            b_result => b_result
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;

        clk       <= '1';
        clk_count <= clk_count + 1;
        wait for clk_period / 2;

        if clk_count = 10 then
            assert false report "Test completed" severity note;
            wait;
        end if;
    end process clk_process;

    stim_proc: process
    begin
        rst <= '1';
        wait for 2 ns;
        rst <= '0';
        wait for 3 ns;

        -- Test case 1:
        weight <= "00000010"; -- Weight = 2
        pixel <= "111111111111111111111111"; -- Pixel = (255, 255, 255)
        wait for clk_period;

        -- Test case 2:
        weight <= "00000011"; -- Weight = 3
        pixel <= "100000001000000010000000"; -- Pixel = (128, 128, 128)
        wait for clk_period;

        -- Test case 3:
        weight <= "00000001"; -- Weight = 1
        pixel <= "000000000000000000000000"; -- Pixel = (0, 0, 0)
        wait for clk_period;

        wait;
    end process;
end architecture behavior;
