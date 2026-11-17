-- 11/11/2026
-- Evelyn, James, Patrick, Alina
-- ECE 2031 L03_0
-- This is our project main peripheral file.


library ieee;
library lpm;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ece2031project is
	generic (
		clock_freq : integer := 10000000 --sets input clock frequency to 10MHz (default), also scomp clock frequency
		
		-- define the clock here
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
architecture behavior of ece2031project is
	--addresses from register map
	CONSTANT master_addr : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110000"; -- 0x70
	CONSTANT sub1_addr   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110001"; -- 0x71
	CONSTANT sub2_addr   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110010"; -- 0x72
	CONSTANT sub3_addr  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110011"; -- 0x73
	CONSTANT master_cmd  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110100"; -- 0x74
	CONSTANT sub_cmd    : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110101"; -- 0x75
	CONSTANT timer_flags : STD_LOGIC_VECTOR(10 DOWNTO 0) := "00001110110"; -- 0x76

	-- stores the current count for each channel, initializes all counts to zero
	signal master_count : unsigned(15 downto 0) := "0000000000000000";
	signal sub1_count : unsigned(15 downto 0) := "0000000000000000";
	signal sub2_count : unsigned(15 downto 0) := "0000000000000000";
	signal sub3_count : unsigned(15 downto 0) := "0000000000000000";

	-- stores whether each channel is running or stopped
	-- '0' indicates timer is stopped; '1' indicates channel is enabled to run
	-- master_run must be '1' for any of the sub-channels to be able to run
	signal master_run : std_logic := '0';
	signal run1 : std_logic := '0';
	signal run2 : std_logic := '0';
	signal run3 : std_logic := '0';

	--stores counting mode for each sub-channel
	-- '0' is stopwatch mode where the channel counts up (default)
	-- '1' is countdown mode where the channel counts down (programmer must set a preset value using using register 0x71, 0x72, or 0x73)
	signal mode1 : std_logic := '0';
	signal mode2 : std_logic := '0';
	signal mode3 : std_logic := '0';

	-- stores the done flags for each sub-channel
	-- '0' indicates countdown is not complete (default)
	-- '1' indicates countdown has finished
	signal done1 : std_logic := '0';
	signal done2 : std_logic := '0';
	signal done3 : std_logic := '0';

	-- the fpga clock runs at 10mhz -> 10 million ticks per second
	-- dividing by 1000 gives us 10000 clock ticks per millisecond
	-- the programmer can use register 0x70 to set how many milliseconds
	-- elapse before the channels count up or down by 1
	constant ticks_per_ms : integer := clock_freq / 1000;

	-- counts how many fpga clock ticks have passed
	-- keeps counting until it reaches tick_period * ticks_per_ms
	-- once enough ticks pass, the timers update and clock_count starts over at 0
	signal clock_count : integer range 0 to 65535 * ticks_per_ms := 0;
	
	-- sets how many ms to wait before channels update
	-- the number of clock ticks we wait is tick_period * ticks_per_ms
	-- 1000 * 10000 = 10 million clock ticks, so the channels update once per second (default)
	-- example: 1 ms tick rate -> tick period is 1, so channels will update every 10000 clock ticks
	-- the programmer can change this value using register 0x70
	signal tick_period : integer range 1 to 65535 := 1000;
begin
	
process(resetn, clk_10mhz)
begin
	-- resets all channels and resets defaults
	if resetn = '0' then
	
	    -- go back to defualt tick period, reset clock count to zero
	    clock_count <= 0;
	    tick_period <= 1000;
	
	    -- reset all channel counts to 0
	    master_count <= "0000000000000000";
	    sub1_count   <= "0000000000000000";
	    sub2_count   <= "0000000000000000";
	    sub3_count   <= "0000000000000000";
	
	    -- stop channels
	    master_run <= '0';
	    run1 <= '0';
	    run2 <= '0';
	    run3 <= '0';
	
	    -- set sub-channels to stopwatch mode
	    mode1 <= '0';
	    mode2 <= '0';
	    mode3 <= '0';
	
	    -- clear done flags
	    done1 <= '0';
	    done2 <= '0';
	    done3 <= '0';

    elsif rising_edge(clk_10mhz) then
			-- start/stop, SCOMP does OUT to 0x74
        if io_write = '1' and io_addr = master_cmd then
            master_run <= data_in(0);   --figuring what is written in the lsb
        end if;

        -- counting logic 
        if master_run = '1' then
            if clock_count >= tick_period * ticks_per_ms - 1 then -- this is to keep it in line with how fpga clock ticks have gone by.
                clock_count  <= 0;
                master_count <= master_count + 1;
            else
                clock_count <= clock_count + 1; -- adding the fpga clock ticks
            end if;
        end if;
    end if;

end process;

end architecture behavior;
