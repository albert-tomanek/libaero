#!/bin/env python3

import subprocess
import sys
import re

if __name__ == '__main__':
    _, inp, out = sys.argv

    rc = subprocess.run(f'gtk4-builder-tool simplify --3to4 "{inp}" > "{out}"', shell=True, stderr=subprocess.PIPE)

    # Errors look like: demo1.glade:98: property GtkScrolledWindow::shadow-type not found
    unsuported_props = set(re.findall("property (\S+)::(\S+) not found", rc.stderr.decode()))

    with open(out) as f:
        text = f.read()
    
    for klass, prop in unsuported_props:
        if not klass.startswith('Aero'):    # It doesnt know about ouw own classes props for some reason, even the inherited ones.
            print(f'Erasing unsupported property `{klass}.{prop}`')
            regex = f'(<object class="{klass}">.*?)<property name="{prop}">.*?</property>(.*?</object>)'
            text = re.sub(regex, r'\1\2', text, flags=re.S|re.M)
            text = re.sub("<packing>.*?<\/packing>", '', text, flags=re.S|re.M)
    
    with open(out, 'w') as f:
        f.write(text)