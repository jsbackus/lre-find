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

-- Create a table to mode-specific settings.
-- Override __index to create a default mode.
local mode = {}
mode.recp = {desc = "Copy with Lua pattern matching"};
mode.remv = {desc = "Move with Lua pattern matching"};
mode.reln = {desc = "Create links with Lua pattern matching"};
mode_mt = {}
mode_mt.__index = function(table,key)
   return { desc = "Tool to move/copy/link files with Lua pattern matching" }
end
setmetatable(mode, mode_mt)

-- Define command-line argument parser
local parser = argparse()
   :name(run_as)
   :description(mode[run_as]["desc"])
   :add_help "-h"
   :epilog(run_as..copyright)

-- Parser Options
parser:flag("-r")
   :description("Recursively process directories")

parser:flag("-d")
   :description("Dry run (don't actually do anything). Implies -v.")

parser:flag("-v")
   :description("Displays actions as they happen.")

if run_as == "reln" then
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

local function handle_dir(dir_name)
   for dir_obj in lfs.dir(dir_name) do
      pathname = dir_name.."/"..dir_obj;
      attrs = lfs.attributes(pathname);
      print("'"..pathname.."' is a "..attrs.mode)

      if (args.r and attrs.mode == "directory" and
	  dir_obj ~= '.' and dir_obj ~= '..' )then
	 
	 handle_dir(pathname)
      end
   end
end

-- debug
print("[Begin Debug]")
for k,v in pairs(args) do print("\t"..k.." = '"..tostring(v).."'") end
print("[End Debug]")

handle_dir('.')
