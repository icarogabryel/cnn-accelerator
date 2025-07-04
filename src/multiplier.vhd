library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        signed_value   : in  std_logic_vector(7 downto 0);
        unsigned_value : in  std_logic_vector(7 downto 0);
        result         : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of multiplier is
    -- These signals are used to be the blocks of Booth's algorithm
    signal blk_0 : std_logic_vector(2 downto 0);
    signal blk_1 : std_logic_vector(2 downto 0);
    signal blk_2 : std_logic_vector(2 downto 0);
    signal blk_3 : std_logic_vector(2 downto 0);

    -- Signal "unsigned_value" extended with 0 on left to force positive
    -- interpretation in two's complement.
    signal x_unsigned : std_logic_vector(8 downto 0);

    -- Its needed to create a signal to hold the negative of the "x_unsigned"
    -- signal and then extend it because VHDL can't index and do type
    -- conversion of "x_unsigned" in the same line.
    signal neq_x_unsigned : std_logic_vector(8 downto 0);

    -- Signals to help creating partial products. This
    -- signals have one bit more than the "x_unsigned" to fit the times 2
    -- multiplication.
    signal unsigned_times_1     : std_logic_vector(9 downto 0);
    signal unsigned_times_2     : std_logic_vector(9 downto 0);
    signal unsigned_times_neg_1 : std_logic_vector(9 downto 0);
    signal unsigned_times_neg_2 : std_logic_vector(9 downto 0);

    -- Signals of the partial products but not shifted yet.
    signal pre_partial_0 : std_logic_vector(9 downto 0);
    signal pre_partial_1 : std_logic_vector(9 downto 0);
    signal pre_partial_2 : std_logic_vector(9 downto 0);
    signal pre_partial_3 : std_logic_vector(9 downto 0);

    -- The partial products generated.
    signal partial_0 : std_logic_vector(15 downto 0);
    signal partial_1 : std_logic_vector(15 downto 0);
    signal partial_2 : std_logic_vector(15 downto 0);
    signal partial_3 : std_logic_vector(15 downto 0);
begin
    -- Add a 0 on right and divide the "signed" into 4 blocks following radix-4
    -- Booth's algorithm.
    blk_0 <= signed_value(1 downto 0) & '0'; -- Add a zero on the right (Booth's algorithm)
    blk_1 <= signed_value(3 downto 1);
    blk_2 <= signed_value(5 downto 3);
    blk_3 <= signed_value(7 downto 5);

    -- Extended "unsigned" with 0 on left to force positive interpretation in
    -- Booth's algorithm.
    x_unsigned <= '0' & unsigned_value;

    -- Make the possibles "pre_partial" products.
    -- Extend the sign bit to fit the size.
    unsigned_times_1     <= x_unsigned(8) & x_unsigned(8 downto 0);
    unsigned_times_2     <= x_unsigned(8 downto 0) & '0'; -- Shift left by 1
    -- Create the negative of the "x_unsigned" signal to be extended in
    -- "unsigned_times_neg_1".
    neq_x_unsigned       <= std_logic_vector(-signed(x_unsigned));
    -- Extend the sign bit
    unsigned_times_neg_1 <= neq_x_unsigned(8) & neq_x_unsigned(8 downto 0);
    -- Shift left by 1
    unsigned_times_neg_2 <= unsigned_times_neg_1(8 downto 0) & '0';

    -- Find the "pre_partial"s corresponding to each block.
    with blk_0 select pre_partial_0 <=
        (others => '0') when "000",     -- Times  0
        unsigned_times_1 when "001",    -- Times  1
        unsigned_times_1 when "010",    -- Times  1
        unsigned_times_2 when "011",    -- Times  2
        unsigned_times_neg_2 when "100", -- Times -2
        unsigned_times_neg_1 when "101", -- Times -1
        unsigned_times_neg_1 when "110", -- Times -1
        (others => '0') when others;    -- Times  0

    with blk_1 select pre_partial_1 <=
        (others => '0') when "000",
        unsigned_times_1 when "001",
        unsigned_times_1 when "010",
        unsigned_times_2 when "011",
        unsigned_times_neg_2 when "100",
        unsigned_times_neg_1 when "101",
        unsigned_times_neg_1 when "110",
        (others => '0') when others;

    with blk_2 select pre_partial_2 <=
        (others => '0') when "000",
        unsigned_times_1 when "001",
        unsigned_times_1 when "010",
        unsigned_times_2 when "011",
        unsigned_times_neg_2 when "100",
        unsigned_times_neg_1 when "101",
        unsigned_times_neg_1 when "110",
        (others => '0') when others;

    with blk_3 select pre_partial_3 <=
        (others => '0') when "000",
        unsigned_times_1 when "001",
        unsigned_times_1 when "010",
        unsigned_times_2 when "011",
        unsigned_times_neg_2 when "100",
        unsigned_times_neg_1 when "101",
        unsigned_times_neg_1 when "110",
        (others => '0') when others;

    -- Extend the "pre_partial"s (to enter the adders) and shift according to
    -- Booth's algorithm to make the partial products.
    partial_0 <= pre_partial_0(9) & pre_partial_0(9) & pre_partial_0(9) & pre_partial_0(9) & pre_partial_0(9) & pre_partial_0(9) & pre_partial_0(9 downto 0); -- No Shift
    partial_1 <= pre_partial_1(9) & pre_partial_1(9) & pre_partial_1(9) & pre_partial_1(9) & pre_partial_1(9 downto 0) & "00"; -- Shift left by 2^1
    partial_2 <= pre_partial_2(9) & pre_partial_2(9) & pre_partial_2(9 downto 0) & "0000"; -- Shift left by 2^2
    partial_3 <= pre_partial_3(9 downto 0) & "000000"; -- Shift left by 2^3


    result <= std_logic_vector(
        signed(partial_0) + signed(partial_1) + signed(partial_2) + signed(partial_3)
    );

end architecture;
