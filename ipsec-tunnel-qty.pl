#!/usr/bin/perl
use Net::Telnet; 

use strict;
my $iter=1;
my @output;

   my $t = new Net::Telnet (Timeout => 180, Prompt => '/\[local/');

                      
#   $t->open("$ARGV[0]");

   $t->open("10.126.142.204");
   $t->timeout(300);
   my $res=$t->login("test","test");
   $t->print("enable");
   my ($prematch, $match) = $t->waitfor(Match=>'/Password:/',
                                        Match=>'/#/');

   if ($match =~ /Password/) {
     $t->print("test");
     $t->waitfor('/#/');
   }

   $t->timeout(300);
   @output = $t->cmd("show tunnel ipsec on-demand");
   @output = $t->cmd("show tunnel ipsec on-demand");

#foreach(@output)

#{
#    print "$_\r\n";
#}


foreach(@output)
{
    if ($_ =~ /Total(\s+)(\d+)/) {
            print "$2";
         }

}



   $t->close();


