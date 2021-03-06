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
   
   return retval
end

--[[
   An unbalanced tree of files/directories that includes empty directories.
]]
function m.tree2()

   local retval = { }
   retval['readme.txt'] = { mode = "file", nlink = 1, contents = "some readme",
			    symbolic_link = false }
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
   
   retval.x86 = { mode = "directory", nlink = 3, contents = {},
		  symbolic_link = false }
   retval.x86.contents["t03_check_send.txt"] = { mode = "file",
						 nlink = 1,
						 symbolic_link = false,
						 contents = "i686 send" }
   retval.x86.contents["t04_check_noop.txt"] = { mode = "file",
						 nlink = 1,
						 symbolic_link = false,
						 contents = "i686 no-op" }
   retval.x86.contents["t05_check_rcv.txt"] = { mode = "file",
						nlink = 1,
						symbolic_link = false,
						contents = "i686 receive" }
   
   retval.x86.contents.x86_64 = { mode = "directory", nlink = 2,
				  contents = {}, symbolic_link = false }
   retval.x86.contents.x86_64.contents["t09_check_noop.txt"] = {
      mode = "file",
      nlink = 1,
      symbolic_link = false,
      contents = "x86_64 no-op" }
   retval.x86.contents.x86_64.contents["t10_check_rcv.txt"] = {
      mode = "file",
      nlink = 1,
      symbolic_link = false,
      contents = "x86_64 receive" }
   retval.x86.contents.x86_64.contents["t11_check_send.txt"] = {
      mode = "file",
      nlink = 1,
      symbolic_link = false,
      contents = "x86_64 send" }
   
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
   
   retval.potato = { mode = "directory", nlink = 2, contents = {},
		     symbolic_link = false }

   retval.wood = { mode = "directory", nlink = 4, contents = {},
		   symbolic_link = false }
   retval.wood.contents.oak = { mode = "directory", nlink = 4, contents = {},
				symbolic_link = false }
   retval.wood.contents.pine = { mode = "directory", nlink = 4, contents = {},
				 symbolic_link = false }
   return retval
end

return m
