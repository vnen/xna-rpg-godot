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

extends TextureFrame

var showing_gamepad = true

func _ready():
	set_focus_mode(FOCUS_ALL)
	grab_focus()

	var action_map = {
		"main_menu": "Main Menu",
		"ui_accept": "Ok",
		"ui_cancel": "Back",
		"char_screen": "Character Management",
		"exit_game": "Exit Game",
		"take_view": "Take / View",
		"drop": "Drop / Unequip",
		"move_up": "Move Character - Up",
		"move_down": "Move Character - Down",
		"move_left": "Move Character - Left",
		"move_right": "Move Character - Right",
		"ui_up": "Move Cursor - Up",
		"ui_down": "Move Cursor - Down",
		"decrease": "Decrease Amount",
		"increase": "Increase Amount",
		"page_screen_left": "Page Screen Left",
		"page_screen_right": "Page Screen Right",
		"target_up": "Select Target -Up",
		"target_down": "Select Target - Down",
		"active_char_left": "Select Active Character - Left",
		"active_char_right": "Select Active Character - Right"
	}

	var action_list = [
		"main_menu",
		"ui_accept",
		"ui_cancel",
		"char_screen",
		"exit_game",
		"take_view",
		"drop",
		"move_up",
		"move_down",
		"move_left",
		"move_right",
		"ui_up",
		"ui_down",
		"decrease",
		"increase",
		"page_screen_left",
		"page_screen_right",
		"target_up",
		"target_down",
		"active_char_left",
		"active_char_right"
	]

	var action_text = ""
	var key1_text = ""
	var key2_text = ""

	for action in action_list:
		action_text += action_map[action] + "\n"

		var key_events = []

		for event in InputMap.get_action_list(action):
			if event.type == InputEvent.KEY:
				key_events.push_back(OS.get_scancode_string(event.scancode))

		if key_events.size() > 0:
			key1_text += key_events[0] + "\n"
			if key_events.size() > 1:
				key2_text += key_events[1] + "\n"
			else:
				key2_text += "---\n"
		else:
			key1_text += "---\n"
			key2_text += "---\n"


	action_text = action_text.substr(0, action_text.length() - 1)

	get_node("KeyList/ActionList").set_text(action_text)
	get_node("KeyList/Key1List").set_text(key1_text.replace("Return", "Enter"))
	get_node("KeyList/Key2List").set_text(key2_text.replace("Return", "Enter"))


func _input_event(event):
	if event.is_pressed() and not event.is_echo():
		if event.is_action("ui_down"):
			accept_event()
			if not showing_gamepad:
				scroll_action_list(1)
		elif event.is_action("ui_up"):
			accept_event()
			if not showing_gamepad:
				scroll_action_list(-1)
		elif event.is_action("ui_cancel"):
			accept_event()
			release_focus()
			queue_free()
		elif event.is_action("page_screen_left") or event.is_action("page_screen_right"):
			accept_event()
			change_page()


func scroll_action_list(amount):
	var action_list = get_node("KeyList/ActionList")
	var lines_skipped = 0
	var lines = action_list.get_line_count()
	var max_lines = action_list.get_max_lines_visible()

	if lines > max_lines:
		# Scroll by amount but clamp it to valid values
		lines_skipped = clamp(action_list.get_lines_skipped() + amount, 0, lines - max_lines)

	action_list.set_lines_skipped(lines_skipped)
	get_node("KeyList/Key1List").set_lines_skipped(lines_skipped)
	get_node("KeyList/Key2List").set_lines_skipped(lines_skipped)

func change_page():
	if showing_gamepad:
		# Change to keyboard view
		get_node("TitlePlank/TitleText").set_text("Keyboard")
		get_node("RightTriggerButton/RightTriggerLabel").set_text("Gamepad")
		get_node("LeftTriggerButton/LeftTriggerLabel").set_text("Gamepad")
		get_node("Joystick").hide()
		get_node("KeyListBG").show()
		get_node("KeyList").show()
		showing_gamepad = false
	else:
		# Change to gamepad view
		get_node("TitlePlank/TitleText").set_text("Gamepad")
		get_node("RightTriggerButton/RightTriggerLabel").set_text("Keyboard")
		get_node("LeftTriggerButton/LeftTriggerLabel").set_text("Keyboard")
		get_node("Joystick").show()
		get_node("KeyListBG").hide()
		get_node("KeyList").hide()
		showing_gamepad = true
