-- 11/11/2026
-- Evelyn, James, Patrick, Alina
--test pull

-- 1. Library Declaration
library ieee;
use ieee.std_logic_1164.all;

-- 2. Entity Declaration (Inputs and Outputs)
entity TimerPeripheral is
	generic (
		-- declares a setting you can choose when you instantiate the peripheral
		-- my friend is saying to like define the clock here
	);
	
  port ( -- these ins and outs are from the timers point of view
    clk    : in  std_logic;
    reset    : in  std_logic;
    io_addr : in std_logic_vector(7 downto 0); -- 8 bit IO address to tell which register 
	 io_write : in std_logic; -- tells peripheral scomp is exdcuting out
	 io_read : in std_logic; -- tells peripheral scomp is executing a in
	 data_in : in std_logic_vector(15 downto 0); -- coming into peripheral from scomp during na out
	 data_out : out std_logic_vector(15 downto o); -- data coming out of the peripheral during a read (like would carry timer count, running status, DONE flag etc)
	 
  );
end entity;

-- this stuff isnt what i added its just from the shell AND gate from before
-- 3. Architecture (Internal Logic)
architecture rtl of and_gate is
begin
  and_result <= input_1 and input_2;
end architecture rtl;
