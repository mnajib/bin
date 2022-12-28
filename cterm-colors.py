#!/usr/bin/env python

fg = '\033[38;5;'
bg = '\033[48;5;'

marker = 1
for i in range( 0, 256):
  n = str(i)
  #fgstr = fg + n + 'm' + n
  #bgstr = bg + n + 'm' 'XXXXX'
  fgstr = '\033[0m' + n
  bgstr = fg + n + 'm' + bg + n + 'm' 'XXXXX'

  if marker == 1:
    print(fgstr, bgstr, '\033[0m', end ="\t")
    marker = 2
  elif marker == 2:
    print(fgstr, bgstr, '\033[0m', end ="\t")
    marker = 3
  elif marker == 3:
    print(fgstr, bgstr, '\033[0m', end ="\t")
    marker = 4
  elif marker == 4:
    print(fgstr, bgstr, '\033[0m', end ="\t")
    marker = 5
  elif marker == 5:
    print(fgstr, bgstr, '\033[0m')
    marker = 1
