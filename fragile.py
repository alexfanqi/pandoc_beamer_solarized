#!/usr/bin/env python3
'''
Filter to add fragile attribute to headers for beamer if the slide contains
CodeBlocks. Although Pandoc's beamer backend can already do this, it only
matches CodeBlock. This is useful to be applied before filters like listings or
minted that replaces CodeBlock with RawBlock.
'''

from pandocfilters import toJSONFilters, Header

def is_fragile(key):
    return key == 'CodeBlock'

def is_slide(key, value):
    # I personally prefer level 2 as slide sep
    return key == 'Header' and value[0] == 2

_slideno = 0
_fragile_slides = []
_cur_fragile = False

def record_fragile(key, value, format_, meta):
    global _fragile_slides
    global _slideno
    global _cur_fragile
    if format_ != 'beamer':
         return None
    if is_slide(key, value):
        _slideno+=1
        _cur_fragile = False
    if is_fragile(key):
        if not _cur_fragile:
            _fragile_slides.append(_slideno)
        _cur_fragile = True

_slideno2 = 0
_next_fragile = None
def insert_fragile(key, value, format_, meta):
    global _slideno2
    global _next_fragile
    global _fragile_slides
    if not _fragile_slides:
        return None
    if not _next_fragile:
        _next_fragile = _fragile_slides[0]
    if is_slide(key, value):
        _slideno2 += 1
        if _slideno2 == _next_fragile:
            level, meta, contents = value
            meta[1].append("fragile")
            _next_fragile = _fragile_slides.pop()
            return Header(level, meta, contents)

if __name__ == '__main__':
    toJSONFilters([record_fragile, insert_fragile])
