library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port (
        mtpr    : in std_logic_vector(7 downto 0);
        mtpcd   : in std_logic_vector(32 downto 0);
        product : out std_logic_vector(39 downto 0)
    );

end entity;

architecture behavior of multiplier is
    signal blk_0 : std_logic_vector(2 downto 0) := mtpr(1 downto 0) & '0'; -- Add a zero on the right
    signal blk_1 : std_logic_vector(2 downto 0) := mtpr(3 downto 1);
    signal blk_2 : std_logic_vector(2 downto 0) := mtpr(5 downto 3);
    signal blk_3 : std_logic_vector(2 downto 0) := mtpr(7 downto 5);

    signal mtpcd_times_1 : std_logic_vector(33 downto 0) := mtpcd(32) & mtpcd(32 downto 0);                       -- Extend the sign bit
    signal mtpcd_times_2 : std_logic_vector(33 downto 0) := mtpcd(32 downto 0) & '0';                             -- Shift left by 1
    signal mtpcd_times_neg_1 : std_logic_vector(33 downto 0) := std_logic_vector(signed(not mtpcd_times_1) + 1);  -- Two's complement
    signal mtpcd_times_neg_2 : std_logic_vector(33 downto 0) := mtpcd_times_neg_1(32 downto 0) & '0';             -- Shift left by 1

    signal partial_0 : std_logic_vector(33 downto 0);
    signal partial_1 : std_logic_vector(33 downto 0);
    signal partial_2 : std_logic_vector(33 downto 0);
    signal partial_3 : std_logic_vector(33 downto 0);

    component adder is
        port (
            a : in std_logic_vector(39 downto 0);
            b : in std_logic_vector(39 downto 0);
            c : in std_logic_vector(39 downto 0);
            d : in std_logic_vector(39 downto 0);
            sum : out std_logic_vector(39 downto 0)
        );

    end component;

begin
    with blk_0 select
        partial_0 <= (others => '0')   when "000",
                     mtpcd_times_1     when "001",
                     mtpcd_times_1     when "010",
                     mtpcd_times_2     when "011",
                     mtpcd_times_neg_2 when "100",
                     mtpcd_times_neg_1 when "101",
                     mtpcd_times_neg_1 when "110",
                     (others => '0')   when others;

    with blk_1 select
        partial_1 <= (others => '0')   when "000",
                     mtpcd_times_1     when "001",
                     mtpcd_times_1     when "010",
                     mtpcd_times_2     when "011",
                     mtpcd_times_neg_2 when "100",
                     mtpcd_times_neg_1 when "101",
                     mtpcd_times_neg_1 when "110",
                     (others => '0')   when others;

    with blk_2 select
        partial_2 <= (others => '0')   when "000",
                     mtpcd_times_1     when "001",
                     mtpcd_times_1     when "010",
                     mtpcd_times_2     when "011",
                     mtpcd_times_neg_2 when "100",
                     mtpcd_times_neg_1 when "101",
                     mtpcd_times_neg_1 when "110",
                     (others => '0')   when others;

    with blk_3 select
        partial_3 <= (others => '0')   when "000",
                     mtpcd_times_1     when "001",
                     mtpcd_times_1     when "010",
                     mtpcd_times_2     when "011",
                     mtpcd_times_neg_2 when "100",
                     mtpcd_times_neg_1 when "101",
                     mtpcd_times_neg_1 when "110",
                     (others => '0')   when others;

    adder_inst : adder
        port map (
            a => (others => partial_0(33)) & partial_0,
            b => (others => partial_1(33)) & partial_1 & "00",      -- Shift left by 2^1
            c => (others => partial_2(33)) & partial_2 & "0000",    -- Shift left by 2^2
            d => (others => partial_3(33)) & partial_3 & "000000",  -- Shift left by 2^3
            sum => product
        );

end architecture;
