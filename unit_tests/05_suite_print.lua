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
-- Test suite for the print subfunction
-------------------------------------------------------------------------------

-- Put filesystem delimiter into a global variable for later.
local fs_delim = package.config:sub(1,1)

-- Add lib subdirectory so that we can find the library..
local t = { '.', 'lib', '?.lua;' }
package.path = table.concat(t, fs_delim)..package.path

local lfs = require "lfs"
local test = require "lib/testlib"
local trees = require "lib/input_trees"

local test_root = 'src'
local test_script = 'lre-find'

local m = {}

function m.cleanup()
   test.del_tree( test_root )
end

-- Begin tests
function m.test_print()
   local exp_val = {
      "03: check send i686",
      "07: check send arm",
      "02: check noop alpha",
      "06: check rcv arm",
      "08: check noop arm",
      "04: check noop i686",
      "01: check rcv alpha",
      "05: check rcv i686",
      "00: check send alpha",
   }

   local tree = trees.tree1()

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"/(%w+)/t(%d+)_(%w+)_(%w+).txt"',
					      '-P', test_root, '-r',
					      '-p', '"%2: %3 %4 %1"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_pseudo_pipe()
   assert( false, "not implemented" )
   return true
end

return test.execute_suite( m )
