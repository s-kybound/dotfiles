#!/usr/bin/env python3
# Generates the Super/Alt -> ESC+<key> relay mappings for tmux's
# i3/sway-like bindings (see ~/.config/tmux/tmux.conf, which binds
# M-<key>). The single source of truth is KEYS below; which physical
# modifier drives it is the one word in the sibling "modkey" file
# (super or alt) - that's the only thing that should differ per device.
import os

here = os.path.dirname(os.path.abspath(__file__))
try:
    with open(os.path.join(here, "modkey")) as f:
        mod = f.read().strip() or "super"
except FileNotFoundError:
    mod = "super"

if mod not in ("super", "alt"):
    mod = "super"

# (key spec suffix, character(s) to send after ESC)
KEYS = [
    ("h", "h"), ("j", "j"), ("k", "k"), ("l", "l"),
    ("shift+h", "H"), ("shift+j", "J"), ("shift+k", "K"), ("shift+l", "L"),
    ("backslash", "\\\\"),
    ("shift+minus", "_"),
    ("f", "f"),
    ("space", "\\x20"),
    ("enter", "\\x0d"),
    ("shift+q", "Q"),
    ("1", "1"), ("2", "2"), ("3", "3"), ("4", "4"), ("5", "5"),
    ("6", "6"), ("7", "7"), ("8", "8"), ("9", "9"),
    ("shift+1", "!"), ("shift+2", "@"), ("shift+3", "#"), ("shift+4", "$"),
    ("shift+5", "%"), ("shift+6", "^"), ("shift+7", "&"), ("shift+8", "*"), ("shift+9", "("),
    ("r", "r"),
    ("shift+c", "C"),
    ("shift+e", "E"),
]

for key, esc in KEYS:
    print(f"map {mod}+{key} send_text all \\x1b{esc}")
