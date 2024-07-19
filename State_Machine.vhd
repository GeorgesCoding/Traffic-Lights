-- By George Chen and Daniel Khataiepour

-- libvrary declaration
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- delcare ports (inputs/outputs)
-- represnets traffic light throguh a Moore state machine
entity State_Machine is port
(
	clk			: in std_logic; -- global clock signal
	reset			: in std_logic; -- synchronized reset signal
	clken			: in std_logic; -- clock enable signal
	blink			: in std_logic; -- blink signal
	NS_request	: in std_logic; -- NS pedestrian request
	EW_request	: in std_logic; -- EW pedestrian request
	
	NS_crossing, EW_crossing	:  out std_logic; -- output to represent the crossing duration in each intersection
	NS_clear, EW_clear			:	out std_logic; -- clears pedestrian requests
	NS_green, NS_amber, NS_red	:	out std_logic; -- NS traffic lights
	EW_green, EW_amber, EW_red :  out std_logic; -- EW traffic lights
	state			: out std_logic_vector(3 downto 0) -- 4 bit binary number to represent the current state of the state machine
 );
end entity;

-- define logic of state machine
architecture SM of State_Machine is

-- list state names
type state_names is (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15);
signal current_state, next_state	: state_names; -- internal signals to represent the current and next state

begin
-- register section, will change according to the clock
register_section: process(clk)

begin
	-- will only occur on rising edge of clock
	if(rising_edge(clk)) then
	
		-- reset is active, so return to beginning state (s0)
		if (reset = '1') then
			current_state <= s0;
			
		-- reset is not active and state machine is enabled, so go to the next state	
		elsif (clken = '1') then
			current_state <= next_state;
			
		end if;
		
	end if;

end process;

-- transition section, will update the state depending if there is a pedestrian request
transition_section: process(current_state)

begin
	case current_state is -- determines the next state according to current state and pedestiran requests
	
		-- if EW request is on and NS request os off, then skip to s6
		when s0 =>
			if (EW_request = '1' AND NS_request = '0') then 
				next_state <= s6;
			else
				next_state <= s1; -- pedestiran request is not activated, so go to next state
			end if;
		
		-- if EW request is on and NS request os off, then skip to s6
		when s1 =>
			if (EW_request = '1'AND NS_request = '0') then 
				next_state <= s6;
			else
				next_state <= s2;		 -- pedestiran request is not activated, so go to next state
			end if;
		
			-- goes to the next state in chronological order
		when s2 =>
			next_state <= s3;
			
		when s3 =>
			next_state <= s4;
			
		when s4 =>
			next_state <= s5;
			
		when s5 =>
			next_state <= s6;
			
		when s6 =>
			next_state <= s7;
			
		when s7 =>
			next_state <= s8;
			
		-- if EW request is off and NS request is on, then skip to s14
		when s8 =>
			if (NS_request = '1' AND EW_request = '0') then
				next_state <= s14;
			else
				next_state <= s9; -- pedestiran request is not activated, so go to next state 
			end if;
			
		-- if EW request is off and NS request is on, then skip to s14	
		when s9 =>
			if (NS_request = '1' AND EW_request = '0') then
				next_state <= s14;
			else
				next_state <= s10; -- pedestiran request is not activated, so go to next state
			end if;		
			
		-- goes to the next state in chronological order	
		when s10 =>
			next_state <= s11;
			
		when s11 =>
			next_state <= s12;
			
		when s12 =>
			next_state <= s13;
			
		when s13 =>
			next_state <= s14;
			
		when s14 =>
			next_state <= s15;
			
		when s15 =>
			next_state <= s0; -- final state reached, so go back to the start (s0)
						
	end case;
end process;


