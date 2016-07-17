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
extends "base_parser.gd"

func parse(file):

	var err = open(file)
	if err != OK:
		return err

	# Read the header of the file to make sure it's a Map
	err = read_header("Map")
	if err != OK:
		return err

	var map_data = { "AssetName": asset_name }

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

	# Read the portals
	err = read_object_array("Portals", map_data, funcref(self, "parse_portal_item"))
	if err != OK:
		return err

	# Read the portal entries
	err = read_object_array("PortalEntries", map_data, funcref(self, "parse_entry_item"))
	if err != OK:
		return err

	# Read the chest entries
	err = read_object_array("ChestEntries", map_data, funcref(self, "parse_entry_item"))
	if err != OK:
		return err

	# Read the fixed combat entries
	err = read_object_array("FixedCombatEntries", map_data, funcref(self, "parse_entry_item_with_direction"))
	if err != OK:
		return err

	# Read the random combat data
	err = read_random_combat(map_data)
	if err != OK:
		return err

	# Read the quest NPCs
	err = read_object_array("QuestNpcEntries", map_data, funcref(self, "parse_entry_item_with_direction"))
	if err != OK:
		return err

	# Read the regular NPCs
	err = read_object_array("PlayerNpcEntries", map_data, funcref(self, "parse_entry_item_with_direction"))
	if err != OK:
		return err

	# Read the Inns
	err = read_object_array("InnEntries", map_data, funcref(self, "parse_entry_item"))
	if err != OK:
		return err

	# Read the Stores
	err = read_object_array("StoreEntries", map_data, funcref(self, "parse_entry_item"))
	if err != OK:
		return err

	# Finished :)

	return map_data

# Parse each portal item
func parse_portal_item(parser):
	var portal = {}

	# Read the name of the portal
	var err = read_string("Name", portal)
	if err != OK:
		return err

	# Read the landing pos of the portal
	err = read_vector2("LandingMapPosition", portal)
	if err != OK:
		return err

	# Read the destination map of the portal
	err = read_string("DestinationMapContentName", portal)
	if err != OK:
		return err

	# Read the destination portal of the portal
	err = read_string("DestinationMapPortalName", portal)
	if err != OK:
		return err

	# Read the end element
	err = read()
	if err != OK:
		return err

	return portal


# Parse each entry item. For portal and chest entries.
func parse_entry_item(parser):
	var entry = {}

	# Read the content name of the entry
	var err = read_string("ContentName", entry)
	if err != OK:
		return err

	# Read the map pos of the entry
	err = read_vector2("MapPosition", entry)
	if err != OK:
		return err

	return entry

# Parse each entry item with direction data. For NPCs.
func parse_entry_item_with_direction(parser):
	var entry = {}

	# Read the content name of the entry
	var err = read_string("ContentName", entry)
	if err != OK:
		return err

	# Read the map pos of the entry
	err = read_vector2("MapPosition", entry)
	if err != OK:
		return err

	# Read the direction of the entry
	var err = read_string("Direction", entry)
	if err != OK:
		return err

	return entry

# Read the random combat information.
func read_random_combat(map_data):
	var err = next_element("RandomCombat")
	if err != OK:
		return err

	var random_combat = {}

	err = read_int("CombatProbability", random_combat)
	if err != OK:
		return err

	err = read_int("FleeProbability", random_combat)
	if err != OK:
		return err

	err = read_range("MonsterCountRange", random_combat)
	if err != OK:
		return err

	err = read_object_array("Entries", random_combat, funcref(self, "parse_randomcombat_entry_item"))
	if err != OK:
		return err

	map_data["RandomCombat"] = random_combat
	return OK

# Parse each random combat monsetr entry item.
func parse_randomcombat_entry_item(parser):
	var entry = {}

	# Read the content name of the entry
	var err = read_string("ContentName", entry)
	if err != OK:
		return err

	# Read the count the entry
	err = read_int("Count", entry)
	if err != OK:
		return err

	# Read the weight of the entry
	var err = read_int("Weight", entry)
	if err != OK:
		return err

	return entry

