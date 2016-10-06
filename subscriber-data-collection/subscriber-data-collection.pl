#!/usr/bin/perl 

print ("
task - collect troubleshooting M commands for N clients\n 
usage ./data-collection  file1-with-susbcribers.txt file2-template-with-commands.txt\n
 "); 

use strict;
use warnings;

my $tunnel_name="";
my $filename ="";
my $row="";
my @tunnels_arr=();
my $temp="";


my $fileinput = 'input-list-of-circuits.txt';
my $filetemplate = 'commands-to-collect-template.txt';

if ($ARGV[0]) {
    $fileinput = $ARGV[0];
 }  

if ($ARGV[1]) {
    $filetemplate = $ARGV[1];
} 


open(my $fh, '<:encoding(UTF-8)', $fileinput)
  or die "Could not open file '$fileinput' $!";
 
while (my $row = <$fh>) {
  chomp $row;
#  $row=~ /^(.*)(\@)(.*)$/;

if ( length($row) > 10) 
 {
  $row=~ /^(.*)(Circuit)(.*)$/;
#  print "$3\n";
  push(@tunnels_arr, $3); 
 } 
  
}



foreach $temp (@tunnels_arr)
{

open(my $fh1, '<:encoding(UTF-8)', $filetemplate)
  or die "Could not open file '$filetemplate' $!";

while (my $row = <$fh1>) {
  chomp $row;

$row=~  s/<cct-handle>/$temp/g;

  print "$row\n";
}
}

