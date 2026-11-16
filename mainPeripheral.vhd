-- 11/11/2026
-- Evelyn, James, Patrick, Alina
--test pull

-- 1. Library Declaration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 2. Entity Declaration (Inputs and Outputs)
entity TimerPeripheral is
	generic (
		clock_freq : integer := 10000000 --sets input clock frequency to 10MHz (default), also scomp clock frequency
		
		-- declares a setting you can choose when you instantiate the peripheral
		-- my friend is saying to like define the clock here
	);
	
  port ( -- these ins and outs are from the timers point of view
     clk_10MHz    : in  std_logic; -- 10MHz clock coming from PLL
     resetn    : in  std_logic; -- active low reset from PLL
     io_addr : in std_logic_vector(10 downto 0); -- 11 bit IO address to tell which register 
	 io_write : in std_logic; -- tells peripheral scomp is exdcuting out
	 io_read : in std_logic; -- tells peripheral scomp is executing a in
	 data_in : in std_logic_vector(15 downto 0); -- coming into peripheral from scomp during na out
	 data_out : out std_logic_vector(15 downto 0) -- data coming out of the peripheral during a read (like would carry timer count, running status, DONE flag etc)
	 
  );
end entity;

--architecture defines what happens in timerPeripheral
architecture behavior of timerPeripheral is
	--addresses from register map
	CONSTANT master_addr : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110000"; -- 0x70
	CONSTANT sub1_addr   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110001"; -- 0x71
	CONSTANT sub2_addr   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110010"; -- 0x72
	CONSTANT sub3_addr  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110011"; -- 0x73
	CONSTANT master_cmd  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110100"; -- 0x74
	CONSTANT sub_cmd    : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110101"; -- 0x75
	CONSTANT timer_flags : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110110"; -- 0x76

	-- stores the current count for each timer, initializes all counts to zero
	signal master_count : unsigned(15 downto 0) := "0000000000000000";
	signal sub1_count : unsigned(15 downto 0) := "0000000000000000";
	signal sub2_count : unsigned(15 downto 0) := "0000000000000000";
	signal sub3_count : unsigned(15 downto 0) := "0000000000000000";

	-- stores whether each timer is running or stopped
	-- '0' indicates timer is stopped; '1' indicates timer is enabled to run
	-- master_run must be '1' for any of the sub-timers to be able to run
	signal master_run : std_logic := '0';
	signal run1 : std_logic := '0';
	signal run2 : std_logic := '0';
	signal run3 : std_logic := '0';

	--stores counting mode for each sub-timer
	-- '0' is stopwatch mode where the timer counts up (default)
	-- '1' is countdown mode where the timer counts down (programmer must set a preset value using using register 0x71, 0x72, or 0x73)
	signal mode1 : std_logic := '0';
	signal mode2 : std_logic := '0';
	signal mode3 : std_logic := '0';

	-- stores the done flags for each sub-timer
	-- '0' indicates countdown is not complete (default)
	-- '1' indicates countdown has finished
	signal done1 : std_logic := '0';
	signal done2 : std_logic := '0';
	signal done3 : std_logic := '0';

	-- the fpga clock runs at 10mhz -> 10 million ticks per second
	-- dividing by 1000 gives us 10000 clock ticks per millisecond
	-- the programmer can use register 0x70 to set how many milliseconds
	-- elapse before the timers count up or down by 1
	constant ticks_per_ms : integer := clock_freq / 1000;

	-- counts how many fpga clock ticks have passed
	-- keeps counting until it reaches tick_period * ticks_per_ms
	-- once enough ticks pass, the timers update and clock_count starts over at 0
	signal clock_count : integer range 0 to 65535 * ticks_per_ms := 0;
	
	-- sets how many ms to wait before timers update
	-- the number of clock ticks we wait is tick_period * ticks_per_ms
	-- 1000 * 10000 = 10 million clock ticks, so the timers update once per second (default)
	-- example: 1 ms tick rate -> tick period is 1, so timers will update every 10000 clock ticks
	-- the programmer can change this value using register 0x70
	signal tick_period : integer range 1 to 65535 := 1000;

process(resetn, clk_10mhz)
begin
	-- resets all timers and resets defaults
	if resetn = '0' then
	
	    -- go back to defualt tick period, reset clock count to zero
	    clock_count <= 0;
	    tick_period <= 1000;
	
	    -- reset all timer counts to 0
	    master_count <= "0000000000000000";
	    sub1_count   <= "0000000000000000";
	    sub2_count   <= "0000000000000000";
	    sub3_count   <= "0000000000000000";
	
	    -- stop timers
	    master_run <= '0';
	    run1 <= '0';
	    run2 <= '0';
	    run3 <= '0';
	
	    -- set sub-timers to stopwatch mode
	    mode1 <= '0';
	    mode2 <= '0';
	    mode3 <= '0';
	
	    -- clear done flags
	    done1 <= '0';
	    done2 <= '0';
	    done3 <= '0';

    elsif rising_edge(clk_10mhz) then

        -- timer logic goes here

		
    end if;

end process;

end architecture behavior;
