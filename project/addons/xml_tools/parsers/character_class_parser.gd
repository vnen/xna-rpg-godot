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

	# Read the header of the file to make sure it's a CharacterClass
	err = read_header("CharacterClass")
	if err != OK:
		return err

	var data = { "AssetName": asset_name }

	err = parse_initial_statistics(data)
	if err != OK:
		return err

	err = parse_leveling_statistics(data)
	if err != OK:
		return err

	err = read_object_array("LevelEntries", data, funcref(self, "parse_level_entry"))
	if err != OK:
		return err

	err = read_int("BaseExperienceValue", data)
	if err != OK:
		return err

	err = read_int("BaseGoldValue", data)
	if err != OK:
		return err

	# Finished :)
	return data

# Parse the InitialStatistics element.
func parse_initial_statistics(data):
	var err = get_next_element("InitialStatistics")
	if err != OK:
		return err

	var stats = {}

	err = read_int("HealthPoints", stats)
	if err != OK:
		return err

	err = read_int("MagicPoints", stats)
	if err != OK:
		return err

	err = read_int("PhysicalOffense", stats)
	if err != OK:
		return err

	err = read_int("PhysicalDefense", stats)
	if err != OK:
		return err

	err = read_int("MagicalOffense", stats)
	if err != OK:
		return err

	err = read_int("MagicalDefense", stats)
	if err != OK:
		return err

	data["InitialStatistics"] = stats

	return OK

# Parse the LevelingStatistics element.
func parse_leveling_statistics(data):
	var err = get_next_element("LevelingStatistics")
	if err != OK:
		return err

	var stats = {}

	err = read_int("HealthPointsIncrease", stats)
	if err != OK:
		return err

	err = read_int("LevelsPerHealthPointsIncrease", stats)
	if err != OK:
		return err

	err = read_int("MagicPointsIncrease", stats)
	if err != OK:
		return err

	err = read_int("LevelsPerMagicPointsIncrease", stats)
	if err != OK:
		return err

	err = read_int("PhysicalOffenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("LevelsPerPhysicalOffenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("PhysicalDefenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("LevelsPerPhysicalDefenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("MagicalOffenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("LevelsPerMagicalOffenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("MagicalDefenseIncrease", stats)
	if err != OK:
		return err

	err = read_int("LevelsPerMagicalDefenseIncrease", stats)
	if err != OK:
		return err

	data["LevelingStatistics"] = stats

	return OK

# Parse each level entry
func parse_level_entry(parser):

	var entry = {}

	var err = read_int("ExperiencePoints", entry)
	if err != OK:
		return err

	err = read_string_array("SpellContentNames", entry)
	if err != OK:
		return err

	return entry
