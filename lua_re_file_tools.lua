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
run_modes_mt = {}
run_modes_mt.__index = function(table,key)
   return {command="default"}
end
setmetatable(run_modes, run_modes_mt)

-- Define helper functions
local function link_item(src, dest, args)
   if( args.s and args.a ) then
      src = lfs.currentdir().."/"..src
   end
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

local function move_item(src, dest, args)
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

local function exec_item(src, dest, args)
   local out
   if( args.v ) then
      out = io.output();
      out:write("'"..dest.."'");
      out:close();
   end
   if( args.dry_run ) then
      print("");
      return;
   end

   bOk, result, code = os.execute( dest );
   if( bOk == nil ) then
      print("Error: unable to execute '"..dest.."'!")
      return;
   end
   if( args.v ) then
      print(" => "..result.." ("..code..")");
   end
end

-- Create a table to mode-specific settings.
-- Override __index to create a default mode.
local single_command = function ( parser ) return parser; end;
local fn_modes = {}
fn_modes.copy = {
   desc = "Copy with Lua pattern matching",
   parsers = { copy = single_command },
   file_action=copy_file,
};
fn_modes.move = {
   desc = "Move with Lua pattern matching",
   parsers = { move = single_command },
   file_action=move_item,
};
fn_modes.link = {
   desc = "Create links with Lua pattern matching",
   parsers = { link = single_command },
   file_action=link_item,
};
fn_modes.exec = {
   desc = "Find and Execute with Lua pattern matching",
   parsers = { exec = single_command },
   file_action=exec_item,
};
-- Default case. Create a new parser for each mode.
fn_modes_mt = {}
fn_modes_mt.__index = function(table,key)
   local ret_val_mt = {}
   ret_val_mt.__index = function(table, key)
      return function ( parser )
	 return parser:command(key, fn_modes[key]["description"])
      end
   end
   local ret_val = {}
   setmetatable(ret_val, ret_val_mt)

   return {
      desc = "Tool to move/copy/link files with Lua pattern matching",
      parsers = ret_val,
   }
end
setmetatable(fn_modes, fn_modes_mt)

local cur_mode = fn_modes[run_modes[run_as]["command"]]

-- Define command-line argument parser
local parser = argparse()
   :name(run_as)
   :description(cur_mode["desc"])
   :add_help "-h"
   :epilog(run_as..copyright)

-- Global parser Options
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

-- Define sub-command options
local sub_parser;
   
-- Define copy-specific options
sub_parser = cur_mode.parsers["copy"];
if sub_parser then
   sub_parser = sub_parser( parser )

   sub_parser:argument("SRC")
      :description("Expression used to match source files")
      :args(1)

   sub_parser:argument("DEST")
      :description("Expression used generate destination file names")
      :args(1)
end

-- Define move-specific options
sub_parser = cur_mode.parsers["move"];
if sub_parser then
   sub_parser = sub_parser( parser )

   sub_parser:argument("SRC")
      :description("Expression used to match source files")
      :args(1)

   sub_parser:argument("DEST")
      :description("Expression used generate destination file names")
      :args(1)
end

-- Define link-specific options
sub_parser = cur_mode.parsers["link"];
if sub_parser then
   sub_parser = sub_parser( parser )

   sub_parser:argument("SRC")
      :description("Expression used to match source files")
      :args(1)

   sub_parser:argument("DEST")
      :description("Expression used generate destination file names")
      :args(1)

   sub_parser:flag("-s")
      :description("Create symbolic link (defaults to hard link)")

   sub_parser:flag("-a")
      :description("Use absolute path when making symbolic link.")
end

-- Define exec-specific options
sub_parser = cur_mode.parsers["exec"];
if sub_parser then
   sub_parser = sub_parser( parser )

   sub_parser:argument("SRC")
      :description("Expression used to match source files")
      :args(1)

   sub_parser:argument("DEST")
      :description("Expression used generate destination file names")
      :args(1)
end

-- parser:argument("DIR")
--    :description("Optional starting directory to look for source files.")
--    :args("?")
--    :default "."

local args = parser:parse(arg);

local function handle_dir(dir_names)
   local idx = 1;
   while( idx <= #dir_names ) do
      local dir_name = dir_names[idx];
      for dir_obj in lfs.dir(dir_name) do
	 pathname = dir_obj
	 if( dir_name ~= '.' ) then
	    pathname = dir_name.."/"..pathname;
	 end

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
