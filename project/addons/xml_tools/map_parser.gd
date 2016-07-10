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
	err = read_header("Map")
	if err != OK:
		return err

	var map_data = {}

	# Read the map dimension
	err = read_vector2("MapDimensions", map_data)
	if err != OK:
		return err

	# Read the tile size
	err = read_vector2("TileSize", map_data)
	if err != OK:
		return err

	# Read the spawn position
	err = read_vector2("SpawnMapPosition", map_data)
	if err != OK:
		return err

	# Read the tileset name
	err = read_string("TextureName", map_data)
	if err != OK:
		return err

	# Read the battle background texture
	err = read_string("CombatTextureName", map_data)
	if err != OK:
		return err

	# Read the music theme name
	err = read_string("MusicCueName", map_data)
	if err != OK:
		return err

	# Read the battle theme name
	err = read_string("CombatMusicCueName", map_data)
	if err != OK:
		return err

	# Read the tilemap base layer
	err = read_int_array("BaseLayer", map_data)
	if err != OK:
		return err

	# Read the tilemap fringe layer
	err = read_int_array("FringeLayer", map_data)
	if err != OK:
		return err

	# Read the tilemap object layer
	err = read_int_array("ObjectLayer", map_data)
	if err != OK:
		return err

	# Read the tilemap colision layer
	err = read_int_array("CollisionLayer", map_data)
	if err != OK:
		return err

	return make_map(parent, map_data, metadata)

# Build the map resource based on the parsed data.
func make_map(parent, map_data, metadata):
	# Load the tileset resource
	var tileset = load(metadata.get_option("tileset_dir").plus_file(map_data["TextureName"] + ".res"))
	if tileset == null:
		return ERR_CANT_AQUIRE_RESOURCE

	# Set the map name
	parent.set_name(asset_name)

	# Create the tilemaps root
	var tilemaps = Node2D.new()
	tilemaps.set_name("TileMaps")
	parent.add_child(tilemaps)
	tilemaps.set_owner(parent)

	# Create base layer
	var base_layer = TileMap.new()
	base_layer.set_name("BaseLayer")
	base_layer.set_cell_size(map_data["TileSize"])
	base_layer.set_tileset(tileset)
	fill_tilemap(base_layer, map_data["BaseLayer"], map_data["MapDimensions"])
	tilemaps.add_child(base_layer)
	base_layer.set_owner(parent)

	# Create fringe layer
	var fringe_layer = TileMap.new()
	fringe_layer.set_name("FringeLayer")
	fringe_layer.set_cell_size(map_data["TileSize"])
	fringe_layer.set_tileset(tileset)
	fill_tilemap(fringe_layer, map_data["FringeLayer"], map_data["MapDimensions"])
	tilemaps.add_child(fringe_layer)
	fringe_layer.set_owner(parent)

	# Create object layer
	var object_layer = TileMap.new()
	object_layer.set_name("ObjectLayer")
	object_layer.set_cell_size(map_data["TileSize"])
	object_layer.set_tileset(tileset)
	fill_tilemap(object_layer, map_data["ObjectLayer"], map_data["MapDimensions"])
	tilemaps.add_child(object_layer)
	object_layer.set_owner(parent)

	# Create collision layer tileset dummy texture
	var collision_image = Image(map_data["TileSize"].x * 2, map_data["TileSize"].y, false, Image.FORMAT_RGBA)
	for y in range(map_data["TileSize"].y):
		for x in range(map_data["TileSize"].x):
			collision_image.put_pixel(x, y, Color(0,0,0,0))
			collision_image.put_pixel(map_data["TileSize"].x + x, y, Color(1,0,0,1))
			pass
	var collision_texture = ImageTexture.new()
	collision_texture.create_from_image(collision_image, 0)

	# Create collision layer tileset
	var collision_tileset = TileSet.new()
	collision_tileset.create_tile(0)
	collision_tileset.tile_set_name(0, "Passable")
	collision_tileset.tile_set_texture(0, collision_texture)
	collision_tileset.tile_set_region(0, Rect2(0, 0, map_data["TileSize"].x, map_data["TileSize"].y))
	collision_tileset.create_tile(1)
	collision_tileset.tile_set_name(1, "Impassable")
	collision_tileset.tile_set_texture(1, collision_texture)
	collision_tileset.tile_set_region(1, Rect2(map_data["TileSize"].x, 0, map_data["TileSize"].x, map_data["TileSize"].y))
	var col_shape = RectangleShape2D.new()
	col_shape.set_extents(map_data["TileSize"] / 2)
	collision_tileset.tile_set_shape(1, col_shape)
	collision_tileset.tile_set_shape_offset(1, map_data["TileSize"] / 2)

	# Create collision layer
	var collision_layer = TileMap.new()
	collision_layer.set_name("CollisionLayer")
	collision_layer.set_cell_size(map_data["TileSize"])
	collision_layer.set_tileset(collision_tileset)
	fill_tilemap(collision_layer, map_data["CollisionLayer"], map_data["MapDimensions"])
	tilemaps.add_child(collision_layer)
	collision_layer.set_owner(parent)
	collision_layer.set_hidden(true)

	# Create spawn point
	var spawn = Position2D.new()
	spawn.set_name("SpawnPosition")
	spawn.set_pos((map_data["SpawnMapPosition"] * map_data["TileSize"]) + (map_data["TileSize"] / 2))
	parent.add_child(spawn)
	spawn.set_owner(parent)

	return OK

# Helper function to fill a tilemap based on an IntArray.
func fill_tilemap(tilemap, data, dimensions):
	for i in range(data.size()):
		var cell = data[i]
		var x = int(fmod(i, dimensions.x))
		var y = int(i / dimensions.x)
		tilemap.set_cell(x, y, cell)
