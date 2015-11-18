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
-- Test suite for the directory crawling code
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

   local tree_root = 'src'
   local tree = trees.tree1()

   test.make_tree( tree, tree_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"/(%w+)/(t%d+)_check_(%w+).txt"',
					      '-P', test_root, '-r',
					      '-p', '"tests/%3/%2_check_%1.txt"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_normal_heirarchy_with_missing()
   local exp_val = {
      "tests/send/t00_check_alpha.txt",
      "tests/noop/t02_check_alpha.txt",
      "tests/noop/t04_check_i686.txt",
      "tests/rcv/t05_check_i686.txt",
      "tests/rcv/t06_check_arm.txt",
      "tests/send/t07_check_arm.txt",
      "tests/noop/t08_check_arm.txt",
   }

   local tree = trees.tree1()

   test.make_tree( tree, test_root )

   -- Remove a few files
   assert( os.remove( table.concat( {'src', 'alpha', 't01_check_rcv.txt'},
				    fs_delim ) ) )

   assert( os.remove( table.concat( {'src', 'i686', 't03_check_send.txt'},
				    fs_delim ) ) )

   local code, lines = test.get_cmd_output( test_script,
					    { '"/(%w+)/(t%d+)_check_(%w+).txt"',
					      '-P', test_root, '-r',
					      '-p', '"tests/%3/%2_check_%1.txt"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_leaf_dirs()
   local exp_val = {
      "tests/src/arm",
      "tests/src/arm/t06_check_rcv.txt",
      "tests/src/alpha",
      "tests/src/alpha/t01_check_rcv.txt",
      "tests/src/arm/t08_check_noop.txt",
      "tests/src/x86",
      "tests/src/x86/x86_64",
      "tests/src/x86/x86_64/t09_check_noop.txt",
      "tests/src/x86/x86_64/t11_check_send.txt",
      "tests/src/arm/t07_check_send.txt",
      "tests/src/alpha/t00_check_send.txt",
      "tests/src/x86/t03_check_send.txt",
      "tests/src/alpha/t02_check_noop.txt",
      "tests/src/potato",
      "tests/src/wood",
      "tests/src/wood/oak",
      "tests/src/x86/x86_64/t10_check_rcv.txt",
      "tests/src/x86/t04_check_noop.txt",
      "tests/src/wood/pine",
      "tests/src/x86/t05_check_rcv.txt",
      "tests/src/readme.txt",
   }

   local test_root = 'src'
   local tree = trees.tree2()

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"^(%w+)/(.*)"',
					      '-P', test_root, '-r', 
					      '-p', '"tests/%1/%2"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_leaf_dirs_files_only()
   local exp_val = {
      "tests/src/arm/t06_check_rcv.txt",
      "tests/src/alpha/t01_check_rcv.txt",
      "tests/src/arm/t08_check_noop.txt",
      "tests/src/x86/x86_64/t09_check_noop.txt",
      "tests/src/x86/x86_64/t11_check_send.txt",
      "tests/src/arm/t07_check_send.txt",
      "tests/src/alpha/t00_check_send.txt",
      "tests/src/x86/t03_check_send.txt",
      "tests/src/alpha/t02_check_noop.txt",
      "tests/src/x86/x86_64/t10_check_rcv.txt",
      "tests/src/x86/t04_check_noop.txt",
      "tests/src/x86/t05_check_rcv.txt",
      "tests/src/readme.txt",
   }

   local test_root = 'src'
   local tree = trees.tree2()

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { test_root, '"^(%w+)/(.*)"',
					      '-P', test_root, '-f', '-r',
					      '-p', '"tests/%1/%2"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_leaf_dirs_dirs_only()
   local exp_val = {
      "tests/src/arm",
      "tests/src/alpha",
      "tests/src/x86",
      "tests/src/x86/x86_64",
      "tests/src/potato",
      "tests/src/wood",
      "tests/src/wood/oak",
      "tests/src/wood/pine",
   }

   local test_root = 'src'
   local tree = trees.tree2()

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { test_root, '"^(%w+)/(.*)"',
					      '-P', test_root, '-d', '-r', 
					      '-p', '"tests/%1/%2"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_nonrecursive()
   local exp_val = {
      "tests/src/arm",
      "tests/src/alpha",
      "tests/src/x86",
      "tests/src/potato",
      "tests/src/wood",
      "tests/src/readme.txt",
   }

   local test_root = 'src'
   local tree = trees.tree2()

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"^(%w+)/(.*)"',
					      '-P', test_root,
					      '-p', '"tests/%1/%2"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_absolute()
   local exp_val = {
      lfs.join(lfs.currentdir(), "tests","src","arm"),
      lfs.join(lfs.currentdir(),"tests","src","arm","t06_check_rcv.txt"),
      lfs.join(lfs.currentdir(),"tests","src","alpha"),
      lfs.join(lfs.currentdir(),"tests","src","alpha","t01_check_rcv.txt"),
      lfs.join(lfs.currentdir(),"tests","src","arm","t08_check_noop.txt"),
      lfs.join(lfs.currentdir(),"tests","src","x86"),
      lfs.join(lfs.currentdir(),"tests","src","x86","x86_64"),
      lfs.join(lfs.currentdir(),"tests","src","x86","x86_64","t09_check_noop.txt"),
      lfs.join(lfs.currentdir(),"tests","src","x86","x86_64","t11_check_send.txt"),
      lfs.join(lfs.currentdir(),"tests","src","arm","t07_check_send.txt"),
      lfs.join(lfs.currentdir(),"tests","src","alpha","t00_check_send.txt"),
      lfs.join(lfs.currentdir(),"tests","src","x86","t03_check_send.txt"),
      lfs.join(lfs.currentdir(),"tests","src","alpha","t02_check_noop.txt"),
      lfs.join(lfs.currentdir(),"tests","src","potato"),
      lfs.join(lfs.currentdir(),"tests","src","wood"),
      lfs.join(lfs.currentdir(),"tests","src","wood","oak"),
      lfs.join(lfs.currentdir(),"tests","src","x86","x86_64","t10_check_rcv.txt"),
      lfs.join(lfs.currentdir(),"tests","src","x86","t04_check_noop.txt"),
      lfs.join(lfs.currentdir(),"tests","src","wood","pine"),
      lfs.join(lfs.currentdir(),"tests","src","x86","t05_check_rcv.txt"),
      lfs.join(lfs.currentdir(),"tests","src","readme.txt"),
   }

   local test_root = 'src'
   local tree = trees.tree2()

   test.make_tree( tree, test_root )

   local code, lines = test.get_cmd_output( test_script,
					    { '"(src)/(.*)"',
					      '-P', test_root, '-r', '-a',
					      '-p', '"tests/%1/%2"' } )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

function m.test_default_root()
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

   local tree_root = 'src'
   local tree = trees.tree1()

   test.make_tree( tree, tree_root )

   -- Clear default exec path
   test.set_default_exec_path( '' )

   local scr = lfs.join( '..', '..', test_script )

   local code, lines = test.get_cmd_output( 'cd '..test_root..' && '..scr,
					    { '"(%w+)/(t%d+)_check_(%w+).txt"',
					      '-r',
					      '-p', '"tests/%3/%2_check_%1.txt"' } )

   -- Restore default exec path
   test.set_default_exec_path( )
   
   assert( code == 0, "Invalid return code: " .. tostring(code) )
   assert( test.compare_unordered_stdout( exp_val, lines ) )

   return true
end

return test.execute_suite( m )
