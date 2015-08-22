#!/usr/bin/env lua

-- Copyright (C) 2015 Jeff Backus
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

local version = "0.1";
local copyright = " v" .. version .. " Copyright (C) 2015 Jeff Backus";

local lfs = require "lfs";
local argparse = require "argparse";

-- Figure out how we were invoked
local _, _, run_as = string.find(arg[0], "([^/]+)$");

-- Create a table to handle different options for how we are started
-- Override __index to create a default case.
local run_modes = {}
run_modes.recp = {command="copy"};
run_modes.remv = {command="move"};
run_modes.reln = {command="link"};
run_modes.reexec = {command="exec"};
-- run_modes_mt = {}
-- run_modes_mt.__index = function(table,key)
--    return {command="default"}
-- end
-- setmetatable(run_modes, run_modes_mt)

-- Define helper functions
local function link_file(src, dest, args)
   if( args.v ) then
      local cmd = "ln"
      if( args.s ) then
	 cmd = cmd.." -s"
      end
      print(cmd.." '"..src.."' '"..dest.."'")
   end
   if( args.dry_run ) then
      return
   end

   lfs.link( src, dest, args.s )
end

local function move_file(src, dest, args)
   if( args.v ) then
      print("mv '"..src.."' '"..dest.."'")
   end
   if( args.dry_run ) then
      return
   end
   os.rename( src, dest )
end

local function copy_file(src, dest, args)

   if( args.v ) then
      print("cp '"..src.."' '"..dest.."'")
   end
   if( args.dry_run ) then
      return
   end
   
   local BUFSIZE = 2^20 -- 1MB at a time
   local fin = assert(io.open(src, "rb"))
   local fout = assert(io.open(dest, "wb"))
   while true do
      local bytes = fin:read(block)
      if not bytes then break end
      fout:write(bytes)
   end
   fin:close()
   fout:close()
end

-- Create a table to mode-specific settings.
-- Override __index to create a default mode.
local mode = {}
mode.copy = {desc = "Copy with Lua pattern matching", copy = true, file_action=copy_file};
mode.move = {desc = "Move with Lua pattern matching", move = true, file_action=move_file};
mode.link = {desc = "Create links with Lua pattern matching", link = true, file_action=link_file};
mode.exec = {desc = "Find and Execute with Lua pattern matching", exec = true};
mode_mt = {}
mode_mt.__index = function(table,key)
   return { desc = "Tool to move/copy/link files with Lua pattern matching" }
end
setmetatable(mode, mode_mt)

local cur_mode = mode[run_modes[run_as]["command"]]

-- Define command-line argument parser
local parser = argparse()
   :name(run_as)
   :description(cur_mode["desc"])
   :add_help "-h"
   :epilog(run_as..copyright)

-- Parser Options
parser:flag("-r")
   :description("Recursively process directories")

parser:flag("-d")
   :description("Only manipulate directories")

parser:flag("-f")
   :description("Only manipulate files (still crawls directories if -r used)")

parser:flag("--dry-run")
   :description("Dry run (don't actually do anything). Implies -v.")

parser:flag("-v")
   :description("Displays actions as they happen.")

parser:flag("-l")
   :description("Interpret DEST as Lua code.")

if cur_mode.link then
   parser:flag("-s")
      :description("Create symbolic link (defaults to hard link)")
end

-- parser:argument("DIR")
--    :description("Optional starting directory to look for source files.")
--    :args("?")
--    :default "."

parser:argument("SRC")
   :description("Expression used to match source files")
   :args(1)

parser:argument("DEST")
   :description("Expression used generate destination file names")
   :args(1)

local args = parser:parse(arg);

local function handle_dir(dir_names)
   local idx = 1;
   while( idx <= #dir_names ) do
      local dir_name = dir_names[idx];
      for dir_obj in lfs.dir(dir_name) do
         pathname = dir_name.."/"..dir_obj;

	 newname = string.gsub(pathname, args.SRC, args.DEST)
--print ("'"..pathname.."' -> '"..newname.."'")	 
         attrs = lfs.attributes(pathname);
--print("'"..pathname.."' is a "..attrs.mode);

	 if( attrs.mode == "directory" and
	     dir_obj ~= '.' and dir_obj ~= '..' ) then
	    
	    -- Append to end of list if recursive mode enabled.
	    if( args.r ) then
	       dir_names[ #dir_names + 1 ] = pathname
	    end
	    if( args.f == nil ) then
	       -- todo
	       print("Handling directory '"..pathname.."'")
	    end
	 elseif( attrs.mode == "file" ) then
	    if( args.d == nil ) then
	       cur_mode.file_action( pathname, newname, args )
	    end
	 end
      end
      idx = idx + 1
   end
end

-- debug
print("[Begin Debug]")
for k,v in pairs(args) do print("\t"..k.." = '"..tostring(v).."'") end
print("[End Debug]")

-- If -l is specified, reinterpret DEST as Lua code.
if args.l then
   args.DEST = load(args.DEST)
end

-- If --dry-run is specified, force -v
if args.dry_run then
   args.v = true
end
   
handle_dir({'.'})
