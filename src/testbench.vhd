library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
end;

architecture behavior of testbench is
    signal signed_value   : std_logic_vector(7 downto 0);
    signal unsigned_value : std_logic_vector(7 downto 0);
    signal result         : std_logic_vector(15 downto 0);

    component multiplier is
        port(
            signed_value   : in  std_logic_vector(7 downto 0);
            unsigned_value : in  std_logic_vector(7 downto 0);
            result         : out std_logic_vector(15 downto 0)
        );
    end component;
begin
    dut : multiplier
        port map(
            signed_value   => signed_value,
            unsigned_value => unsigned_value,
            result         => result
        );

    data_process : process
    begin
        for i in -128 to 127 loop
            for j in 0 to 255 loop
                signed_value   <= std_logic_vector(to_signed(i, 8));
                unsigned_value <= std_logic_vector(to_unsigned(j, 8));
                wait for 10 ns;
                assert result = std_logic_vector(to_signed(i * j, 16)) report "Test failed for signed_value=" & integer'image(i) & " unsigned_value=" & integer'image(j) severity note;
            end loop;
        end loop;
        wait;
    end process;
end architecture;
