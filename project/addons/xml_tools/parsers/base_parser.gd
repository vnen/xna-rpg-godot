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

################################################################################

# This is the base parser. It contains the read* functions to help the
# specific parsers that inherits from this.

tool
extends "xml_parser.gd"

var asset_name = null

# Read the reader of the XNA XML asset file and store the asset name.
# Return an error code.
func read_header(type):
	var err = next_element("XnaContent")
	if err != OK:
		return err

	var err = next_element("Asset")
	if err != OK:
		return err

	if get_named_attribute_value_safe("Type") != ("RolePlayingGameData." + type):
		return ERR_INVALID_DATA

	err = get_element_content("Name")
	if typeof(err) == TYPE_STRING:
		asset_name = err
		return OK
	else:
		return err

# Read a Vector2 from the file and store it in data using element as key name.
func read_vector2(element, data):
	var vec2 = parse_vector2(element)
	if typeof(vec2) == TYPE_INT:
		# Errored
		return vec2
	var err = read()
	if err != OK:
		return err
	err = expect_end(element)
	if err != OK:
		return err

	# If it got here then there's no error
	data[element] = vec2
	return OK

# Read a String from the file and store it in data using element as key name.
func read_string(element, data):
	var content = get_element_content(element)
	if typeof(content) == TYPE_INT:
		# It's an error code
		return content
	var err = read()
	if err != OK:
		return err
	err = expect_end(element)
	if err != OK:
		return err

	# If it got here then there's no error
	data[element] = content
	return OK

# Read an integer from the file and store it in data using element as key name.
func read_int(element, data):
	var content = get_element_content(element)
	if typeof(content) == TYPE_INT:
		# It's an error code
		return content
	var err = read()
	if err != OK:
		return err
	err = expect_end(element)
	if err != OK:
		return err

	if not content.is_valid_integer():
		return ERR_INVALID_DATA

	# If it got here then there's no error
	data[element] = int(content)
	return OK

# Read a range as a two-element array
func read_range(element, data):
	var err = next_element(element)
	if err != OK:
		return err

	var range_data = {}

	err = read_int("Minimum", range_data)
	if err != OK:
		return err

	err = read_int("Maximum", range_data)
	if err != OK:
		return err

	# Read the maximum end tag
	err = read()
	if err != OK:
		return err

	# If it got here then there's no error
	data[element] = [int(range_data["Minimum"]),int(range_data["Maximum"])]
	return OK

# Read an IntArray from the file and store it in data using element as key name.
func read_int_array(element, data):
	var int_arr = parse_int_array(element)
	if typeof(int_arr) == TYPE_INT:
		# Errored
		return int_arr
	var err = read()
	if err != OK:
		return err
	err = expect_end(element)
	if err != OK:
		return err

	# If it got here then there's no error
	data[element] = int_arr
	return OK

# Read an array of objects using a custom item parsing function.
func read_object_array(element, data, item_parser):
	var obj_arr = parse_obj_array(element, item_parser)
	if typeof(obj_arr) == TYPE_INT:
		# Errored
		return obj_arr

	# If it got here then there's no error
	data[element] = obj_arr
	return OK
