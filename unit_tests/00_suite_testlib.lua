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

local m = {}

function m.test_del_tree()

   local tree_root = 'tree1'
   local tree = trees.tree1()
   test.make_tree( tree, tree_root )

   test.del_tree( tree_root )
   local check = pcall( test.read_tree, tree_root )
   assert( check == nil, "Was able to read from "..tree_root )
   
   return true
end

function m.test_tree1()

   local tree_root = 'tree1'
   local tree = trees.tree1()
   test.make_tree( tree, tree_root )

   local check = test.read_tree( tree_root )
   local bOk, msgs = test.compare_trees( tree, check )
   msgs = table.concat(msgs, '\n')
   assert( bOk, msgs )
   
   return true
end

-- function m.test_ex()
--    print("")
--    local my_tree = test.read_tree( 'src' )
--    test.dump_tree( my_tree )

--    my_tree.a.contents.b.contents["wozzy.txt"].mode = 'link'
--    my_tree.a.contents.b.contents["wozzy.txt"].contents = '../pssh.txt'   
--    test.make_tree( my_tree, 'dest' )
--    my_tree = test.read_tree( 'dest' )
--    test.dump_tree( my_tree )

--    return true
-- end

return test.execute_suite( m )
