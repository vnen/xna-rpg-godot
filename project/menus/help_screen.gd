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

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	set_focus_mode(FOCUS_ALL)
	grab_focus()

func _input_event(event):
	if event.is_pressed() and not event.is_echo():
		if event.is_action("ui_down"):
			accept_event()
			scroll_text(1)
		elif event.is_action("ui_up"):
			accept_event()
			scroll_text(-1)
		elif event.is_action("ui_cancel"):
			accept_event()
			release_focus()
			queue_free()


func scroll_text(amount):
	var text = get_node("HelpText")
	var lines = text.get_line_count()
	var max_lines = text.get_max_lines_visible()

	if lines <= max_lines:
		# No need to scroll if all lines are visible at once
		text.set_lines_skipped(0)
	else:
		# Scroll by amount but clamp it to valid values
		text.set_lines_skipped(clamp(text.get_lines_skipped() + amount, 0, lines - max_lines))