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
-- Test suite template. Each suite file must begin with suite_ in order
-- for run_tests.lua to pick it up.
-------------------------------------------------------------------------------
local suite_name = "template"

-- Put filesystem delimiter into a global variable for later.
local fs_delim = package.config:sub(1,1)
local t = { '.', 'lib', '?.lua;' }
package.path = table.concat(t, fs_delim)..package.path

local lfs = require "lfs"
local test = require "lib/testlib"

local m = {}

-- Define test functions here. Each must be in m and begin with test_.
-- Each test should return true on pass or nil + error message on fail.
-- Ex:
function m.test_ex1()
   return true
end

return test.execute_suite( suite_name, m )
