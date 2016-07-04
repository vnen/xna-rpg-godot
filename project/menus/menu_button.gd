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

extends Button

export (String) var description = ""
export (int) var position_offset = 0

signal focused(desc)

var default_color
var focus_color

func _ready():
	default_color = get("custom_colors/font_color")
	focus_color = get("custom_colors/font_color_hover")
	connect("focus_enter", self, "_on_focus_enter")
	connect("focus_exit", self, "_on_focus_exit")
	set_process(true)

func _process(delta):
	set_margin(MARGIN_LEFT, position_offset)

func _on_focus_enter():
	set("custom_colors/font_color", focus_color)
	emit_signal("focused", description)

func _on_focus_exit():
	set("custom_colors/font_color", default_color)

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		_on_focus_exit()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		if has_focus():
			_on_focus_enter()
