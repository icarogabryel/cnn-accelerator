library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
    port(
        a   : in  std_logic_vector(15 downto 0);
        b   : in  std_logic_vector(15 downto 0);
        c   : in  std_logic_vector(15 downto 0);
        d   : in  std_logic_vector(15 downto 0);
        sum : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of adder is
    component compressor
        port(
            b0, b1, b2, b3 : in  std_logic;
            c_in           : in  std_logic;
            c_out          : out std_logic;
            carry          : out std_logic;
            sum            : out std_logic
        );
    end component compressor;

    signal carry_bus : std_logic_vector(16 downto 0);
    signal c_out_bus : std_logic_vector(16 downto 0);
    signal p_carry   : std_logic_vector(15 downto 0); -- propagation carry

begin
    carry_bus(0) <= '0';
    c_out_bus(0) <= '0';

    compressor_gen : for i in 0 to 15 generate
        p_carry(i) <= carry_bus(i) or c_out_bus(i);

        compressor_inst : compressor
            port map(
                b0    => a(i),
                b1    => b(i),
                b2    => c(i),
                b3    => d(i),
                c_in  => p_carry(i),
                c_out => c_out_bus(i + 1),
                carry => carry_bus(i + 1),
                sum   => sum(i)
            );
    end generate compressor_gen;
end architecture behavior;
