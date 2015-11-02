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
-- Library of common unit test input trees
-------------------------------------------------------------------------------
local m = {}

--[[
   A simple tree of directories and files.
]]
function m.tree1()

   local retval = { }
   retval.alpha = { mode = "directory", nlink = 2, contents = {} }
   retval.alpha.contents["t00_check_send.txt"] = { mode = "file",
						   nlink = 1,
						   contents = "alpha send" }
   retval.alpha.contents["t01_check_rcv.txt"] = { mode = "file",
						  nlink = 1,
						  contents = "alpha receive" }
   retval.alpha.contents["t02_check_noop.txt"] = { mode = "file",
						   nlink = 1,
						   contents = "alpha no-op" }
   
   retval.i686 = { mode = "directory", nlink = 2, contents = {} }
   retval.i686.contents["t03_check_send.txt"] = { mode = "file",
						  nlink = 1,
						  contents = "i686 send" }
   retval.i686.contents["t04_check_noop.txt"] = { mode = "file",
						  nlink = 1,
						  contents = "i686 no-op" }
   retval.i686.contents["t05_check_rcv.txt"] = { mode = "file",
						 nlink = 1,
						 contents = "i686 receive" }
   
   retval.arm = { mode = "directory", nlink = 2, contents = {} }
   retval.arm.contents["t06_check_rcv.txt"] = { mode = "file",
						nlink = 1,
						contents = "arm receive" }
   retval.arm.contents["t07_check_send.txt"] = { mode = "file",
						 nlink = 1,
						 contents = "arm send" }
   retval.arm.contents["t08_check_noop.txt"] = { mode = "file",
						 nlink = 1,
						 contents = "arm no-op" }
   
   return retval
end

return m