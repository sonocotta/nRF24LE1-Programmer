#!/usr/bin/perl

# Programmer.pl - Program to feed Intel HEX files produced by SDCC to the nRF24LE1 Arduino
# programmer sketch.  Will optionally set the number of protected pages and disable read of
# main memory block by SPI

# Usage:
#      programmer.pl <Hex file> <Arduino Serial Port> [NUPP] [RDISMB]
#
#      NUPP - Number of write unprotected memory blocks (0 - 31) - 0xFF: All pages unprotected
#      RDISMB - External read protect main memory block - 0x00 Protected, 0xFF Unprotected

# Note:
#      Program execution normally starts from address 0x0000 unless there is an odd number of ones
#      in the 16 topmost addresses of the flash memory (0x3FF0 - 0x3FFF).  How to set those bits
#      is left as an exercise for the reader. (Hint: Hack the hex file to write in those addresses.
#      You will also need to set an address offset for your code.)

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

my $nupp=0xff;
my $rdismb=0xff;

# Read NUPP from command line
if (defined($ARGV[2])) {
  $nupp = $ARGV[2];
  chomp $nupp;
  $nupp = oct($nupp) if $nupp =~ /^0/; # catches 077 0b10 0x20
  if ($nupp !~ /^\d+?$/) {
    undef $nupp;
  }
}

# Read RDISMB from command line
if (defined($ARGV[3])) {
  $rdismb = $ARGV[3];
  chomp $rdismb;
  $rdismb = oct($rdismb) if $rdismb =~ /^0/; # catches 077 0b10 0x20
  if ($rdismb !~ /^\d+?$/) {
    undef $rdismb;
  }
}

if ( (@ARGV < 2) || (!defined($nupp)) || (!defined($rdismb))) {
  print "Usage: $0 <Hex.file> <Arduino Serial Port> [NUPP] [RDISMB]\n";
  exit;
}

# Serial port settings to suit Arduino
system "stty -F $ARGV[1] 10:0:18b1:0:3:1c:7f:15:4:0:1:0:11:13:1a:0:12:f:17:16:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0";


open(HEX, "<", $ARGV[0]) or die "Cannot open $ARGV[0]: $!";
open(SERIAL, "+<", $ARGV[1]) or die "Cannot open $ARGV[1]: $!";

#Wait for Arduino reset
sleep(3);

#Send the flash trigger character
print SERIAL "\x01";

do {
  while (!defined($_ = <SERIAL>)) {}
  print;
  chomp;
} until /READY/;

print SERIAL "GO $nupp $rdismb\n";

while (1) {

  while (!defined($_ = <SERIAL>)) {}

  print;
  chomp;

  last if /READY/;

  last if /DONE/;

  if (/OK/) {
    $_ = <HEX>;
    print;
    print SERIAL;
  }
}

close(HEX);
close(SERIAL);


