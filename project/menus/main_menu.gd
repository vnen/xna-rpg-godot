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

func _ready():
	get_node("Buttons/NewGameButton").call_deferred("grab_focus")
	set_process_unhandled_input(true)

func _unhandled_input(event):
	if event.is_pressed() and not event.is_echo() and event.is_action("ui_cancel"):
		accept_event()
		print("evet")
		_on_ExitButton_pressed()

func _on_button_focused(description):
	get_node("DescriptionText").set_text(description)

# Button routines

func _on_NewGameButton_pressed():
	var loading_screen = load("res://menus/loading_screen.tscn").instance()
	add_child(loading_screen)
	loading_screen.connect("exit_tree", get_node("Buttons/NewGameButton"), "grab_focus")

func _on_SaveGameButton_pressed():
	var save_screen = load("res://menus/save_load_screen.tscn").instance()
	add_child(save_screen)
	save_screen.get_node("TitlePlank/TitleText").set_text("Save")
	save_screen.connect("exit_tree", get_node("Buttons/SaveGameButton"), "grab_focus")

func _on_LoadGameButton_pressed():
	var load_screen = load("res://menus/save_load_screen.tscn").instance()
	add_child(load_screen)
	load_screen.connect("exit_tree", get_node("Buttons/LoadGameButton"), "grab_focus")

func _on_ControlsButton_pressed():
	var controls_screen = load("res://menus/controls_screen.tscn").instance()
	add_child(controls_screen)
	controls_screen.connect("exit_tree", get_node("Buttons/ControlsButton"), "grab_focus")

func _on_HelpButton_pressed():
	var help_screen = load("res://menus/help_screen.tscn").instance()
	add_child(help_screen)
	help_screen.connect("exit_tree", get_node("Buttons/HelpButton"), "grab_focus")

func _on_ExitButton_pressed():
	var message_box = get_node("MessageBox")
	message_box.popup()
	message_box.grab_focus()

# Message Box

func _on_MessageBox_canceled():
	get_node("MessageBox").hide()

func _on_MessageBox_confirmed():
	get_tree().quit()
