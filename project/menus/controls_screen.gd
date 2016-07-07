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
