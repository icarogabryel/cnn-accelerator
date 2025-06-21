library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_tb is
end;

architecture behavior of multiplier_tb is
    signal clk, rst     : std_logic;
    signal clk_count    : integer := 0;
    constant clk_period : time    := 10 ns;

    signal mtpr  : std_logic_vector(7 downto 0);
    signal mtpcd : std_logic_vector(7 downto 0);
    signal prod  : std_logic_vector(15 downto 0);

    component multiplier is
        port(
            clk, rst : in  std_logic;
            mtpr     : in  std_logic_vector(7 downto 0);
            mtpcd    : in  std_logic_vector(7 downto 0);
            prod     : out std_logic_vector(15 downto 0)
        );
    end component;

begin
    mult : multiplier
        port map(
            clk   => clk,
            rst   => rst,
            mtpr  => mtpr,
            mtpcd => mtpcd,
            prod  => prod
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

    rst_process : process
    begin
        rst <= '0';
        wait for 2 ns;

        rst <= '1';
        wait for 8 ns;

        rst <= '0';
        wait;
    end process rst_process;

    data_process : process
    begin
        wait for 5 ns;

        mtpr  <= std_logic_vector(to_signed(-128, 8));
        mtpcd <= std_logic_vector(to_unsigned(255, 8));

        wait for 20 ns;
        assert prod = std_logic_vector(to_signed(-32640, 16)) report "First test failed" severity error;

        mtpr  <= std_logic_vector(to_signed(127, 8));
        mtpcd <= std_logic_vector(to_unsigned(255, 8));

        wait for 20 ns;
        assert prod = std_logic_vector(to_signed(32385, 16)) report "Second test failed" severity error;

        mtpr  <= (others => '0');
        mtpcd <= (others => '0');

        wait for 20 ns;
        assert prod = std_logic_vector(to_signed(0, 16)) report "Third test failed" severity error;

        wait;
    end process;
end architecture;
