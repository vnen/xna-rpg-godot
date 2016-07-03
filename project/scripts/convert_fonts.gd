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

# SpriteFont converter. This takes SpriteFont images and make them Godot's
# font resources.
# Usage (from the project folder): godot -s scripts/convert_fonts.gd
# Make sure to run make_pngs.sh first

extends SceneTree

# List of characters of the font
var char_list = [" ","!","\"","#","$","%","&","'","(",")","*","+",",","-",".","/",
                 "0","1","2","3","4","5","6","7","8","9",":",";","<","=",">","?",
                 "@","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O",
                 "P","Q","R","S","T","U","V","W","X","Y","Z","[","\\","]","^","_",
                 "`","a","b","c","d","e","f","g","h","i","j","k","l","m","n","o",
                 "p","q","r","s","t","u","v","w","x","y","z","{","|","}","~"]

func _init():
	var dir_list = Directory.new()

	var error = dir_list.open("fonts")

	if error != OK:
		print("Can't open fonts directory!")
		quit()
		return

	print("Converting fonts...")

	dir_list.list_dir_begin()

	var file = dir_list.get_next()
	while file != "":
		if file.extension() == "png":
			convert_font("fonts".plus_file(file))
		file = dir_list.get_next()

	print("Done!")

	quit()

func convert_font(source):
	var target = "fonts".plus_file(source.get_file().basename() + ".fnt")
	print("Loading image %s..." % source)
	var image = Image(0,0,false,Image.FORMAT_RGBA)
	image.load(source)

	print("Making font...")
	var font = make_font(image)

	print("Saving font %s..." % target)
	if font != null:
		ResourceSaver.save(target, font)

	print("Font %s saved!" % target)

func make_font(image):
	var texture = ImageTexture.new()
	var font = BitmapFont.new()

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
	font.add_texture(texture)

	for i in range(rects.size()):
		font.add_char(char_list[i].ord_at(0), 0, rects[i])

	font.set_height(char_height)
	font.set_ascent(char_height * 3.0 / 4.0)

	return font
