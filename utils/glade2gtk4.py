#!/bin/env python3

import subprocess
import sys
import re

if __name__ == '__main__':
    _, inp, out = sys.argv

    rc = subprocess.run(f'gtk4-builder-tool simplify --3to4 "{inp}" > "{out}"', shell=True, stderr=subprocess.PIPE)

    # Errors look like: demo1.glade:98: property GtkScrolledWindow::shadow-type not found
    unsuported_props = set(re.findall("property \S+::([\w-]+) not found", rc.stderr.decode()))

    with open(out) as f:
        text = f.read()
    
    for prop in unsuported_props:
        print(f'Erasing unsupported property `{prop}`')
        text = re.sub(f'\n\s*<property name=\"{prop}\".*>.*<.*>', '', text)
    
    with open(out, 'w') as f:
        f.write(text)
