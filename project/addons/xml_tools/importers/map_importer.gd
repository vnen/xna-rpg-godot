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

# SpriteFont importer. This takes SpriteFont images and make them Godot's
# font resources.

tool
extends EditorImportPlugin

var plugin_name = "gm.xna.map_importer"
var dialog = null
var map_parser = null

func get_name():
	return plugin_name

func get_visible_name():
	return "XNA Map"

func import_dialog(from):
	var md = null
	if from != "":
		md = ResourceLoader.load_import_metadata(from)
	dialog.config(self, from, md)
	dialog.popup_centered()

func import(target, metadata):
	assert(metadata.get_source_count() == 1)

	var source = metadata.get_source_path(0)

	var map
	if ResourceLoader.has(target):
		map = ResourceLoader.load(target).instance()
	else:
		pass
	map = Node2D.new()

	var err = map_parser.parse(source, map, metadata)


	if err != OK:
		return err

	var pack = PackedScene.new()

	pack.pack(map)

	metadata.set_editor(plugin_name)
	var f = File.new()
	metadata.set_source_md5(0, f.get_md5(source))
	pack.set_import_metadata(metadata)

	return ResourceSaver.save(target, pack)

func config(base_control):
	dialog = preload("map_dialog.tscn").instance()
	map_parser = load("res://addons/xml_tools/map_parser.gd")
	map_parser = map_parser.new()
	base_control.add_child(dialog)
