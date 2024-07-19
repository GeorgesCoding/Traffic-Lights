-- By George and Daniel

-- library declaration
library ieee;
use ieee.std_logic_1164.all;

-- declare ports (intputs/outputs)d
entity synchronizer is port (
			clk		: in std_logic; -- global clock signal
			reset		: in std_logic; -- synchronized reset 
			din		: in std_logic; -- data input
			dout		: out std_logic -- data output
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is

	-- 2 bit signal used to track register value
	Signal sreg		: std_logic_vector(1 downto 0);

BEGIN

-- change sreg depending on the clock signal
process (clk) is
begin
	if (rising_edge(clk)) then -- only evaluate if clock is on rising edge
	
		if (reset = '1') then -- if reset bit is active, set sreg to "00"
			sreg <= "00";
			
		else -- else, shift the bits of sreg left and concatonate din to sreg(0)
			sreg(1 downto 0) <= sreg(0) & din;
			
		end if;
		
	 end if;
	 
end process;

dout <= sreg(1); -- assigns data output the vzlue of the second register


end circuit;