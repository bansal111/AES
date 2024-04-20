-- VHDL implementation of AES
-- Copyright (C) 2019  Hosein Hadipour

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

entity aes_enc is 
	port (
		clk : in std_logic;
		rst : in std_logic;
		--key : in std_logic_vector(127 downto 0);
		plain_text : in std_logic_vector(15 downto 0);
		ciphertext : out std_logic_vector(15 downto 0)
		--done : out std_logic		
	);
end aes_enc;

architecture behavioral of aes_enc is
	signal reg_input : std_logic_vector(127 downto 0);
	signal reg_output : std_logic_vector(127 downto 0);
	signal subbox_input : std_logic_vector(127 downto 0);
	signal subbox_output : std_logic_vector(127 downto 0);
	signal shiftrows_output : std_logic_vector(127 downto 0);
	signal mixcol_output : std_logic_vector(127 downto 0);
	signal feedback : std_logic_vector(127 downto 0);
	signal round_key : std_logic_vector(127 downto 0);
	signal round_const : std_logic_vector(7 downto 0);
	signal sel : std_logic;
	signal key: std_logic_vector(127 downto 0):= x"3243f6a8885a308d313198a2e0370734";
	signal plaintext :std_logic_vector(127 downto 0);
	signal plain_saved:std_logic_vector(127 downto 16):= x"2b7e151628aed2a6abf7158809cf";
	signal done:std_logic;
begin
plaintext<= plain_text(15 downto 0)&plain_saved(127 downto 16);
	reg_input <= plaintext when rst = '0' else feedback;
	reg_inst : entity work.reg
		generic map(
			size => 128
		)
		port map(
			clk => clk,
			d   => reg_input,
			q   => reg_output
		);
	-- Encryption body
	add_round_key_inst : entity work.add_round_key
		port map(
			input1 => reg_output,
			input2 => round_key,
			output => subbox_input
		);
	sub_byte_inst : entity work.sub_byte
		port map(
			input_data  => subbox_input,
			output_data => subbox_output
			
		);
	shift_rows_inst : entity work.shift_rows
		port map(
			input  => subbox_output,
			output => shiftrows_output
		);
	mix_columns_inst : entity work.mix_columns
		port map(
			input_data  => shiftrows_output,
			output_data => mixcol_output
		);
	feedback <= mixcol_output when sel = '0' else shiftrows_output;
	ciphertext <= subbox_input(127 downto 112);	
	-- Controller
	controller_inst : entity work.controller
		port map(
			clk            => clk,
			rst            => rst,
			rconst         => round_const,
			is_final_round => sel,
			done           => done
		);
	-- Keyschedule
	key_schedule_inst : entity work.key_schedule
		port map(
			clk         => clk,
			rst         => rst,
			key         => key,
			round_const => round_const,
			round_key   => round_key
		);	
		--ciphertext<= subbox_input (127 downto 112);
end architecture behavioral;
