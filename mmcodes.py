#!/usr/bin/python



import random, sys, getopt, math



USAGE = """
mmcodes [-c num_colors -p num_pegs -b bias -n num_codes -s seed]

Generate Mastermind codes and write them to the standard output, one code
per line.  Each line will contain a list of num_pegs space separated 
integers in the range 1 to num_colors.  

The following command line options are available:

  -c    The number of distinct colors.  Default is 6.

  -p    The number of pegs.  Default is 4.

  -b    A non-negative integer that selects a bias with which to generate
        codes.  The default is to choose colors uniformly at random for each
        peg.  Valid bias values include the following:

          0 - Uniform selection 
          1 - Use exactly one color
          2 - Prefer colors with smaller numbers
          3 - Cycle through all of the colors in order

  -n    The number of codes to generate and output.  Default is 1.

  -s    An integer to use as the random number generator seed.

  -h    Print this message.
"""



def main():

  num_colors = 8
  num_pegs = 6
  bias = 0
  num_codes = 1
  seed = 0

  opts, args = getopt.getopt(sys.argv[1:], "c:p:b:n:s:h")
  for o, a in opts:
    if o == "-c":
      num_colors = int(a)
      if num_colors < 1:
          print "Number of colors must be at least 1"
          sys.exit(0)
    elif o == "-p":
      num_pegs = int(a)
      if num_pegs < 1:
          print "Number of pegs must be at least 1"
          sys.exit(0)
    elif o == "-b":
      bias = int(a)
    elif o == "-n":
      num_codes = int(a)
      if num_codes < 1:
          print "Number of codes must be at least 1"
          sys.exit(0)
    elif o == "-s":
      seed = int(a)
    elif o =="-h":
      print USAGE
      sys.exit(0)


  if seed <> 0:
      random.seed(seed)
  else:
    random.seed()

  #
  # Choose codes uniformly at random
  #
  if bias == 0:

    for n in range(num_codes):
      for i in range(num_pegs):
        print random.randint(1, num_colors),
      print ""

  #
  # Use exactly one color
  #
  elif bias == 1:

    for n in range(num_codes):
      color = random.randint(1, num_colors)
      for i in range(num_pegs):
        print color,
      print ""

  #
  # Prefer colors with smaller numbers
  #
  elif bias == 2:

    for n in range(num_codes):
      for i in range(num_pegs):
        color = 0
        p = random.random() + 1E-10
        while (p > 0 and color < num_colors):
          color = color + 1
          p = p - math.pow(0.5, color)
        print color,
      print ""

  #
  # Cycle through the colors in order
  #
  elif bias == 3:

    for n in range(num_codes):
      color = random.randint(1, num_colors)
      for i in range(num_pegs):
        print color,
        color = (color + 1) % (num_colors + 1)
        if color == 0:
          color = 1
      print ""


  else:
    print "Invalid bias"



if __name__ == "__main__":

  main()
