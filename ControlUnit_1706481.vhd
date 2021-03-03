----------------------------------------------------------------------------------
-- Company: 		ITESM Campus Qro
-- Engineer: 		A01706481 - Luis Angel Zavala Robles
-- 
-- Create Date:    02/25/2021 
-- Design Name: 
-- Module Name:    ControlUnit 
-- Project Name: 	 Control Unit
-- Target Devices: MAX DE10-LITE FPGA BOARD
-- Tool versions:  Quartus Prime Lite 18.1
-- Description: 	 Challenge Evidence 2. Unit Control
--
-- Dependencies: 
--
-- Revision: 		v1.0
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

-- Library and package declaration--
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_unsigned.all;

ENTITY ControlUnit_1706481 IS
  PORT (
		Clk_1706481						: IN STD_LOGIC;
		Rst_1706481						: IN STD_LOGIC;
		Data_Identifier_1706481		: IN STD_LOGIC;
		S_1706481						: OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
		unusedLEDs_1706481			: OUT STD_LOGIC_VECTOR(3 DOWNTO 0)); -- Used only to turn off the unused leds of DE10-Lite Board
END ControlUnit_1706481;


ARCHITECTURE A01706481 OF ControlUnit_1706481 IS
   -- State name declaration as binary state
	TYPE state_names IS (Start, PulseROM, PulseROM2, PulsePC_RI, PulsePC_RD, PulseAcumT, PulseAcumP);
	
	--	Signals used in FSM 
	SIGNAL present_state	: state_names;
	SIGNAL next_state		: state_names;

	-- Signals used in frequency divider  
	SIGNAL OscCount        : natural range 0 to (50_000_000 / 1);
	SIGNAL	ClkEn			  : STD_LOGIC; 

BEGIN
---------------------------------------------------------------
-------------------Frequency Divider -------------------------- 
  	PROCESS(Rst_1706481, Clk_1706481)								---
	BEGIN																		---
		IF(Rst_1706481 = '0') THEN										---
			OscCount <= 0;													---
		ELSIF (rising_edge(clk_1706481)) THEN						---
			IF(OscCount = 50_000_000 / 1) THEN					   ---
				ClkEn <= '1';												---
				OscCount <= 0;												---
			ELSE																---
				ClkEn <= '0';												---
				OscCount <= OscCount + 1;								---
			END IF;															---
		END IF;																---
	END PROCESS;															---
---------------------------------------------------------------
---------------------------------------------------------------
	
	
	
-----------------Begin Moore State Machine --------------------

	-- State register definition process.
	statereg: PROCESS(Clk_1706481, Rst_1706481)
	BEGIN
		IF (Rst_1706481 = '0') THEN
			present_state <= Start;
		ELSIF( rising_edge(Clk_1706481)) THEN
			IF(ClkEn = '1') THEN
				present_state <= next_state;
			END IF;
		END IF;
	END PROCESS;
	
	
	-- Next state logic definition, this is a combinatorial process useful to put in statements the state diagram
	fsm: PROCESS(Data_Identifier_1706481, present_state)
	BEGIN
		CASE present_state IS
			
			WHEN PulsePC_RI	=>	
					IF(Data_Identifier_1706481 = '1') 	  THEN next_state	<= PulseROM2;
					ELSIF(Data_Identifier_1706481 = '0')  THEN next_state	<= PulseAcumT;
					ELSE										          next_state	<= PulsePC_RI;
					END IF;
			WHEN Start 			=>							 next_state	<= PulseROM;
			WHEN PulseROM		=>						    next_state	<= PulsePC_RI;
			WHEN PulseROM2		=>							 next_state	<= PulsePC_RD;
			WHEN PulsePC_RD	=>							 next_state	<= PulseAcumT;
			WHEN PulseAcumT	=>							 next_state	<= PulseAcumP;
			WHEN PulseAcumP	=>							 next_state	<= PulseROM;
			
			WHEN OTHERS			=>							 next_state	<= Start;
		END CASE;
		
	END PROCESS;
	
	
	-- Output logic definition of Moore State Machine, Outputs depende only on the current state 
	outputs: PROCESS(present_state)
	BEGIN
		CASE present_state IS
			WHEN Start 			=> S_1706481 <= "000000";
			WHEN PulseROM		=>	S_1706481 <= "100000";
			WHEN PulseROM2		=>	S_1706481 <= "100000";
			WHEN PulsePC_RI	=>	S_1706481 <= "011000";
			WHEN PulsePC_RD	=>	S_1706481 <= "010100";
			WHEN PulseAcumT	=>	S_1706481 <= "000010";
			WHEN PulseAcumP	=>	S_1706481 <= "000001";
			WHEN OTHERS			=> S_1706481 <= "000000";
		END CASE;
	
	END PROCESS;
	
	-- Turn off unused LEDs to better visualization in DE10-Lite
	UnusedLEDs_1706481 <=	(others	=> '0');

END A01706481;