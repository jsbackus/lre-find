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
-- Test suite for the link subfunction
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
local targ_root = 'tests'
local test_script = 'lre-find'

local m = {}

function m.cleanup()
   test.del_tree( test_root )
   test.del_tree( targ_root )
end

-- Begin tests
function m.test_flat()
   local tree = trees.tree2()

   local match = "/([%w_]+)/t(%d+)_([%w_]+)_([%w_]+).txt"
   local pat = "%2_%3_%4_%1"

   local exp_tree = { }
   -- Flatten the target tree, converting files into links
   local queue = { { record = tree, path = test_root } }
   local i = 1
   local next_free = 2
   while queue[ i ] do
      for entry, record in pairs( queue[ i ].record ) do
	 local pathname = lfs.join(queue[ i ].path, entry)
	 
	 if( record.mode == "directory" ) then
	    -- Append directory to queue
	    queue[ next_free ] = { record = record.contents, path = pathname }
	    next_free = next_free + 1
	 else
	    -- Convert name, and add a symlink with contents equal to record
	    -- path
	    local newname = pathname:gsub( ".*"..match, pat )
	    if( newname ~= pathname ) then
	       exp_tree[ newname ] = { symbolic_link = true, contents = pathname } 
	    end
	 end
      end
      -- Remove entry
      queue[ i ] = nil
      
      -- Move on to next entry
      i = i + 1      
   end

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"'..match..'"',
					      '-P', test_root, '-r',
					      '-s', '"'..lfs.join(targ_root,pat)..'"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )

   local check = test.read_tree( targ_root )
   
   local bOk, msgs = test.compare_trees( exp_tree, check )
   msgs = table.concat(msgs, '\n')
   assert( bOk, msgs )

   return true
end

function m.test_hierarchy()
   local tree = trees.tree1()

   local match = "/([%w_]+)/t(%d+)_([%w_]+)_([%w_]+).txt"
   local pat = "%2/%3/%4/%1.test"

   local exp_tree = { }
-- TODO
   retval.alpha = { mode = "directory", nlink = 2, contents = {},
		    symbolic_link = false }
   retval.alpha.contents["t00_check_send.txt"] = { mode = "file",
						   nlink = 1,
						   symbolic_link = false,
						   contents = "alpha send" }
   retval.alpha.contents["t01_check_rcv.txt"] = { mode = "file",
						  nlink = 1,
						   symbolic_link = false,
						  contents = "alpha receive" }
   retval.alpha.contents["t02_check_noop.txt"] = { mode = "file",
						   nlink = 1,
						   symbolic_link = false,
						   contents = "alpha no-op" }
   
   retval.i686 = { mode = "directory", nlink = 2, contents = {},
		    symbolic_link = false }
   retval.i686.contents["t03_check_send.txt"] = { mode = "file",
						  nlink = 1,
						  symbolic_link = false,
						  contents = "i686 send" }
   retval.i686.contents["t04_check_noop.txt"] = { mode = "file",
						  nlink = 1,
						  symbolic_link = false,
						  contents = "i686 no-op" }
   retval.i686.contents["t05_check_rcv.txt"] = { mode = "file",
						 nlink = 1,
						 symbolic_link = false,
						 contents = "i686 receive" }
   
   retval.arm = { mode = "directory", nlink = 2, contents = {},
		    symbolic_link = false }
   retval.arm.contents["t06_check_rcv.txt"] = { mode = "file",
						nlink = 1,
						symbolic_link = false,
						contents = "arm receive" }
   retval.arm.contents["t07_check_send.txt"] = { mode = "file",
						 nlink = 1,
						 symbolic_link = false,
						 contents = "arm send" }
   retval.arm.contents["t08_check_noop.txt"] = { mode = "file",
						 nlink = 1,
						 symbolic_link = false,
						 contents = "arm no-op" }

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"'..match..'"',
					      '-P', test_root, '-r',
					      '-s', '"'..lfs.join(targ_root,pat)..'"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )

   local check = test.read_tree( targ_root )
   
   local bOk, msgs = test.compare_trees( exp_tree, check )
   msgs = table.concat(msgs, '\n')
   assert( bOk, msgs )

   return true
end

function m.test_absolute()
   assert( false, "not implemented" )
   return true
end

return test.execute_suite( m )
