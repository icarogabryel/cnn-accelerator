library ieee;
use ieee.std_logic_1164.all;

entity compressor is
    port(
        b0, b1, b2, b3 : in  std_logic;
        c_in           : in  std_logic;
        c_out          : out std_logic;
        carry          : out std_logic;
        sum            : out std_logic
    );

end entity;

architecture behavior of compressor is
    signal i_sum : std_logic;

begin
    i_sum <= b0 xor b1 xor b2;
    carry <= (b0 and b1) or (b1 and b2) or (b0 and b2);

    sum   <= i_sum xor b3 xor c_in;
    c_out <= (i_sum and b3) or (i_sum and c_in) or (b3 and c_in);

end behavior;
