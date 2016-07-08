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
extends EditorImportPlugin

var plugin_name = "gm.xna.tileset_importer"
var dialog = null

func get_name():
	return plugin_name

func get_visible_name():
	return "TileSet from Texture"

func import_dialog(from):
	var md = null
	if from != "":
		md = ResourceLoader.load_import_metadata(from)
	dialog.config(self, from, md)
	dialog.popup_centered()

func import(target, metadata):
	assert(metadata.get_source_count() == 1)

	var source = metadata.get_source_path(0)

	# Load or create TileSet
	var tileset
	if ResourceLoader.has(target):
		tileset = ResourceLoader.load(target)
	else:
		tileset = TileSet.new()
	tileset.clear()

	var tile_width = int(metadata.get_option("tile_width"))
	var tile_heigth = int(metadata.get_option("tile_height"))

	if tile_width <= 0 or tile_heigth <= 0:
		return ERR_INVALID_PARAMETER

	var texture = load(source)

	if not texture:
		return ERR_CANT_AQUIRE_RESOURCE

	var image_width = texture.get_width()
	var image_height = texture.get_height()

	var cols = int(image_width / tile_width)
	var rows = int(image_height / tile_heigth)

	print("rows ", rows)
	print("cols ", cols)

	for col in range(cols):
		for row in range(rows):
			var id = row * cols + col
			tileset.create_tile(id)
			tileset.tile_set_texture(id, texture)
			tileset.tile_set_region(id, Rect2(col * tile_width, row * tile_heigth, tile_width, tile_heigth))
			print ("creating tile %d with Rect(%d,%d,%d,%d)" % [id,col * tile_width, row * tile_heigth, tile_width, tile_heigth])

	# Signal resource update
	tileset.emit_signal("changed")

	# Update import metadata
	metadata.set_editor(plugin_name)
	var f = File.new()
	metadata.set_source_md5(0, f.get_md5(source))
	tileset.set_import_metadata(metadata)

	# Save file
	return ResourceSaver.save(target, tileset)

func config(base_control):
	dialog = preload("tileset_dialog.tscn").instance()
	base_control.add_child(dialog)
