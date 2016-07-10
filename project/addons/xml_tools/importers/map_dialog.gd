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
extends ConfirmationDialog

var src_file_browse
var dst_file_browse
var tileset_folder_browse
var map_importer

func config(importer, path, metadata):
	map_importer = importer
	if metadata:
		assert(metadata.get_source_count() > 0)
		var src_path = map_importer.expand_source_path(metadata.get_source_path(0))
		get_node("container/src_file").set_text(src_path)
		get_node("container/dst_file").set_text(path)
		var tilesets = metadata.get_option("tileset_dir")
		if tilesets:
			get_node("container/tilesets_folder").set_text(tilesets)

func _ready():

	src_file_browse = FileDialog.new()
	src_file_browse.set_mode(FileDialog.MODE_OPEN_FILE)
	src_file_browse.set_access(FileDialog.ACCESS_FILESYSTEM)
	src_file_browse.add_filter("*.xml")
	src_file_browse.connect("file_selected", self, "_on_src_selected")

	add_child(src_file_browse)

	dst_file_browse = EditorFileDialog.new()
	dst_file_browse.set_mode(EditorFileDialog.MODE_SAVE_FILE)
	dst_file_browse.add_filter("*.tscn")
	dst_file_browse.connect("file_selected", self, "_on_dst_selected")

	add_child(dst_file_browse)

	tileset_folder_browse = EditorFileDialog.new()
	tileset_folder_browse.set_mode(EditorFileDialog.MODE_OPEN_DIR)
	tileset_folder_browse.set_current_dir(get_node("container/tilesets_folder").get_text())
	tileset_folder_browse.connect("dir_selected", self, "_on_tileset_selected")

	add_child(tileset_folder_browse)

	set_hide_on_ok(true)
	get_ok().set_text("Import")

func _on_src_browse_pressed():
	src_file_browse.popup_centered_ratio()

func _on_dst_browse_pressed():
	dst_file_browse.popup_centered_ratio()

func _on_tilesets_browse_pressed():
	tileset_folder_browse.popup_centered_ratio()

func _on_src_selected(path):
	get_node("container/src_file").set_text(path)

func _on_dst_selected(path):
	get_node("container/dst_file").set_text(path)

func _on_tileset_selected(path):
	get_node("container/tilesets_folder").set_text(path)

func _on_MapImportDialog_confirmed():
	var md = ResourceImportMetadata.new()
	md.add_source(map_importer.validate_source_path(get_node("container/src_file").get_text()))
	md.set_option("tileset_dir", get_node("container/tilesets_folder").get_text())
	var err = map_importer.import(get_node("container/dst_file").get_text(), md)

	if err != OK:
		var error_node = get_node("error")
		if err == ERR_FILE_CANT_OPEN:
			error_node.set_text("Can't open the source file!")
		elif err == ERR_CANT_CREATE:
			error_node.set_text("Can't create the font!")
		else:
			error_node.set_text("Error Importing!")
		get_node("error").popup_centered_minsize()
