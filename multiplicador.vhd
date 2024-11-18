-- Multiplicador de dos numeros de 16 bits
-- La multiplicacion comienza cuando se activa START durante un periodo del reloj del sistema
-- Previamente el multplicando y el multiplicador deben estar en las entradas A y B, respectivamente
-- El circuito activa la salida FIN cuando termina de realizar la operacion, que estara disponible
-- en la salida PRODUCTO
-- Autor: 
-- Fecha:

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multiplicador is
port(nRst      : in std_logic;
     clk       : in std_logic;
     start     : in std_logic;
     A         : in std_logic_vector(15 downto 0);
     B         : in std_logic_vector(15 downto 0);
     fin       : buffer std_logic;
     producto  : buffer std_logic_vector(31 downto 0)
     );
end entity;

architecture rtl of multiplicador is

  signal mndo, mdor : std_logic_vector(3 downto 0);
  signal res : std_logic_vector(7 downto 0);
  signal sum, factor : std_logic_vector(31 downto 0);
  signal enable : std_logic;
  signal ctrl : std_logic_vector(2 downto 0);
  signal q : std_logic_vector(3 downto 0);
  signal fdc : std_logic;
  signal ff_ctrl : std_logic;
begin

-----------------------------------------------------------------------------------------------------
-- Ejercicio 1
-----------------------------------------------------------------------------------------------------
  process(clk, nRst)
  begin
    if nRst = '0' then
      sum <= (others => '0');
    elsif clk'event and clk = '1' then
      if start = '1' then
        sum <= (others => '0');
      elsif enable = '1' then
        sum <= producto;
      end if;
    end if;
  end process;

  producto <= sum + factor;
-----------------------------------------------------------------------------------------------------
-- Ejercicio 2
-----------------------------------------------------------------------------------------------------
  factor <= x"000000"& res            when ctrl = 0 else
            x"00000" & res & x"0"     when ctrl = 1 else
            x"0000"  & res & x"00"    when ctrl = 2 else
            x"000"   & res & x"000"   when ctrl = 3 else
            x"00"    & res & x"0000"  when ctrl = 4 else
            x"0"     & res & x"00000" when ctrl = 5 else
                       res & x"000000";

-----------------------------------------------------------------------------------------------------
-- Ejercicio 3
-----------------------------------------------------------------------------------------------------

-- Modelo del multiplicador de 4 bits
  res <= mndo * mdor;
-- Selectores
  mndo <= b(3 downto 0)  when q(1 downto 0) = 0 else
          b(7 downto 4)  when q(1 downto 0) = 1 else
          b(11 downto 8) when q(1 downto 0) = 2 else
          b(15 downto 12);

  mdor <= a(3 downto 0)  when q(3 downto 2) = 0 else
          a(7 downto 4)  when q(3 downto 2) = 1 else
          a(11 downto 8) when q(3 downto 2) = 2 else
          a(15 downto 12);
-- Contador
  process(clk, nRst)
  begin
    if nRst = '0' then
      q <= (others => '0');
    elsif clk'event and clk = '1' then
      if start = '1' then
        q <= (others => '0');
      elsif enable = '1' then
        q <= q + 1;
      end if;
    end if;
  end process;

  fdc <= '1' when q = 15 else '0';

-----------------------------------------------------------------------------------------------------
-- Ejercicio 4
-----------------------------------------------------------------------------------------------------

-- Codificador

 ctrl <=  ('0' & q(1 downto 0)) +  ('0' & q(3 downto 2));
         
-- Control

 process(clk, nRst)
  begin
    if nRst = '0' then
      ff_ctrl <= '0';
    elsif clk'event and clk = '1' then
      if start = '1' then
        ff_ctrl <= '1';
      elsif fin = '1' then
        ff_ctrl <= '0';
      end if;
    end if;
  end process;

  enable <= ff_ctrl and not fdc;
  fin <= not enable and not start;
end rtl;
