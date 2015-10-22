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
-- Searches current directory for all test suites, executing each in turn. 
-------------------------------------------------------------------------------

local lfs = require "lfs";

local pass = 0
local total = 0
local num_suites = 0
for fn in lfs.dir('.') do
   if fn:match('^suite_.*%.lua$') then
      num_suites = num_suites + 1
      local suite = loadfile(fn)
      local results = suite()
      pass = pass + results.pass
      total = total + results.total
   end
end

-- Print a summary of results
print( '<'..string.rep('-', 58)..'>' )
print( tostring(pass)..' of '..tostring(total)..' test(s) pass in '..
	  tostring(num_suites)..' suite(s)' )
print( "" )

-- Return the total number of failed tests
os.exit(total - pass)
