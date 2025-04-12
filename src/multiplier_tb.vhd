library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier_tb is
end;

architecture behavior of multiplier_tb is
    signal clk, rst : std_logic;
    signal clk_period : time := 10 ns;
    signal clk_count  : integer := 0;

    signal mtpr    : std_logic_vector(6 downto 0);
    signal mtpcd   : std_logic_vector(31 downto 0);
    signal product : std_logic_vector(38 downto 0);

    component multiplier is
        port(
            clk, rst : in  std_logic;
            mtpr     : in  std_logic_vector(6 downto 0);
            mtpcd    : in  std_logic_vector(31 downto 0);
            product  : out std_logic_vector(38 downto 0)
        );
    end component;

begin
    mult : multiplier
        port map(
            clk     => clk,
            rst     => rst,
            mtpr    => mtpr,
            mtpcd   => mtpcd,
            product => product
        );

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;

        clk <= '1';
        clk_count <= clk_count + 1;
        wait for clk_period/2;

        if (clk_count = 10) then
            report "ending simulation";
            wait;

        end if;

    end process clk_process;

    rst_process: process
    begin
        rst <= '0';
        wait for 2 ns;

        rst <= '1';
        wait for 8 ns;

        rst <= '0';
        wait;

    end process rst_process;

    data_process: process
    begin
        wait for 5 ns;

        mtpr  <= std_logic_vector(to_signed(8, 7));
        mtpcd <= std_logic_vector(to_signed(2, 32));
        wait for 10 ns;

        mtpr  <= std_logic_vector(to_signed(-5, 7));
        mtpcd <= std_logic_vector(to_signed(20, 32));
        wait for 10 ns;

        wait;

    end process;

end architecture;
