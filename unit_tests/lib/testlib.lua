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

local default_exec_path = '..'..fs_delim

--[[
   Displays the specified message
]]
function m.write( msg )
   io.write( msg )
end

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

   m.write( string.rep( '*', 60 )..'\n' )
   m.write( "Executing suite '"..suite_name.."':\n" )
   for name,fn in pairs( suite_fns ) do
      if( name:lower():sub(1,5) == "test_" ) then

	 local ok, msg
	 
	 -- Run setup function, if it exists
	 if( suite_fns.setup ) then
	    ok, msg = pcall( suite_fns.setup )
	    if( ok ~= nil ) then
	       m.write( "Setup failed:\n" )
	       m.write( msg )
	    end
	 end

	 -- Attempt test
	 total = total + 1
	 m.write( '  '..name.." ... " )
	 ok, msg = pcall( fn )

	 if( ok ) then
	    m.write( "Passed\n" )
	    pass = pass + 1
	 else
	    m.write( "FAILED:\n" )
	    m.write( msg )
	    m.write( "\n\n" )
	 end

	 -- Run test-specific cleanup function, if it exists. If not, try
	 -- the general cleanup.
	 local cleanfn = suite_fns[ 'cleanup'..name:sub(5) ] or
	    suite_fns.cleanup

	 if( cleanfn ) then
	    ok, msg = pcall( cleanfn )
	    if( ok ~= nil ) then
	       m.write( "Cleanup failed:\n" )
	       m.write( msg )
	    end
	 end
      end
   end
   m.write( "\n" )
   m.write( "Results for suite '"..suite_name.."': "..tostring(pass)..
	     " of "..tostring(total).." pass\n" )
   m.write( string.rep( '*', 60 ) )
   m.write( "\n\n" )

   return { total = total, pass = pass }
end

--[[
   Sets the default execution path.

   This path is prepended to the command specified to get_cmd_output.
]]
function m.set_default_exec_path( path )
   default_exec_path = path
end

--[[
   Executes the specified command with the specified arguments.

   args is a list of arguments which will be joined with ' '.

   Command return code and a list of each line written to STDOUT is returned.

   An error is raised if unable to execute command with popen.
]]
function m.get_cmd_output( cmd, args )
   local lclcmd = default_exec_path..cmd..' '..table.concat(args, ' ')
   local fin = assert( io.popen( lclcmd, 'r' ),
		       "Unable to execute '"..lclcmd.."'" )
   local lines = {}
   for l in fin:lines() do
      lines[ #lines + 1 ] = l
   end

   local ok, msg, code = fin:close()
   return code, lines
end

return m
