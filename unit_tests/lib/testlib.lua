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
   if( msg ) then
      io.write( msg )
   end
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

   args is a list of arguments which will be joined with spaces.

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

--[[ 
   Crawls the specified directory tree, removing each item in turn.
]]
function m.del_tree( path )
   -- TODO
   print("del_tree not implemented!")
end

--[[
   Builds a table that represents the contents of the specified directory tree.
]]
function m.read_tree( filepath )
   -- entry = { mode = mode, nlink = num, symbolic_link = t/f
   --           contents = [string if file, table if dir] }
   local retval = {}
   -- <pos> = { record = ref, path = full path }
   local queue = { { record = retval, path = filepath } }
   local i = 1
   local next_free = 2

   while queue[ i ] do
      pathname = queue[ i ].path
      parent_record = queue[ i ].record
      for entry in lfs.dir( pathname ) do
	 if( entry ~= '.' and entry ~= '..' ) then
	    local entry_path = pathname..fs_delim..entry
	    local record = {}
	    local attrs = lfs.attributes( entry_path )
	    record.symbolic_link =
	       ( lfs.symlinkattributes( entry_path, 'mode' ) == "link" )
	    record.nlink = attrs.nlink
	    record.mode = attrs.mode

	    if( record.symbolic_link ) then
	       -- Set contents to the link location. Requires that readlink
	       -- be installed. This is Posix only, but so are symbolic links..
	       fin = io.popen( 'readlink '..entry_path )
	       if( fin ) then
		  record.contents = fin:read()
		  fin:close()
	       end
	    else
	       if( record.mode == "file" ) then
		  -- Read entire file and stuff into contents
		  fin = io.open( entry_path, 'rb' )
		  if( fin ) then
		     record.contents = fin:read('a')
		     fin:close()
		  end
	       else
		  record.contents = {}
		  
		  -- Append to queue
		  queue[ next_free ] = { record = record.contents,
					 path = entry_path }
		  next_free = next_free + 1
	       end
	    end
	    
	    -- Add record to parent
	    parent_record[ entry ] = record
	    
	 end
      end
      
      -- Remove entry
      queue[ i ] = nil
      
      -- Move on to next entry
      i = i + 1
   end

   return retval
end

--[[
   Takes a set of nested tables that contain directory information and 
   recreates the indicated structure within the specified root.

   Removes the specified root, first.
]]
function m.make_tree( tree, root )
   -- Remove root, if it exists
   m.del_tree( root )

   -- <pos> = { record = ref, path = full path }
   local queue = { { record = tree, path = root } }
   local i = 1
   local next_free = 2

   while queue[ i ] do
      pathname = queue[ i ].path

      -- Make the specified path
      lfs.mkdir( pathname )
      
      for entry, record in pairs( queue[ i ].record ) do
	 local entry_path = pathname..fs_delim..entry
	 if( record.symbolic_link ) then
	    -- Make the symbolic link
	    local tmp_dir = lfs.currentdir()
	    lfs.chdir(pathname)
	    lfs.link( record.contents, entry, true )
	    lfs.chdir(tmp_dir)
	 elseif( record.mode == "file" ) then
	    -- Create file
	    fout = assert(io.open( entry_path, "wb" ),
			  "Unable to open file '"..entry_path.."' for writing!")
	    fout:write( record.contents )
	    fout:close()
	 elseif( record.mode == "directory" ) then
	    -- Append to queue
	    queue[ next_free ] = { record = record.contents,
				   path = entry_path }
	    next_free = next_free + 1
	 elseif( record.mode == "link" ) then
	    -- Indicates hard link
	    local tmp_dir = lfs.currentdir()
	    lfs.chdir(pathname)
	    lfs.link( record.contents, entry, false )
	    lfs.chdir(tmp_dir)
	 else
	    error("Unsupported mode: "..record.mode)
	 end
      end
      -- Remove entry
      queue[ i ] = nil
      
      -- Move on to next entry
      i = i + 1
   end

   return retval
end

--[[ 
   Displays the contents of the specified table representing a directory 
   tree.

   Intended for debug purposes.
]]
function m.dump_tree( tree, path )
   for k,v in pairs(tree) do
      local entry_path
      if( path ) then
	 entry_path = path..fs_delim..k
      else
	 entry_path = k
      end
      m.write("'"..entry_path.."' -> ")
      m.write("mode = "..v.mode..", nlink = "..tostring(v.nlink)..
		 ", symlink? "..tostring(v.symbolic_link))
      if( v.mode == "file" or v.symbolic_link ) then
	 m.write(", contents: "..v.contents.."\n")
      else
	 m.write("\n")
	 m.dump_tree( v.contents, entry_path )
      end
   end
end

--[[
   Compares what the program returned via STDOUT to the specified expected 
   value.
]]
function m.compare_stdout( expected, actual )
   local retval = true

   local min_lines = math.min( #expected, #actual )

   local showed_msg = false
   for i in 1, min_lines do
      if( expected[i] ~= actual[i] ) then
	 if( not showed_msg ) then
	    m.write( "Output did not match expected:\n" )
	    showed_msg = true
	 end
	 m.write( "Expected '" .. expected[i] .. "', got: '" .. actual[i] .. "'" )
	 retval = false
      end
   end

   if( #expected ~= #actual ) then
      if( #expected < #actual ) then
	 m.write( "Unexpected output:\n" )
	 for i in #expected + 1, #actual do
	    m.write( actual[ i ] )
	 end
      else
	 m.write( "Missing expected output:\n" )
	 for i in #actual + 1, #expected do
	    m.write( expected[ i ] )
	 end
      end
      retval = false
   end
   
   return retval
end

return m
