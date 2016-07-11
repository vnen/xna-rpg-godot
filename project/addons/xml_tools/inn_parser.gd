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
extends "res://addons/xml_tools/base_parser.gd"

func parse(file, parent, metadata):

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

	return make_inn(parent, inn_data, metadata)

# Build the inn scene based on the parsed data.
func make_inn(parent, inn_data, metadata):
	# Load the shop keeper texture resource
	var tileset = ResourceLoader.load( \
		metadata.get_option("textures_dir").plus_file(inn_data["ShopkeeperTextureName"] + ".png"), "Texture" \
	)
	if tileset == null:
		return ERR_CANT_AQUIRE_RESOURCE

	# Load the inn script
	var script = ResourceLoader.load(metadata.get_option("script_path"), "Script")
	if script == null:
		return ERR_CANT_AQUIRE_RESOURCE

	parent.set_name(asset_name)
	parent.set_script(script)

	# Set the name in the script
	parent.name = asset_name

	return OK
