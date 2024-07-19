-- By George Chen and Daniel Khataiepour

-- library delcaration
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

-- declare ports for the board
ENTITY LogicalStep_Lab4_top IS
   PORT
	(
    clkin_50	: in	std_logic;							-- The 50 MHz FPGA Clockinput
	 rst_n		: in	std_logic;							-- The RESET input (ACTIVE LOW)
	 pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	 sw   		: in  	std_logic_vector(7 downto 0); -- The switch inputs
    leds			: out 	std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	
	-- temporary outputs for simulation purposes
	--simulation_sm_clken, simulation_blink_sig, simulation_NS_green, simulation_NS_amber, simulation_NS_red, simulation_EW_green, simulation_EW_amber, simulation_EW_red	:	out std_logic;

   seg7_data 	: out 	std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic							-- seg7 digi selectors
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS
   component segment7_mux port (
          clk        : in  	std_logic := '0';
			 DIN2 		: in  	std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 		: in  	std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0); -- 7 bit output to 7-segment
			 DIG2			: out	std_logic; -- output for digit 2
			 DIG1			: out	std_logic -- output for digit 1`
   );
   end component;

	-- clock generator component
   component clock_generator port (
			sim_mode			: in boolean; -- boolean True/False for if compiling for simulation purposes
			reset				: in std_logic; -- synchronized reset bit
         clkin      		: in  std_logic; -- clock input 
			sm_clken			: out	std_logic; -- clock enable output
			blink		  		: out std_logic -- traffic light blinking output
  );
   end component;

	-- pb fliter component
    component pb_filters port (
			clkin					: in std_logic; -- clock input
			rst_n					: in std_logic; -- reset bit, uninverted (active low)
			rst_n_filtered	   : out std_logic; -- filtered reset bit, still uninverted (active low)
			pb_n					: in  std_logic_vector (3 downto 0); -- 4 bit vector representing the four push buttons, uninverted (active low)
			pb_n_filtered	   : out	std_logic_vector(3 downto 0)	-- filtered push button representation,l uninverted (active low)
 );
   end component;
	
-- push button inverters component
	component pb_inverters port (
			rst_n					 : in  std_logic; -- reset bit, uninverted (active low)
			rst				    : out	std_logic; -- reset bit, inverted (active high)
			pb_n_filtered	    : in  std_logic_vector (3 downto 0); -- filtered push button represented by 4 bit vector, uninverted (active low)
			pb						 : out	std_logic_vector(3 downto 0)	-- four push buttons represented by a 4 bit vector, inverted (active high)						 
  );
   end component;
	
-- synchronizer component	
	component synchronizer port(
			clk					: in std_logic; -- global clock input
			reset					: in std_logic; -- synchronized reset input
			din					: in std_logic; -- data input bit
			dout					: out std_logic -- data output bit
  );
	end component; 
	
	-- holding register component declaration
  component holding_register port (
			clk					: in std_logic; -- global clock input
			reset					: in std_logic; -- synchronized reset input
			register_clr		: in std_logic; -- register clear input
			din					: in std_logic; -- data input 
			dout					: out std_logic -- data output
  );
  end component;			
  
  -- Moore state machine declaration
component State_Machine is port
(
	clk			: in std_logic; -- global clock input
	reset			: in std_logic; -- synchronized reset input
	clken			: in std_logic; -- clock enable input, used to enable the state machine
	blink			: in std_logic; -- traffic light blink input, used to blink the green traffic light
	NS_request	: in std_logic; -- NS pedestrian request, pb(0)
	EW_request	: in std_logic; -- EW pedestrian request, pb(1)
	
	NS_crossing, EW_crossing	:  out std_logic; -- NS and EW safe pedestrian crossing signal, for leds(0) and leds(2), 1 for adtive, 0 for off
	NS_clear, EW_clear			:	out std_logic; -- NS and EW pedestrian request clear signals
	NS_green, NS_amber, NS_red	:	out std_logic; -- NS traffic light colours
	EW_green, EW_amber, EW_red :  out std_logic; -- EW traffic light colours
	state			: out std_logic_vector(3 downto 0) -- 4 bit vector to represent the state of the state machine as a binary number
 );
end component;
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode								: boolean := FALSE;  -- set to FALSE for LogicalStep board download -- set to TRUE for SIMULATIONS
	SIGNAL rst, rst_n_filtered, synch_rst	: std_logic; -- holding reset signals
	SIGNAL sm_clken, blink_sig					: std_logic; -- holding clock enable and blink signals
	SIGNAL pb_n_filtered, pb					: std_logic_vector(3 downto 0); -- push button values
	signal syncEW_out, syncNS_out				: std_logic; -- EW and NS synchronizer outputs (pedestrian requests)
	signal NS_display, EW_display				: std_logic; -- EW and NS pedestrian crossing values
	signal NS_lights, EW_lights				: std_logic_vector(6 downto 0); -- concatonated traffic light digits
	signal NS_green, NS_amber, NS_red		: std_logic; -- NS traffic light colours
	signal EW_green, EW_amber, EW_red		: std_logic; -- EW traffic light colours
	signal holdEW_out, holdNS_out				: std_logic; -- EW and NS holding register outputs (traffic light outputs)
	signal stateNum								: std_logic_vector(3 downto 0); -- 4 bit vector to hold the state of state machien as a binary number
	signal NS_clear, EW_clear					: std_logic; -- holds pedestrian request clear signals
	
BEGIN
----------------------------------------------------------------------------------------------------
filter: pb_filters		port map (clkin_50, rst_n, rst_n_filtered, pb_n, pb_n_filtered); -- filters buttons
inverter: pb_inverters	port map (rst_n_filtered, rst, pb_n_filtered, pb); -- inverts buttons
syncRST: synchronizer   port map (clkin_50, synch_rst, rst, synch_rst);	-- the synchronizer is also reset by synch_rst. generates synchronous reset signal
clock: clock_generator 	port map (sim_mode, synch_rst, clkin_50, sm_clken, blink_sig); -- generates global clockj signal

sycnEW: synchronizer	port map(clkin_50, synch_rst, pb(1), syncEW_out); -- synchronizer for EW traffic light
sycnNS: synchronizer	port map(clkin_50, synch_rst, pb(0), syncNS_out); -- synchronizer for NS traffic light

holdEW: holding_register port map (clkin_50, synch_rst, EW_clear, syncEW_out, holdEW_out); -- holding register for EW intersection
holdNS: holding_register port map (clkin_50, synch_rst, NS_clear, syncNS_out, holdNS_out); -- holding register for NS intersection
leds(3) <= holdEW_out; -- displays the EW pedestrian request to leds(3)
leds(1) <= holdNS_out; -- displays the NS pedestrian request to leds(3)

-- Moore state machine, goes through the various states and controls traffic lights
stateMCHN:	State_Machineport map(clkin_50, synch_rst, sm_clken, blink_sig, holdNS_out, holdEW_out, NS_display, EW_display, NS_clear, EW_clear, NS_green, NS_amber, NS_red, EW_green, EW_amber, EW_red, stateNum);
leds(0) <= NS_display; -- displays the NS crossing state in leds(0)
leds(2) <= EW_display; -- displays the EW crossing state to leds(2)
leds(7 downto 4) <= stateNum; -- displays the 4 bit binary number to leds(7 downto 0)

segMUX: segment7_mux	port map (clkin_50, NS_lights, EW_lights, seg7_data, seg7_char2, seg7_char1); -- segment7_mux to display the trafifc light digit values
NS_lights(6 downto 0) <= NS_amber & "00" & NS_green & "00" & NS_red; -- concatonate the traffic light digits for NS into 7 bit number using the given format from segment7_mux
EW_lights(6 downto 0) <= EW_amber & "00" & EW_green & "00" & EW_red; -- concatonate the traffic light digits for EW into 7 bit number using the given format from segment7_mux

-- temporary outputs for simulation purposes
--simulation_sm_clken <= sm_clken;
--simulation_blink_sig <= blink_sig;
--simulation_NS_green <= NS_green;
--simulation_NS_amber <= NS_amber;
--simulation_NS_red <= NS_red;
--simulation_EW_green <= EW_green;
--simulation_EW_amber <= EW_amber;
--simulation_EW_red <= EW_red;

END SimpleCircuit;