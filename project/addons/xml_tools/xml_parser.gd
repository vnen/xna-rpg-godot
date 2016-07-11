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

tool
extends XMLParser

# Move the cursor to the next element node. It can also expect a certain
# element name.
func next_element(element = null, do_read = true):
	var err = _next(NODE_ELEMENT, do_read)
	if err != OK or element == null:
		return err
	if element != get_node_name():
		return ERR_INVALID_DATA
	return OK

# Move the cursor to the next ending element. It can also expect a certain
# element name.
func next_element_end(element = null):
	var err = _next(NODE_ELEMENT_END)
	if err != OK or element == null:
		return err
	if element != get_node_name():
		return ERR_INVALID_DATA
	return OK

# Move the cursor to the next text node.
func next_text():
	return _next(NODE_TEXT)

# Move the cursor to the next ending node.
func next_end(element = null):
	var err = _next(NODE_ELEMENT_END)
	if err != OK or element == null:
		return err
	if element != get_node_name():
		return ERR_INVALID_DATA

# Check if the cursor is in an element node. Can check if it's a certain element.
func is_element(element = null):
	if get_node_type() != NODE_ELEMENT:
		return false
	if element == null or get_node_name() == element:
		return true
	return false

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
	var err = next_element(element)
	if err != OK:
		return err

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
	if typeof(content) == TYPE_INT:
		# Errored
		return content
	var values = content.strip_edges().split_floats(" ", false)
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
# The item parser must be a FuncRef referencing a function that receives a
# this XMLParser and returns the generated object.
func parse_obj_array(element, item_parser):
	if typeof(item_parser) != TYPE_OBJECT or not item_parser extends FuncRef:
		return ERR_INVALID_PARAMETER

	var err = next_element(element)
	if err != OK:
		return err

	if is_empty():
		# The element is empty, move on
		return []

	var arr = []

	err = next_element("Item")
	if err != OK:
		return err

	while true:
		var ret = item_parser.call_func(self)
		if typeof(ret) == TYPE_INT:
			# If it returns an int then it should be an error
			return ret

		arr.push_back(ret)

		# Go to next item ending
		err = next_element_end("Item")
		if err != OK:
			return err

		# Skip the element ending
		err = read()
		if err != OK:
			return err

		_skip(true)
		if expect_end(element) == OK:
			# Reached the end of the array
			break

		# Check if it's an item
		var is_item = is_element("Item")
		if not is_item:
			return ERR_INVALID_DATA

	# Skip the ending element
	err = read()
	if err != OK:
		return err

	return arr

################################################################################
# Inner functions                                                              #
################################################################################

# Inner helper function to move to a next type of node.
func _next(node_type, do_read = true):
	var err = OK
	if do_read:
		err = read()
	while get_node_type() != node_type:
		err = read()

		if err != OK:
			return err
	return err

# Skip blank space
func _skip(text=true):
	var err = OK
	var blanks = [NODE_UNKNOWN,NODE_CDATA,NODE_COMMENT]
	if text:
		blanks.push_back(NODE_TEXT)
	while err == OK and get_node_type() in blanks:
		err = read()
	return err
