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
-- Library of common unit test functions
-------------------------------------------------------------------------------

local m = {}

local lfs = require "lfs";

-- Put filesystem delimiter into a global variable for later.
local fs_delim = package.config:sub(1,1)

--[[ 
   Executes all tests in the specified suite.

   Takes a table as an argument and looks for all keys beginning with test_.
   Each entry is pcall'd and should return true if passes. Error messages
   are sent to STDOUT.

   Suite should be loaded with require

   Returns a table containing the total number of tests and the number of
   passing tests.
]]
function m.execute_suite( suite_name, suite_fns )

   local total = 0
   local pass = 0

   print( string.rep( '*', 60 ) )
   print( "Executing suite '"..suite_name.."':" )
   for name,fn in pairs( suite_fns ) do
      if( name:lower():sub(1,5) == "test_" ) then

	 total = total + 1
	 io.write( '  '..name.." ... " )
	 local ok, msg = pcall( fn )

	 if( ok ) then
	    print( "Passed" )
	    pass = pass + 1
	 else
	    print( "FAILED:" )
	    print( msg )
	    print( "" )
	 end
      end
   end
   print( "" )
   print( "Results for suite '"..suite_name.."': "..tostring(pass)..
	     " of "..tostring(total).." pass" )
   print( string.rep( '*', 60 ) )
   print( "" )

   return { total = total, pass = pass }
end

return m
