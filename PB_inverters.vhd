-- By George Chen and Daniel Khataiepour


-- declare libraries
library ieee;
use ieee.std_logic_1164.all;

-- declare ports (inputs/outputs)
entity PB_inverters is port (
	rst_n				: in	std_logic; -- reset button
	rst				: out std_logic; -- inverted reset
 	pb_n_filtered	: in  std_logic_vector (3 downto 0); -- push buttons on board
	pb					: out	std_logic_vector(3 downto 0)	-- inverted push buttons						 
	); 
end PB_inverters;

architecture ckt of PB_inverters is

begin
rst <= NOT(rst_n); -- invert reset button from active low to active high
pb <= NOT(pb_n_filtered); -- invert reset button from active low to active high


end ckt;