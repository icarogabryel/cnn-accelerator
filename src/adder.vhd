library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port (
        a   : in std_logic_vector(38 downto 0);
        b   : in std_logic_vector(38 downto 0);
        c   : in std_logic_vector(38 downto 0);
        d   : in std_logic_vector(38 downto 0);
        sum : out std_logic_vector(38 downto 0)
    );

end entity;

architecture behavior of adder is

begin
    sum <= std_logic_vector(unsigned(a) + unsigned(b) + unsigned(c) + unsigned(d));

end architecture behavior;