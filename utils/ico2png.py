#!/bin/env python3
# This is useful for converting .ico icons extracted directly from Windows

from PIL import Image
import numpy as np
import sys, os

if __name__ == "__main__":
    directory = sys.argv[1]
    for f in os.listdir(directory):
        if f.endswith('.ico') or f.endswith('.cur'):
            img = Image.open(f)
            img = Image.fromarray(np.array(img))    # When converting to an array, PIL converts the highest quality one.
            img.save(f.replace('.ico', '.png').replace('.cur', '.png'), 'PNG')
            os.system(f'rm "{f}"')

            # also possibly
            # run(f'convert {f} -transparent #808080 {f}')