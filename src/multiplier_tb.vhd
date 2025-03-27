library ieee;
use ieee.std_logic_1164.all;

entity multiplier_tb is
end;

architecture behavior of multiplier_tb is
    signal mtpr    : std_logic_vector(6 downto 0);
    signal mtpcd   : std_logic_vector(31 downto 0);
    signal product : std_logic_vector(38 downto 0);

    component multiplier is
        port(
            mtpr    : in  std_logic_vector(6 downto 0);
            mtpcd   : in  std_logic_vector(31 downto 0);
            product : out std_logic_vector(38 downto 0)
        );
    end component;

begin
    mult : multiplier
        port map(
            mtpr    => mtpr,
            mtpcd   => mtpcd,
            product => product
        );

    process
    begin
        mtpr  <= "0000100";
        mtpcd <= "00000000000000010000000000000000";
        wait for 10 ns;

        mtpr  <= "1111110";
        mtpcd <= "11111111111111111111111111111010";
        wait for 10 ns;

        wait;

    end process;

end architecture;
