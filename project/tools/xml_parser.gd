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

# XMLParser tool. This is a helper to add functions to the built-in XMLParser
# class. It's meant to help building specific importers for the XNA content
# files, since they're similar to some extent.

extends XMLParser

# Move the cursor to the next element node. It can also expect a certain
# element name.
func next_element(element = null):
	var err = next(NODE_ELEMENT)
	if err != OK or element == null:
		return err
	if element != get_node_name():
		return ERR_INVALID_DATA

# Move the cursor to the next text node.
func next_text():
	return next(NODE_TEXT)

# Move the cursor to the next ending node.
func next_end(element = null):
	var err = next(NODE_ELEMENT_END)
	if err != OK or element == null:
		return err
	if element != get_node_name():
		return ERR_INVALID_DATA

# Expect the element to end now and have no further content.
# If the element argument is null, check for the end of any tag.
func expect_end(element = null):
	var err = _skip(false)
	if err == OK and get_node_type() != NODE_ELEMENT_END:
		return ERR_INVALID_DATA
	if element != null and get_node_name() != element:
		return ERR_INVALID_DATA
	return err

# Get the content of the next element, with optional tag name.
# If the element has sub-elements this will return an error code.
func get_element_content(element = null):
	var err = next_element()
	if err != OK:
		return err

	if element != null and get_node_name() != element:
		return ERR_INVALID_DATA

	err = read()
	if err != OK:
		return err

	if get_node_type() != NODE_TEXT:
		return ERR_INVALID_DATA

	var content = get_node_data()

	expect_end(element)

	return content

################################################################################
# Content Parsers                                                              #
################################################################################

# Parser a Vector2 from a text. Returns an error if the text is invalid.
func parse_vector2(element):
	var content = get_element_content(element)
	var values = content.stript_edges().split_floats(" ", false)
	if values.size() != 2:
		return ERR_INVALID_DATA
	return Vector2(values[0], values[1])

# Parse an array of ints from a text
func parse_int_array(element):
	var content = get_element_content(element)
	var values = content.strip_edges().replace("\n", " ").replace("\r", " ").split(" ", false)
	var arr = IntArray()
	for val in values:
		arr.push_back(int(val))
	return arr

# Parse an array of objects with a specific parser for each item.
# The item parser must have a parse_item(XMLParser) function, which
# must return an error code.
func parse_obj_array(element, item_parser):
	if not item_parser.has_method("parse_item"):
		return ERR_INVALID_PARAMETER

	var err = next_element(element)
	if err != OK:
		return err

	var arr = []

	err = next_element("Item")
	if err != OK:
		return err

	while true:
		var ret = item_parser.parse_item(self)
		if ret != OK:
			return ret
		arr.push_back(ret)

		_skip()
		err = expect_end("Item")
		if err != OK:
			return err

		err = _skip()
		if err != OK:
			return err

		if expect_end(element) == OK:
			# Reached the end of the array
			break

		# Read the next item
		err = next_element("Item")
		if err != OK:
			return err

	# Skip the ending element and following blank space
	read()
	return _skip()

################################################################################
# Inner functions                                                              #
################################################################################

# Inner helper function to move to a next type of node.
func _next(node_type):
	var err = read()
	while get_node_type() != node_type:
		err = read()

		if err != OK:
			return err
	return err

# Skip blank space
func _skip(text=true):
	var err = read()
	var blanks = [NODE_UNKNOWN,NODE_CDATA,NODE_COMMENT]
	if text:
		blanks.push_back(NODE_TEXT)
	while err == OK and get_node_type() in blanks:
		err = read()
	return err
