#!/bin/env python3

import sys, os
import re

gtk4_exclusive = [
    'Gdk.Texture',
    'Gtk.SignalListItemFactory',
    'Gtk.ListItem'
]

if __name__ == '__main__':
    _, vapi, out = sys.argv

    with open(vapi) as f:
        text = f.read()

    # Now we remove everything that would obstruct the .vapi in compiling as a library.

    text = re.sub(f'^\s*\[CCode.*?\]', '', text, 0, re.M|re.S)
    # text = re.sub(f'^\s*\[GtkTemplate.*?\]', '', text, 0, re.M|re.S)
    text = re.sub(f'^\s*\[GtkChild.*?\].*?;', '', text, 0, re.M|re.S)

    # Remove functions (keep signals and properties only)

    text = re.sub(f'^(?!.*\b\b).*\(.*?\).*?$', lambda m: '' if not ('signal' in m.group(0) or 'delegate' in m.group(0)) else m.group(0), text, 0, re.M)

    # Remove functions containyng symbols unsuported in Gtk3 (to actually allow it to compile under Gtk3)

    text = '\n'.join(l for l in text.splitlines() if all(type not in l for type in gtk4_exclusive))

    # Write to .vala file
    with open(out, 'w') as f:
        f.write(text)
