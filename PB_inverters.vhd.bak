library ieee;
use ieee.std_logic_1164.all;


entity PB_inverters is port (
	rst_n				: in	std_logic;
	rst				: out std_logic;
 	pb_n_filtered	: in  std_logic_vector (3 downto 0);
	pb					: out	std_logic_vector(3 downto 0)							 
	); 
end PB_inverters;

architecture ckt of PB_inverters is

begin
rst <= NOT(rst_n);
pb <= NOT(pb_n_filtered);


end ckt;