-- decoder section, responsible for outputting the traffic lights, state number, if safe for crossing and clears the pedestrian request
decoder_section: process(current_state)
begin
	case current_state is -- assigns outputs based on the current state
	
		-- blinks the NS green light and turns on red light for EW
		-- everything else is off
		when s0 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
		
			NS_green		<= blink;
			NS_amber		<=	'0';
			NS_red		<= '0';
						
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0000"; -- sets state number to 0
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';
		
		-- blinks the NS green light and turns on red light for EW
		-- everything else is off			
		when s1 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
		
			NS_green		<= blink;
			NS_amber		<=	'0';
			NS_red		<= '0';			
			
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0001";	-- sets state number to 1
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';
			
		-- Turns on NS green light to be solid. since is a solid green light, NS_crossing is turned on
		-- EW is still red	
		when s2 =>
			NS_crossing <= '1';
			EW_crossing <= '0';
					
			NS_green		<= '1';
			NS_amber		<=	'0';
			NS_red		<= '0';			
					
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0010";	-- sets state number to 2
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';		
		
		-- Turns on NS green light to be solid. since is a solid green light, NS_crossing is turned on
		-- EW is still red			
		when s3 =>
			NS_crossing <= '1';
			EW_crossing <= '0';
					
			NS_green		<= '1';
			NS_amber		<=	'0';
			NS_red		<= '0';			
					
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0011";	-- sets state number to 3
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
	
		-- Turns on NS green light to be solid. since is a solid green light, NS_crossing is turned on
		-- EW is still red		
		when s4 =>
			NS_crossing <= '1';
			EW_crossing <= '0';
					
			NS_green		<= '1';
			NS_amber		<=	'0';
			NS_red		<= '0';			
					
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0100";	-- sets state number to 4
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';
			
		-- Turns on NS green light to be solid. since is a solid green light, NS_crossing is turned on
		-- EW is still red				
		when s5 =>
			NS_crossing <= '1';
			EW_crossing <= '0';
					
			NS_green		<= '1';
			NS_amber		<=	'0';
			NS_red		<= '0';			
					
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0101";	-- sets state number to 5
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
	
		-- Turns on NS amber light, no longer solid green so NS_crossing is turned off.
		-- EW is still red
		-- clears the pedestrian request in the NS direction
		when s6 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
					
			NS_green		<= '0';
			NS_amber		<=	'1';
			NS_red		<= '0';			
					
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0110"; -- sets state number to 6
			
			NS_clear 	<= '1';
			EW_clear 	<= '0';		
			
		-- Turns on NS amber light, no longer solid green so NS_crossing is turned off.
		-- EW is still red			
		when s7 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
					
			NS_green		<= '0';
			NS_amber		<=	'1';
			NS_red		<= '0';			
					
			EW_green		<= '0';
			EW_amber		<=	'0';
			EW_red		<= '1';
			
			state			<= "0111";	-- sets state number to 7
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';
			
		-- blinks the EW green light and turns on red light for NS
		-- everything else is off				
		when s8 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= blink;
			EW_amber		<=	'0';
			EW_red		<= '0';
			
			state			<= "1000"; -- sets state number to 8
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';
			
		-- blinks the NS green light and turns on red light for EW
		-- everything else is off				
		when s9 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= blink;
			EW_amber		<=	'0';
			EW_red		<= '0';
			
			state			<= "1001";	-- sets state number to 9
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
			
		-- Turns on ew green light to be solid. since is a solid green light, EW_crossing is turned on
		-- NS is still red			
		when s10 =>
			NS_crossing <= '0';
			EW_crossing <= '1';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= '1';
			EW_amber		<=	'0';
			EW_red		<= '0';
			
			state			<= "1010";	-- sets state number to 10
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
			
		-- Turns on ew green light to be solid. since is a solid green light, EW_crossing is turned on
		-- NS is still red			
		when s11 =>
			NS_crossing <= '0';
			EW_crossing <= '1';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= '1';
			EW_amber		<=	'0';
			EW_red		<= '0';
			
			state			<= "1011";	 -- sets state number to 11
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';
			
		-- Turns on ew green light to be solid. since is a solid green light, EW_crossing is turned on
		-- NS is still red			
		when s12 =>
			NS_crossing <= '0';
			EW_crossing <= '1';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= '1';
			EW_amber		<=	'0';
			EW_red		<= '0';
			
			state			<= "1100";	-- sets state number to 12
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
	
		-- Turns on ew green light to be solid. since is a solid green light, EW_crossing is turned on
		-- NS is still red	
		when s13 =>
			NS_crossing <= '0';
			EW_crossing <= '1';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= '1';
			EW_amber		<=	'0';
			EW_red		<= '0';
			
			state			<= "1101";-- sets state number to 13
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
	
		-- Turns on EW amber light, no longer solid green so EW_crossing is turned off.
		-- NS is still red
		-- clears the pedestirna request for EW direction
		when s14 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';			
					
			EW_green		<= '0';
			EW_amber		<=	'1';
			EW_red		<= '0';
			
			state			<= "1110"; -- sets state number to 14
			
			NS_clear 	<= '0';
			EW_clear 	<= '1';	
		
		-- Turns on EW amber light, no longer solid green so EW_crossing is turned off.
		-- NS is still red	
		when s15 =>
			NS_crossing <= '0';
			EW_crossing <= '0';
					
			NS_green		<= '0';
			NS_amber		<=	'0';
			NS_red		<= '1';
						
			EW_green		<= '0';
			EW_amber		<=	'1';
			EW_red		<= '0';
			
			state			<= "1111"; -- sets state number to 15
			
			NS_clear 	<= '0';
			EW_clear 	<= '0';	
		
		
		end case;
	end process;

end architecture SM;