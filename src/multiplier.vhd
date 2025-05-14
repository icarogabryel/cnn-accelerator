library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        clk, rst : in  std_logic;
        mtpr     : in  std_logic_vector(7 downto 0);
        mtpcd    : in  std_logic_vector(7 downto 0);
        prod     : out std_logic_vector(15 downto 0)
    );
end entity;

architecture behavior of multiplier is
    type reg_bank_type is array (0 to 3) of std_logic_vector(8 downto 0);

    signal blk_0 : std_logic_vector(2 downto 0);
    signal blk_1 : std_logic_vector(2 downto 0);
    signal blk_2 : std_logic_vector(2 downto 0);
    signal blk_3 : std_logic_vector(2 downto 0);

    signal mtpcd_times_1     : std_logic_vector(8 downto 0);
    signal mtpcd_times_2     : std_logic_vector(8 downto 0);
    signal mtpcd_times_neg_1 : std_logic_vector(8 downto 0);
    signal mtpcd_times_neg_2 : std_logic_vector(8 downto 0);

    signal partial_0 : std_logic_vector(8 downto 0);
    signal partial_1 : std_logic_vector(8 downto 0);
    signal partial_2 : std_logic_vector(8 downto 0);
    signal partial_3 : std_logic_vector(8 downto 0);

    signal reg_bank : reg_bank_type;

    signal x_partial_0 : std_logic_vector(15 downto 0);
    signal x_partial_1 : std_logic_vector(15 downto 0);
    signal x_partial_2 : std_logic_vector(15 downto 0);
    signal x_partial_3 : std_logic_vector(15 downto 0);

    component adder is
        port(
            a   : in  std_logic_vector(38 downto 0);
            b   : in  std_logic_vector(38 downto 0);
            c   : in  std_logic_vector(38 downto 0);
            d   : in  std_logic_vector(38 downto 0);
            sum : out std_logic_vector(38 downto 0)
        );
    end component;

begin
    -- Divide the multiplier into 4 blocks
    blk_0 <= mtpr(1 downto 0) & '0'; -- Add a zero on the right (Booth's algorithm)
    blk_1 <= mtpr(3 downto 1);
    blk_2 <= mtpr(5 downto 3);
    blk_3 <= mtpr(7 downto 5);

    -- Make possible partial products (9 bits to fit the times 2 multiplication)
    mtpcd_times_1     <= mtpcd(7) & mtpcd(7 downto 0);             -- Extend the sign bit
    mtpcd_times_2     <= mtpcd(7 downto 0) & '0';                  -- Shift left by 1
    mtpcd_times_neg_1 <= std_logic_vector(-signed(mtpcd_times_1)); -- Negate the value
    mtpcd_times_neg_2 <= mtpcd(7 downto 0) & '0';                  -- Shift left by 1

    -- Find the partial products
    with blk_0 select partial_0 <=
        (others => '0')   when "000",  -- Times  0
        mtpcd_times_1     when "001",  -- Times  1
        mtpcd_times_1     when "010",  -- Times  1
        mtpcd_times_2     when "011",  -- Times  2
        mtpcd_times_neg_2 when "100",  -- Times -2
        mtpcd_times_neg_1 when "101",  -- Times -1
        mtpcd_times_neg_1 when "110",  -- Times -1
        (others => '0')   when others; -- Times  0

    with blk_1 select partial_1 <=
        (others => '0')   when "000",
        mtpcd_times_1     when "001",
        mtpcd_times_1     when "010",
        mtpcd_times_2     when "011",
        mtpcd_times_neg_2 when "100",
        mtpcd_times_neg_1 when "101",
        mtpcd_times_neg_1 when "110",
        (others => '0')   when others;

    with blk_2 select partial_2 <=
        (others => '0')   when "000",
        mtpcd_times_1     when "001",
        mtpcd_times_1     when "010",
        mtpcd_times_2     when "011",
        mtpcd_times_neg_2 when "100",
        mtpcd_times_neg_1 when "101",
        mtpcd_times_neg_1 when "110",
        (others => '0')   when others;

    with blk_3 select partial_3 <=
        (others => '0')   when "000",
        mtpcd_times_1     when "001",
        mtpcd_times_1     when "010",
        mtpcd_times_2     when "011",
        mtpcd_times_neg_2 when "100",
        mtpcd_times_neg_1 when "101",
        mtpcd_times_neg_1 when "110",
        (others => '0')   when others;

    write_rb : process(clk, rst) is
    begin
        if rst = '1' then
            reg_bank(0) <= (others => '0');
            reg_bank(1) <= (others => '0');
            reg_bank(2) <= (others => '0');
            reg_bank(3) <= (others => '0');
        elsif rising_edge(clk) then
            reg_bank(0) <= x_partial_0;
            reg_bank(1) <= x_partial_1;
            reg_bank(2) <= x_partial_1;
            reg_bank(3) <= x_partial_1;
        end if;
    end process write_rb;

    x_partial_0 <= reg_bank(0)(8) & reg_bank(0)(8) & reg_bank(0)(8) & reg_bank(0)(8) & reg_bank(0)(8) & reg_bank(0)(8) & reg_bank(0)(8) & reg_bank(0)(8 downto 0); -- No Shift
    x_partial_1 <= reg_bank(1)(8) & reg_bank(1)(8) & reg_bank(1)(8) & reg_bank(1)(8) & reg_bank(1)(8) & reg_bank(1)(8 downto 0) & "00";                            -- Shift left by 2^1
    x_partial_2 <= reg_bank(2)(8) & reg_bank(2)(8) & reg_bank(2)(8) & reg_bank(2)(8 downto 0) & "0000";                                                            -- Shift left by 2^2
    x_partial_3 <= reg_bank(3)(8) & reg_bank(3)(8 downto 0) & "000000";                                                                                            -- Shift left by 2^3

    adder_inst : adder
        port map(
            a   => x_partial_0,
            b   => x_partial_1,
            c   => x_partial_2,
            d   => x_partial_3,
            sum => prod
        );
end architecture;
