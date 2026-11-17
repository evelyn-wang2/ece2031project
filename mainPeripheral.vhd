-- 11/11/2026
-- Evelyn, James, Patrick, Alina


-- 1. Library Declaration
library ieee;
library lpm;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use lpm.lpm_components.all;

-- 2. Entity Declaration (Inputs and Outputs)
entity multi_timer is
  port (
    clock,
    resetn      : in    std_logic;
    io_addr     : in    std_logic_vector(10 downto 0);
    io_read     : in    std_logic;
    io_write    : in    std_logic;
    io_data     : inout std_logic_vector(15 downto 0);
  );
end entity multi_timer;

-- 3. Architecture (Internal Logic)
architecture internals of multitimer is
  signal data_out : std_logic_vector(15 downto 0);
  signal io_en    : std_logic;
  signal master   : std_logic_vector(15 downto 0); -- master time signal
  signal sub1     : std_logic_vector(15 downto 0); -- signal for sub-timer count
  signal sub1ex   : std_logic_vector(15 downto 0); -- signal for sub-timer expiry time
  signal sub1run  : std_logic;                     -- sub-timer run status


  begin

  io_bus: lpm_bustri
  generic map (
    lpm_width => 16
  )
  port map (
		data     => data_out,
		enabledt => io_en,
		tridata  => io_data
  )

  process (clock, resetn, io_addr, io_read)
	BEGIN -- from original clock, signal names changed
		IF (RESETN = '0' OR ((IO_ADDR = "00000000010") AND (IO_WRITE = '1'))) THEN
			master <= x"0000";
		ELSIF (rising_edge(CLOCK)) THEN
			master <= master + 1;
		END IF;
	END PROCESS;
  begin
    if ((io_addr = "00001110001") and (io_write = '1')) then
      sub1ex <= (master + io_data);
    end if;
    if ((io_addr = "00001110101") and (io_write = '1')) then
      sub1run <= io_data(0);
      -- if (io_data(3) = '1') then
      --  sub1 <= x"0000";
    end if;


end internals;
