# The MIT License (MIT)
#
# Copyright (c) 2016 George Marques
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

tool
extends "base_parser.gd"

func parse(file):

	var err = open(file)
	if err != OK:
		return err

	# Read the header of the file to make sure it's a Map
	err = read_header("Inn")
	if err != OK:
		return err

	var inn_data = {}

	err = read_int("ChargePerPlayer", inn_data)
	if err != OK:
		return err

	err = read_string("WelcomeMessage", inn_data)
	if err != OK:
		return err

	err = read_string("PaidMessage", inn_data)
	if err != OK:
		return err

	err = read_string("NotEnoughGoldMessage", inn_data)
	if err != OK:
		return err

	err = read_string("ShopkeeperTextureName", inn_data)
	if err != OK:
		return err

	# Finished :)

	return inn_data
