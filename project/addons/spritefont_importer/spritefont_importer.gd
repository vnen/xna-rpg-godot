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

# List of characters of the font
var char_list = [" ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/",
                 "0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?",
                 "@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O",
                 "P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_",
                 "`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o",
                 "p","q","r","s","t","u","v","w","x","y","z","{","|","}","~"]

var dialog = null

func get_name():
	return "gm.xna.spritefont_importer"

func get_visible_name():
	return "SpriteFont"

func import_dialog(from):
	var md = null
	if from != "":
		md = ResourceLoader.load_import_metadata(from)
	dialog.config(self, from, md)
	dialog.popup_centered()

func import(target, metadata):
	assert(metadata.get_source_count() == 1)

	var source = metadata.get_source_path(0)

	return convert_font(source, target, metadata)

func convert_font(source, target, metadata):
	var image = Image(0,0,false,Image.FORMAT_RGBA)
	var err = image.load(source)
	if err != OK:
		return ERR_FILE_CANT_OPEN

	var in_use = ResourceLoader.has(target)

	var font
	if in_use:
		font = ResourceLoader.load(target, "BitmapFont")
	else:
		font = BitmapFont.new()

	make_font(font, image)

	if in_use:
		# If the font is in use, make the users know it changed
		font.emit_signal("changed")

	var file = File.new()
	if font == null:
		err = ERR_CANT_CREATE
	else:
		metadata.set_editor("gm.xna.spritefont_importer")
		metadata.set_source_md5(0, file.get_md5(source))
		font.set_import_metadata(metadata)
		err = ResourceSaver.save(target, font)

	return err

func make_font(font, image):
	var texture = ImageTexture.new()

	# List of Rect2 for characters
	var rects = []

	# Test data
	var transparent = Color(0,0,0,0)
	var magenta = Color(1,0,1,1)
	var x = 0
	var y = 0
	var width = image.get_width()
	var height = image.get_height()
	var char_height = 1
	var found_rect_in_line = false


	# Loop into image
	while x < width and y < height:
		# Ignore magenta background
		if image.get_pixel(x, y) == magenta:
			x += 1
			if x == width:
				x = 0
				if found_rect_in_line:
					y += char_height
					found_rect_in_line = false
				else:
					y += 1
		else:
			# Find rectangle
			var rect_width = 0
			var rect_height = 0
			var tx = x
			var ty = y
			# Search horizontally for the rectangle end
			while tx < width and image.get_pixel(tx, y) != magenta:
				tx += 1
			# Search vertically for the rectangle end
			while ty < height and image.get_pixel(x, ty) != magenta:
				ty += 1
			# Calculate rectangle size
			rect_width = tx - x
			rect_height = ty - y
			char_height = rect_height

			rects.push_back(Rect2(x, y, rect_width, rect_height))
			x = tx # Skip rectangle
			found_rect_in_line = true

	# Remove magenta
	for y in range(height):
		for x in range(width):
			if image.get_pixel(x, y) == magenta:
				image.put_pixel(x, y, transparent)

	# Create texture from image
	texture.create_from_image(image)
	texture.set_flags(0)

	# Make font
	font.clear()
	while font.get_texture_count() > 0:
		font.remove_texture(0)
	font.add_texture(texture)
	font.set_height(char_height)
	font.set_ascent(char_height * 3.0 / 4.0)
	for i in range(rects.size()):
		font.add_char(char_list[i].ord_at(0), 0, rects[i])

	return font

func config(base_control):
	dialog = preload("spritefont_dialog.tscn").instance()
	base_control.add_child(dialog)
