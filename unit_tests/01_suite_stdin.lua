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
local trees = require "lib/input_trees"

local test_file = "stdin_tests.stdin.txt"
local test_script = "run_stdin_test.sh"

local m = {}

-- Begin support functions

--[[
   Creates an input file and a script to send its contents to lre-find.

   Populates the input file with the paths of all leaf items, including empty
   directories.
]]
function m.create_test_file( tree, parent )
   
   local fout = assert( io.open( test_script, "w" ) )
   fout:write( "cat "..test_file.." | ../lre-find $@\n" )
   fout:close()

   local crawler
   crawler = function( sub_tree, path )
      local is_leaf = true
      if( type(sub_tree) == "table" ) then
	 for k, v in pairs( sub_tree ) do
	    local new_tree = {}
	    if( v.mode == "directory" ) then
	       new_tree = v.contents
	    end
	    crawler( new_tree, path..fs_delim..k )
	    is_leaf = nil
	 end
      end
      if( is_leaf ) then
	 coroutine.yield( path.."\n" )
      end
   end

   fout = assert( io.open( test_file, "w" ) )
   for path in coroutine.wrap( function() crawler(tree, parent) end) do
      fout:write( path )
   end
   fout:close()
end

function m.cleanup()
   assert( os.remove( test_file ) )
   assert( os.remove( test_script ) )
end

-- Begin tests
function m.test_normal_heirarchy()
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

   local tree = trees.tree1()
   test.dump_tree( tree )
   m.create_test_file( tree, 'src' )
   test.make_tree( tree, 'src' )
--   local pfft = test.read_tree( 'src' )
--   test.dump_tree( pfft )

   test.set_default_exec_path( "" )
   
   local code, lines = test.get_cmd_output( '/bin/sh '..test_script,
					    { '"/(%w+)/(t%d+)_check_(%w+).txt"',
					      '--', '-p',
					      'tests/%3/%2_check_%1.txt' } )
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

return test.execute_suite( suite_name, m )
