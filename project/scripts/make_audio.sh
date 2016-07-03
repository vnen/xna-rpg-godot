#!/bin/bash

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

# Audio converter. This uses ffmpeg to convert .wav files to .opus, but only
# the BGM. Sound effects are simply copied as is, since Godot can only
# understand wav for samples and cannot use them for streams.
# And since they're all together in the original project, this script is
# hardcoded to know what is stream and what is sample.

# Run this from the project folder!

CURDIR=$(pwd)
CURDIR=$(basename $CURDIR)

if [ $CURDIR != "project" ]
then
	echo "You must run this from the project folder!"
	exit 1
fi

mkdir -p sounds

for FILE in ../original/RolePlayingGame/Content/Audio/Waves/*.wav
do
	if [[ "$FILE" == *Theme.wav ]]
	then
		BASENAME=$(basename -s .wav "$FILE")
		ffmpeg -v 0 -y -i "$FILE" "sounds/$BASENAME.opus"
	else
		BASENAME=$(basename "$FILE")
		cp "$FILE" "sounds/$BASENAME"
	fi
done
