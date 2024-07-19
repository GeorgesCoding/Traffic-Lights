-- By George and Daniel

-- library declaration
library ieee;
use ieee.std_logic_1164.all;

-- delcare ports (inputs/outputs)
entity holding_register is port (

			clk				: in std_logic; -- clock signal
			reset				: in std_logic; -- synchronized reset signal
			register_clr	: in std_logic; -- register clear input 
			din				: in std_logic; -- data input bit
			dout				: out std_logic -- data output
  );
 end holding_register;
 
 -- define logic of circuit
 architecture circuit of holding_register is

	Signal sreg				: std_logic; -- signal to temporarily hold register value
	
BEGIN

-- activates based on changes in clock signal
process(clk, din, register_clr, reset, sreg) is
begin
-- activates only on rising edge of clock signal
	if (rising_edge(clk)) then
		
		-- sreg holds the value of the combinational logic of the register
		sreg <= (din OR sreg) AND not(register_clr OR reset);
		dout <= sreg; -- assign the data output the value of sreg
					
	end if;
		
end process;


end;