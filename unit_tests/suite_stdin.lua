#!/usr/bin/env lua

-- Copyright (C) 2015 Jeff Backus(jeff@jsbackus.com)
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use, copy,
-- modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
-- BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
-- ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-------------------------------------------------------------------------------
-- Test suite for taking a path list from STDIN.
-------------------------------------------------------------------------------
local suite_name = "stdin"

-- Put filesystem delimiter into a global variable for later.
local fs_delim = package.config:sub(1,1)

-- Add lib subdirectory so that we can find the library..
local t = { '.', 'lib', '?.lua;' }
package.path = table.concat(t, fs_delim)..package.path

local lfs = require "lfs"
local test = require "lib/testlib"

local test_file = "stdin_tests.stdin.txt"

local m = {}

-- Begin support functions

--[[
   A simple input scheme
]]
function m.input_scheme1()
   
   local fdata = [[
src/alpha/t00_check_send.txt
src/alpha/t01_check_rcv.txt
src/alpha/t02_check_noop.txt
src/i686/t03_check_send.txt
src/i686/t04_check_noop.txt
src/i686/t05_check_rcv.txt
src/arm/t06_check_rcv.txt
src/arm/t07_check_send.txt
src/arm/t08_check_noop.txt
]]

   local fout = assert( io.open( test_file, "w" ) )
   fout:write( fdata )
   fout:close()
end

function m.cleanup()
   os.remove( test_file )
end

-- Begin tests
function m.test_simple_match()
   local exp_val = {
      "tests/send/t00_check_alpha.txt",
      "tests/rcv/t01_check_alpha.txt",
      "tests/noop/t02_check_alpha.txt",
      "tests/send/t03_check_i686.txt",
      "tests/noop/t04_check_i686.txt",
      "tests/rcv/t05_check_i686.txt",
      "tests/rcv/t06_check_arm.txt",
      "tests/send/t07_check_arm.txt",
      "tests/noop/t08_check_arm.txt",
   }

   m.input_scheme1()

   test.set_default_exec_path( "" )
   
   local code, lines = test.get_cmd_output( 'cat '..test_file..' | ../lre-find', { '"/(%w+)/(t%d+)_check_(%w+).txt"', '--', '-p', 'tests/%3/%1_check_%2.txt' } )
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_stdout( exp_val, lines ) )

   return true
end

return test.execute_suite( suite_name, m )