# Build the map resource based on the parsed data.
func make_map(map_data, parent, metadata):
	# Source base
	var source_base = metadata.get_source_path(0).get_base_dir().get_base_dir()

	# Load the other parsers
	var inn_parser = preload("inn_parser.gd").new()
	var chest_parser = preload("chest_parser.gd").new()
	var store_parser = preload("store_parser.gd").new()
	var fixed_combat_parser = preload("fixed_combat_parser.gd").new()

	# Load the tileset resource
	var tileset = load(metadata.get_option("tileset_dir").plus_file(map_data["TextureName"] + ".res"))
	if tileset == null:
		return ERR_CANT_AQUIRE_RESOURCE

	# Load the block activator scene
	var block_activator = preload("res://maps/block_activator.tscn")

	# Load the scripts
	var inn_script = preload("res://maps/inn.gd")

	# Set the map name
	parent.set_name(asset_name)

	# Create base layer
	var base_layer = TileMap.new()
	base_layer.set_name("BaseLayer")
	base_layer.set_cell_size(map_data["TileSize"])
	base_layer.set_tileset(tileset)
	fill_tilemap(base_layer, map_data["BaseLayer"], map_data["MapDimensions"])
	parent.add_child(base_layer)
	base_layer.set_owner(parent)

	# Create fringe layer
	var fringe_layer = TileMap.new()
	fringe_layer.set_name("FringeLayer")
	fringe_layer.set_cell_size(map_data["TileSize"])
	fringe_layer.set_tileset(tileset)
	fill_tilemap(fringe_layer, map_data["FringeLayer"], map_data["MapDimensions"])
	parent.add_child(fringe_layer)
	fringe_layer.set_owner(parent)


	# Before the next layers, here comes the players, so they'll be drawn behind
	var players_layer = YSort.new()
	players_layer.set_name("PlayersLayer")
	parent.add_child(players_layer)
	players_layer.set_owner(parent)


	# Create object layer
	var object_layer = TileMap.new()
	object_layer.set_name("ObjectLayer")
	object_layer.set_cell_size(map_data["TileSize"])
	object_layer.set_tileset(tileset)
	fill_tilemap(object_layer, map_data["ObjectLayer"], map_data["MapDimensions"])
	parent.add_child(object_layer)
	object_layer.set_owner(parent)

	# Create collision layer tileset dummy texture
	var collision_image = Image(map_data["TileSize"].x * 2, map_data["TileSize"].y, false, Image.FORMAT_RGBA)
	for y in range(map_data["TileSize"].y):
		for x in range(map_data["TileSize"].x):
			collision_image.put_pixel(x, y, Color(0,0,0,0))
			collision_image.put_pixel(map_data["TileSize"].x + x, y, Color(1,0,0,0.3))
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
	collision_layer.set_collision_layer(2)
	parent.add_child(collision_layer)
	collision_layer.set_owner(parent)
	collision_layer.set_hidden(true)

	# Create spawn point
	var spawn = Position2D.new()
	spawn.set_name("SpawnPosition")
	spawn.set_pos(normalize_position(map_data["SpawnMapPosition"], map_data))
	parent.add_child(spawn)
	spawn.set_owner(parent)

	# Create the activators
	var activators = Node2D.new()
	activators.set_name("Activators")
	parent.add_child(activators)
	activators.set_owner(parent)

	# Create the activators for Inns
	var inns = Node2D.new()
	inns.set_name("Inns")
	activators.add_child(inns)
	inns.set_owner(parent)
	for inn in map_data.InnEntries:
		# Parse the Inn
		var inn_data = inn_parser.parse(source_base.plus_file("Maps/Inns").plus_file(inn.ContentName + ".xml"))
		if typeof(inn_data) == TYPE_INT:
			# Errored
			return inn_data

		# Load shopkeeper texture
		var shop_keeper_texture = \
			ResourceLoader.load("res://entities/characters/textures".plus_file(inn_data.ShopkeeperTextureName + ".png"))
		if shop_keeper_texture == null:
			return ERR_CANT_AQUIRE_RESOURCE

		# Add activator and set data
		var inn_activator = block_activator.instance()
		inn_activator.set_script(inn_script)
		inn_activator.set_name(inn.ContentName)
		inn_activator.set_pos(normalize_position(inn.MapPosition, map_data))
		inn_activator.name = inn_data.AssetName
		inn_activator.charge_per_player = inn_data.ChargePerPlayer
		inn_activator.welcome_message = inn_data.WelcomeMessage
		inn_activator.paid_message = inn_data.PaidMessage
		inn_activator.not_enough_gold = inn_data.NotEnoughGoldMessage
		inn_activator.shop_keeper_texture = shop_keeper_texture

		# Add the Inn activator to the scene
		inns.add_child(inn_activator)
		inn_activator.set_owner(parent)

	# Create stores [dummy]
	var stores = Node2D.new()
	stores.set_name("StoresDummy")
	activators.add_child(stores)
	stores.set_owner(parent)
	stores.set_hidden(true)
	stores.set("editor/display_folded", true)
	for store in map_data.StoreEntries:
		# Parse the Store
		var store_data = store_parser.parse(source_base.plus_file("Maps/Stores").plus_file(store.ContentName + ".xml"))
		if typeof(store_data) == TYPE_INT:
			# Errored
			return store_data

		var text = Label.new()
		text.set_name(store.ContentName)

		for item in store_data.StoreCategories:
			text.set_text(text.get_text() + "Name" + store_data.AssetName + "\n"  + str(item.AvailableContentNames) + "\n\n")

		stores.add_child(text)
		text.set_owner(parent)

	# Create fixed combats [dummy]
	var fixed_combats = Node2D.new()
	fixed_combats.set_name("FixedCombatsDummy")
	activators.add_child(fixed_combats)
	fixed_combats.set_owner(parent)
	fixed_combats.set_hidden(true)
	fixed_combats.set("editor/display_folded", true)
	for fixed_combat in map_data.FixedCombatEntries:
		# Parse the fixed_combat
		var fixed_combat_data = \
			fixed_combat_parser.parse(source_base.plus_file("Maps/FixedCombats").plus_file(fixed_combat.ContentName + ".xml"))
		if typeof(fixed_combat_data) == TYPE_INT:
			# Errored
			return fixed_combat_data

		var text = Label.new()
		text.set_name(fixed_combat.ContentName)

		text.set_text(text.get_text() + "Fixed Combat - " + fixed_combat_data.AssetName + "\n" \
				+ str(fixed_combat_data.Entries) + "\n\n")

		fixed_combats.add_child(text)
		text.set_owner(parent)

	# Create chests [dummy]
	var chests = Node2D.new()
	chests.set_name("ChestsDummy")
	activators.add_child(chests)
	chests.set_owner(parent)
	chests.set_hidden(true)
	chests.set("editor/display_folded", true)
	for chest in map_data.ChestEntries:
		# Parse the chest
		var chest_data = \
			chest_parser.parse(source_base.plus_file("Maps/Chests").plus_file(chest.ContentName + ".xml"))
		if typeof(chest_data) == TYPE_INT:
			# Errored
			return chest_data

		var text = Label.new()
		text.set_name(chest.ContentName)

		text.set_text(text.get_text() + "Chest - " + chest_data.AssetName + "\n" \
				+ str(chest_data.Entries) + "\n\n")

		chests.add_child(text)
		text.set_owner(parent)

	return OK

# Helper function to fill a tilemap based on an IntArray.
func fill_tilemap(tilemap, data, dimensions):
	for i in range(data.size()):
		var cell = data[i]
		var x = int(fmod(i, dimensions.x))
		var y = int(i / dimensions.x)
		tilemap.set_cell(x, y, cell)

# Normalize map position based on tile position.
func normalize_position(pos, map_data):
	return (pos * map_data["TileSize"]) + (map_data["TileSize"] / 2)
