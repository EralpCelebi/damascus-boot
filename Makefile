# Name: Damascus Boot Project
# Author: Çelebi, Eralp <eralp.celebi.personal@gmail.com>
# Version: v0.1
# Description: Makefile for the project.

# Copyright (C) 2021  Eralp Çelebi
# Author: Çelebi, Eralp <eralp.celebi.personal@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

as 		:= nasm
asflags := -f bin

all: damascus-boot.img
	@echo Built boot image.

clean:
	rm -rf damascus-boot.img
	rm -rf Object/*

run: damascus-boot.img
	@qemu-system-x86_64 -hda $^ -curses -nographic	# Uses qemu for emulation.

damascus-boot.img: Object/boot.bin
	@dd if=/dev/zero of=$@ bs=512 count=2			# Creates an image with the size of two sectors. 
	@dd if=Object/boot.bin of=$@ 					# Writes the bootloader binary to the image.

Object/%.bin: Source/%.asm
	@mkdir -p Object
	@$(as) $(asflags) $^ -o $@						# Compiles the binary.
