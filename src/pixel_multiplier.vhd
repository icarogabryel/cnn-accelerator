library ieee;
use ieee.std_logic_1164.all;

entity pixel_multiplier is
    port(
        clk, rst : in  std_logic;
        weight   : in  std_logic_vector(7 downto 0);
        pixel    : in  std_logic_vector(23 downto 0);
        r_result : out std_logic_vector(15 downto 0);
        g_result : out std_logic_vector(15 downto 0);
        b_result : out std_logic_vector(15 downto 0)
    );
end entity pixel_multiplier;

architecture behavior of pixel_multiplier is
    signal r_value, g_value, b_value : std_logic_vector(7 downto 0);

    component multiplier
        port(
            clk, rst : in  std_logic;
            mtpr     : in  std_logic_vector(7 downto 0);
            mtpcd    : in  std_logic_vector(7 downto 0);
            prod     : out std_logic_vector(15 downto 0)
        );
    end component multiplier;
begin
    r_value <= pixel(23 downto 16);
    g_value <= pixel(15 downto 8);
    b_value <= pixel(7 downto 0);

    r_multiplier : multiplier
        port map(
            clk   => clk,
            rst   => rst,
            mtpr  => weight,
            mtpcd => r_value,
            prod  => r_result
        );

    g_multiplier : multiplier
        port map(
            clk   => clk,
            rst   => rst,
            mtpr  => weight,
            mtpcd => g_value,
            prod  => g_result
        );

    b_multiplier : multiplier
        port map(
            clk   => clk,
            rst   => rst,
            mtpr  => weight,
            mtpcd => b_value,
            prod  => b_result
        );
end architecture;
