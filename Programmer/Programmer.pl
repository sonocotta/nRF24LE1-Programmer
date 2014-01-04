#!/usr/bin/perl

# Programmer.pl - Program to feed Intel HEX files produced by SDCC to the nRF24LE1 Arduino 
# programmer sketch.

# Note: Ensure serial port speed is set to 57600 baud.

#  Copyright (c) 2014 Dean Cording
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

use strict;
use warnings;


if (@ARGV != 2) {
  print "Usage: $0 <Hex.file> <Arduino Serial Port>\n";
  exit;
}
  

open(HEX, "<", $ARGV[0]) or die "Cannot open $ARGV[0]: $!";
open(SERIAL, "+<", $ARGV[1]) or die "Cannot open $ARGV[1]: $!";

print SERIAL "GO\n";

while (1) {
 
  while (!defined($_ = <SERIAL>)) {}

  print;
  chomp;
  
  last if /DONE/;
 
  if (/OK/) {
    $_ = <HEX>;
    print;
    print SERIAL;
  }
}

close(HEX);
close(SERIAL);


