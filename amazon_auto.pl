#!/usr/bin/perl
use strict;
use warnings;


my @years = ('2012', '2013', '2014', '2015', '2016', '2017');

foreach my $year (@years){
  my @command = ('ruby', 'csv_category.rb', $year);
  my $ret = system @command;
  if ($ret != 0) {
    print "code[$ret]\n";
  }
  sleep(30);
}
