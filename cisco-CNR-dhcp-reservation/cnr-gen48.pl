#!/usr/bin/perl -w

my $templ="t48.txt";
my $res="res48.txt";
my $ip="ip-mac48.txt";


#-----====CLASS
#---=== gw == subnet + mask -2
#---=== switch ip == subnet + mask - 3


sub switch_obj {
# ip==gw !!!- odin mojno ubrat, no len
# sw_aggr - switch aggregacii

    my ($ip, $gw, $subnet, $mask, $mac, $hostname, $domain, $sw_aggr, $new_domain) = @_;
 
   $domain=~ s/^\s+//s;
   $domain=~ s/\s+$//s;

   $hostname=~ s/^\s+//s;
   $hostname=~ s/\s+$//s;
	
   $mac=~ s/^\s+//s;
   $mac=~ s/\s+$//s;

   $sw_aggr=~ s/^\s+//s;
   $sw_aggr=~ s/\s+$//s;

    my $self = {
	'ip'       => $ip,
	'gw'   	   => $gw,
        'subnet'   => $subnet,
        'mask'     => $mask,
	'mac'      => $mac,
	'hostname' => $hostname,
	'domain'   => $domain,
	'sw_aggr' =>  $sw_aggr,
	'new_domain' => $new_domain # new_domain == sw-22-003 get 003 + 500 == vl_503
   };
    return $self;
}

my @ip_mac_list=();


#----=====READ IP MAC LIST

sub read_ip_mac_list;
sub get_ip_gw;
sub  create_cli_script;
sub subnet_plus_ip;
sub  write_to_file;
sub get_new_domain;


&read_ip_mac_list;
&create_cli_script;

#---=== Functions ====-

sub read_ip_mac_list {
#print "-=== read_ip_mac_list ===-\n";

if ($ARGV[0])
	{print "use ip file - $ARGV[0]\n"; open IP, $ARGV[0] or die "Coudn't open $ARGV[0]";}
else
	{open (IP, $ip)  or die "Coudn't open ip_list $ip";}

foreach  (<IP>)
 {
#90.155.136.128	255.255.255.224	 00:19:5b:8c:3c:3e	sw-22-003	vl_503	sw-12-001
  if ((/^(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)\t(\S+)/))
   { 
    my ($ip,$gw)=get_ip_gw($1,$2);
    my ($new_dom)=get_new_domain($4);
    print "|$ip|, |$gw|\n";
    #print "|$ip|, |$gw|, |$1| |$2| |$3| |$4| |$5|\n";
    
    push @ip_mac_list, switch_obj($ip, $gw, $1,$2,$3,$4,$5,$6,$new_dom);
   }
  
 }
close(IP);
#print "====end func===\n";
}



sub get_ip_gw
{
 my ($subnet, $mask)=@_;

 my $sub="";
 my $msk="";

 if ($subnet =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/)
	{
	 $sub=$4;
	}
    else
	{
	  print "You enter wrong subnet!!!\n";
	  return 0;
	}
print "sub = $sub\n";

 if ($mask =~ /(\d+)\.(\d+)\.(\d+)\.(\d+)/)
	{
         $msk=$4;
	}
     else
	{
	  print "You enter wrong mask!!!\n";
	  return 0;
	}
print "msk= $msk\n";

$subnet =~ /(\d+\.\d+\.\d+\.)(\d+)/;
# знаю что можно изящней сразу в ретурн

#sub=128 msk=224  256-224 

my ($tmp_ip,$tmp_gw)=($sub+256-$msk-2,$sub+256-$msk-2);

return ($1.$tmp_ip,$1.$tmp_gw);

}


sub create_cli_script
{

foreach (@ip_mac_list)
{
 #print " $_->{ip} $_->{gw} $_->{subnet} $_->{mask}  $_->{mac} $_->{hostname} $_->{domain} \n";

  if (!open(TMPL, $templ))
        {
                print "Couldn't open $templ file: $! \n";
                return 0;
        }
  read(TMPL,$mystr,6000);
  close(TMPL);
 
 $mystr=~s/<%ip>/$_->{ip}/g;
 $mystr=~s/<%gw%>/$_->{gw}/g;
 $mystr=~s/<%hostname%>/$_->{hostname}/g;
 $mystr=~s/<%domain%>/$_->{domain}/g;
 $mystr=~s/<%mask%>/$_->{mask}/g;
 $mystr=~s/<%subnet%>/$_->{subnet}/g;
 $mystr=~s/<%mac%>/$_->{mac}/g;
 $mystr=~s/<%sw_aggr%>/$_->{sw_aggr}/g;
 $mystr=~s/<%new_domain%>/$_->{new_domain}/g;


$_->{subnet} =~ /(\d+\.\d+\.\d+\.)(\d+)/;
my $sub_3=$1;
my $sub_4=$2;

#print "sub_3=$sub_3, sub_4=$sub_4\n";

$mystr=~s/<%subnet\+(\d+)%>/$sub_3.(int($sub_4)+int($1))/eg;

#if ($mystr=~s/<%subnet\+(\d+)%>/$sub_3.(int($sub_4)+int($1))/g) 
 #  {
 #   my $res_ip=int($sub_4)+int($1);
 #   print "CATCH res_ip=$res_ip\n";
 #  $mystr=~s/<%subnet\+(\d+)%>/$sub_3$res_ip/g;

#   }
#else {continue}
# $mystr=~s/<%subnet\+(\d+)%>/<\%$sub_3\%>/g;
#  my $tmpip=$1+$sub_4;
# $mystr=~s/<%$sub_3%>/$sub_3$tmpip/g;
 


 
 #print "#=======CLASS====#\n";

 print "\n$mystr\n";

write_to_file($mystr);
 
}
 

}


# nujna tolko dlja  client-class <%gw%> set domain-name <%new_domain%> 
sub get_new_domain
{
 my ($nd)=$_; #sw-22-003
 my $res="";

 if ($nd=~ /sw-(\d+)-(\d+)/)

 { 
  my $vl_num=500+$2;
  $res="vl_".$vl_num;
  return $res;
 } 

else
{
 return "vl_num";
}

}


sub write_to_file
{
 
 my ($res1)=@_;
 
if(!open (ress,">>$res")){
	        print ("Couldn't open $res file: $! \n");
		return 0;
	}

print ress "$res1\n";
	close (ress);


}
