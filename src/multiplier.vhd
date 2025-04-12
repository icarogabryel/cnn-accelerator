library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        clk, rst : in  std_logic;
        mtpr     : in  std_logic_vector(6 downto 0);
        mtpcd    : in  std_logic_vector(31 downto 0);
        product  : out std_logic_vector(38 downto 0)
    );

end entity;

architecture behavior of multiplier is
    type reg_bank_type is array(0 to 3) of std_logic_vector(32 downto 0);

    signal blk_0 : std_logic_vector(2 downto 0);
    signal blk_1 : std_logic_vector(2 downto 0);
    signal blk_2 : std_logic_vector(2 downto 0);
    signal blk_3 : std_logic_vector(2 downto 0);

    signal mtpcd_times_1     : std_logic_vector(32 downto 0);
    signal mtpcd_times_2     : std_logic_vector(32 downto 0);
    signal mtpcd_times_neg_1 : std_logic_vector(32 downto 0);
    signal mtpcd_times_neg_2 : std_logic_vector(32 downto 0);

    signal pre_partial_0 : std_logic_vector(32 downto 0);
    signal pre_partial_1 : std_logic_vector(32 downto 0);
    signal pre_partial_2 : std_logic_vector(32 downto 0);
    signal pre_partial_3 : std_logic_vector(32 downto 0);

    signal reg_bank : reg_bank_type;

    signal partial_0 : std_logic_vector(38 downto 0);
    signal partial_1 : std_logic_vector(38 downto 0);
    signal partial_2 : std_logic_vector(38 downto 0);
    signal partial_3 : std_logic_vector(38 downto 0);

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
    blk_0 <= mtpr(1 downto 0) & '0';    -- Add a zero on the right
    blk_1 <= mtpr(3 downto 1);
    blk_2 <= mtpr(5 downto 3);
    blk_3 <= mtpr(6) & mtpr(6 downto 5);    -- Sign extend to fit 3 bits

    mtpcd_times_1     <= mtpcd(31) & mtpcd(31 downto 0); -- Extend the sign bit
    mtpcd_times_2     <= mtpcd(31 downto 0) & '0'; -- Shift left by 1
    mtpcd_times_neg_1 <= std_logic_vector(-signed(mtpcd_times_1));
    mtpcd_times_neg_2 <= mtpcd_times_neg_1(31 downto 0) & '0'; -- Shift left by 1

    with blk_0 select pre_partial_0 <=
        (others => '0')   when "000",
        mtpcd_times_1     when "001",
        mtpcd_times_1     when "010",
        mtpcd_times_2     when "011",
        mtpcd_times_neg_2 when "100",
        mtpcd_times_neg_1 when "101",
        mtpcd_times_neg_1 when "110",
        (others => '0')   when others;

    with blk_1 select pre_partial_1 <=
        (others => '0')   when "000",
        mtpcd_times_1     when "001",
        mtpcd_times_1     when "010",
        mtpcd_times_2     when "011",
        mtpcd_times_neg_2 when "100",
        mtpcd_times_neg_1 when "101",
        mtpcd_times_neg_1 when "110",
        (others => '0')   when others;

    with blk_2 select pre_partial_2 <=
        (others => '0')   when "000",
        mtpcd_times_1     when "001",
        mtpcd_times_1     when "010",
        mtpcd_times_2     when "011",
        mtpcd_times_neg_2 when "100",
        mtpcd_times_neg_1 when "101",
        mtpcd_times_neg_1 when "110",
        (others => '0')   when others;

    with blk_3 select pre_partial_3 <=
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
            reg_bank(0) <= pre_partial_0;
            reg_bank(1) <= pre_partial_1;
            reg_bank(2) <= pre_partial_2;
            reg_bank(3) <= pre_partial_3;

        end if;
    end process write_rb;

    partial_0 <= reg_bank(0)(32) & reg_bank(0)(32) & reg_bank(0)(32) & reg_bank(0)(32) & reg_bank(0)(32) & reg_bank(0)(32) & reg_bank(0)(32 downto 0);
    partial_1 <= reg_bank(1)(32) & reg_bank(1)(32) & reg_bank(1)(32) & reg_bank(1)(32) & reg_bank(1)(32 downto 0) & "00"; -- Shift left by 2^1
    partial_2 <= reg_bank(2)(32) & reg_bank(2)(32) & reg_bank(2)(32 downto 0) & "0000"; -- Shift left by 2^2
    partial_3 <= reg_bank(3)(32 downto 0) & "000000"; -- Shift left by 2^3

    adder_inst : adder
        port map(
            a   => partial_0,
            b   => partial_1,
            c   => partial_2,
            d   => partial_3,
            sum => product
        );

end architecture;
